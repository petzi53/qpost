# "R/coins_generation.R"
#
# Prerequisites
# ─────────────────────────────────────────────────────────────────────────────
# Add the following to your PROJECT-LEVEL .Rprofile (next to _quarto.yml)
# and restart R once:
#
#   options(
#     qpost.lang    = "en",
#     qpost.license = "CC BY 4.0"
#   )
#
# After that, no manual YAML fields are needed for blog-title, url, lang, or
# license. All four are resolved automatically. Any field still present in a
# post's YAML header takes precedence, so per-post overrides still work.
# ─────────────────────────────────────────────────────────────────────────────

# ── 1. Read YAML front matter from a Quarto file ──────────────────────────────
read_yaml_header <- function(file_path) {
    lines <- readr::read_lines(file_path)

    delimiters <- which(stringr::str_detect(lines, "^---\\s*$"))

    if (length(delimiters) < 2) {
        stop("Could not find a valid YAML header (need two '---' delimiters).")
    }

    yaml_lines <- lines[(delimiters[1] + 1):(delimiters[2] - 1)]
    yaml::yaml.load(stringr::str_c(yaml_lines, collapse = "\n"))
}

# ── 2. Format a single author entry to "Lastname, Firstname" ──────────────────
format_author <- function(author_entry) {
    if (is.character(author_entry)) {
        parts <- stringr::str_split(author_entry, "\\s+")[[1]]
        if (length(parts) >= 2) {
            stringr::str_c(
                tail(parts, 1),
                stringr::str_c(head(parts, -1), collapse = " "),
                sep = ", "
            )
        } else {
            author_entry
        }
    } else if (is.list(author_entry)) {
        given  <- author_entry$name$given  %||% author_entry$given  %||% ""
        family <- author_entry$name$family %||% author_entry$family %||% ""
        if (nzchar(family)) stringr::str_c(family, given, sep = ", ") else given
    } else {
        as.character(author_entry)
    }
}

# ── 3a. Locate the project root (directory containing _quarto.yml) ────────────
#
#  Walks up the directory tree from `start_path` until it finds `_quarto.yml`
#  or reaches the filesystem root.
#
find_project_root <- function(start_path) {
    dir <- if (fs::is_file(start_path)) fs::path_dir(start_path) else start_path

    repeat {
        if (fs::file_exists(fs::path(dir, "_quarto.yml"))) return(dir)
        parent <- fs::path_dir(dir)
        if (identical(parent, dir)) {
            stop("Could not find '_quarto.yml' anywhere above: ", start_path)
        }
        dir <- parent
    }
}

# ── 3b. Read _quarto.yml starting from any file inside the project ────────────
read_quarto_yml <- function(start_path) {
    root <- find_project_root(start_path)
    yaml::yaml.load_file(fs::path(root, "_quarto.yml"))
}

# ── 3c. Derive blog-title and full post URL from _quarto.yml + document path ──
#
#  Returns a named list:
#    $blog_title  – website: title  from _quarto.yml
#    $post_url    – site-url + relative path of the document (extension stripped)
#
derive_site_metadata <- function(file_path, quarto_cfg) {

    # Blog title
    blog_title <- quarto_cfg$website$title %||% NA_character_

    # Base URL — strip any trailing slash for safe concatenation
    site_url <- stringr::str_remove(
        quarto_cfg$website$`site-url` %||% NA_character_,
        "/$"
    )

    # Relative path of the .qmd inside the project, extension stripped.
    # Quarto publishes  posts/slug/index.qmd  as  <site-url>/posts/slug/index
    project_root <- find_project_root(file_path)
    rel_stem     <- fs::path_ext_remove(fs::path_rel(file_path, project_root))

    post_url <- if (!is.na(site_url)) {
        stringr::str_c(site_url, "/", rel_stem)
    } else {
        NA_character_
    }

    list(blog_title = blog_title, post_url = post_url)
}

# ── 4. Build the raw key-value pairs from YAML metadata ───────────────────────
#
#  Zotero COinS field mapping for mtx:dc + rft.type=blogPost:
#
#  YAML field        COinS key          Zotero field
#  ──────────────────────────────────────────────────────────────
#  title + subtitle  rft.title          Title ("Title: Subtitle")
#                                       Zotero auto-splits on ":" →
#                                       Short Title = part before ":"
#  blog-title        rft.source         Blog Title
#  url               rft_id             URL (top-level key, no dot)
#  date              rft.date           Date
#  lang              rft.language       Language
#  license           rft.rights         Rights
#  description       rft.description    Abstract
#  author            rft.au             Author
#  ──────────────────────────────────────────────────────────────
#
#  NOTE: There is no explicit COinS key for Short Title.
#  Zotero derives Short Title automatically by splitting rft.title on ":"
#  and taking everything before the colon. Therefore the separator between
#  title and subtitle MUST be ": " (colon + space), not " – " (em dash).
#
#  Auto-resolution priority for the four formerly-manual fields:
#    1. Value present in the document's YAML header      → used as-is
#    2. blog-title / url: derived from _quarto.yml       → filled in
#    3. lang / license:   getOption("qpost.*")           → filled in
#    4. Nothing found anywhere                           → field omitted
# ─────────────────────────────────────────────────────────────────────────────
build_coins_pairs <- function(meta, file_path = NULL) {

    # ── Validate required fields ─────────────────────────────────────────────
    required       <- c("title", "date")
    missing_fields <- required[!required %in% names(meta)]
    if (length(missing_fields) > 0) {
        stop(stringr::str_c(
            "Missing required YAML fields: ",
            stringr::str_c(missing_fields, collapse = ", ")
        ))
    }

    # ── Auto-fill blog-title and url from _quarto.yml ────────────────────────
    if (!is.null(file_path)) {
        quarto_cfg <- read_quarto_yml(file_path)
        site_meta  <- derive_site_metadata(file_path, quarto_cfg)

        # blog-title: YAML wins; fall back to _quarto.yml website title
        if (is.null(meta$`blog-title`) || !nzchar(meta$`blog-title`)) {
            meta$`blog-title` <- site_meta$blog_title
        }

        # url: YAML wins; fall back to constructed canonical URL
        if (is.null(meta$url) || !nzchar(meta$url)) {
            meta$url <- site_meta$post_url
        }
    }

    # ── Auto-fill lang and license from .Rprofile options ────────────────────
    if (is.null(meta$lang) || !nzchar(meta$lang)) {
        meta$lang <- getOption("qpost.lang", default = NA_character_)
    }

    if (is.null(meta$license) || !nzchar(meta$license)) {
        meta$license <- getOption("qpost.license", default = NA_character_)
    }

    # ── Title handling ────────────────────────────────────────────────────────
    # Separator MUST be ": " so Zotero auto-populates Short Title from the
    # part of rft.title that precedes the colon
    title_full <- if (!is.null(meta$subtitle) && nzchar(meta$subtitle)) {
        stringr::str_c(meta$title, meta$subtitle, sep = ": ")
    } else {
        meta$title
    }

    # ── Fixed base pairs ──────────────────────────────────────────────────────
    pairs <- c(
        "ctx_ver"     = "Z39.88-2004",
        "rft_val_fmt" = "info:ofi/fmt:kev:mtx:dc",
        "rft.type"    = "blogPost",               # forces Zotero item type
        "rft.title"   = title_full,               # "Title: Subtitle" → Zotero splits
        "rft.date"    = stringr::str_extract(as.character(meta$date), "^\\d{4}")
    )

    # ── Optional pairs ────────────────────────────────────────────────────────

    # Blog title
    if (!is.null(meta$`blog-title`) && !is.na(meta$`blog-title`) &&
        nzchar(meta$`blog-title`)) {
        pairs["rft.source"] <- meta$`blog-title`
    }

    # URL → rft_id (top-level OpenURL identifier, NO dot after rft)
    if (!is.null(meta$url) && !is.na(meta$url) && nzchar(meta$url)) {
        pairs["rft_id"] <- meta$url
    }

    # Language
    if (!is.null(meta$lang) && !is.na(meta$lang) && nzchar(meta$lang)) {
        pairs["rft.language"] <- meta$lang
    }

    # License / rights
    if (!is.null(meta$license) && !is.na(meta$license) && nzchar(meta$license)) {
        pairs["rft.rights"] <- meta$license
    }

    # Abstract / description
    if (!is.null(meta$description) && nzchar(meta$description)) {
        pairs["rft.description"] <- meta$description
    }

    # ── Author pairs (may be multiple) ───────────────────────────────────────
    authors <- meta$author
    if (!is.null(authors)) {
        if (!is.list(authors) || is.character(authors)) authors <- list(authors)
        author_strings <- purrr::map_chr(authors, format_author)
        author_pairs   <- rlang::set_names(
            author_strings,
            rep("rft.au", length(author_strings))
        )
        pairs <- c(pairs, author_pairs)
    }

    pairs
}

# ── 5. Encode key-value pairs into a COinS query string ───────────────────────
build_coins_query_string <- function(pairs) {
    pairs |>
        purrr::imap_chr(\(v, k) stringr::str_c(
            urltools::url_encode(k), "=", urltools::url_encode(v)
        )) |>
        stringr::str_c(collapse = "&")
}

# ── 6. Wrap the query string into a Quarto R chunk ────────────────────────────
render_coins_chunk <- function(pairs) {
    query_string <- build_coins_query_string(pairs)

    # Escape backslashes first, then double-quotes, for safe embedding
    # in a paste0() string literal inside the generated chunk
    query_string_escaped <- stringr::str_replace_all(
        query_string, "\\\\", "\\\\\\\\"
    )
    query_string_escaped <- stringr::str_replace_all(
        query_string_escaped, '"', '\\\\"'
    )

    chunk_lines <- c(
        "```{r}",
        "#| label: coins-code",
        "#| results: asis",
        "#| echo: false",
        "",
        paste0('coins_metadata <- "title=\'', query_string_escaped, '\'"'),
        "",
        "coins_html <- paste0('<span class=\"Z3988\" ', coins_metadata, '></span>')",
        "",
        "cat(coins_html)",
        "```"
    )

    paste(chunk_lines, collapse = "\n")
}

# ── 7. Append or overwrite the COinS chunk in the Quarto file ─────────────────
append_coins_to_file <- function(path, chunk, backup = TRUE) {

    existing_content <- readr::read_file(path)
    coins_present    <- stringr::str_detect(existing_content, "label: coins-code")

    if (coins_present) {
        # ── Ask user whether to overwrite ─────────────────────────────────────
        answer <- readline(
            prompt = "COinS chunk already present. Overwrite? [y/N]: "
        )

        if (!stringr::str_to_lower(stringr::str_trim(answer)) %in% c("y", "yes")) {
            message("Skipping \u2014 existing COinS chunk left unchanged.")
            return(invisible(NULL))
        }

        # ── Backup before overwriting ──────────────────────────────────────────
        if (backup) {
            bak_path <- stringr::str_c(path, ".bak")
            file.copy(path, bak_path, overwrite = TRUE)
            message("Backup written to:        ", bak_path)
        }

        # ── Remove old comment + chunk (everything from marker to end of file) ─
        # (?s) enables dotall mode inline so "." matches newlines too
        remove_pattern <- paste0(
            "(?s)",
            "(\n<!-- COinS metadata for Zotero compatibility ",
            "\\(auto-generated\\) -->\n)?",
            "\n?```\\{r\\}\n#\\| label: coins-code.*"
        )

        cleaned_content <- stringr::str_remove(existing_content, remove_pattern)

        # ── Build final content: cleaned body + new chunk ────────────────
        new_content <- stringr::str_c(
            cleaned_content,
            "\n",
            "<!-- COinS metadata for Zotero compatibility (auto-generated) -->",
            "\n\n",
            chunk,
            "\n"
        )

        readr::write_file(new_content, path)
        message("COinS chunk overwritten in: ", path)

    } else {

        # ── No existing COinS: just append ────────────────────────────────────
        if (backup) {
            bak_path <- stringr::str_c(path, ".bak")
            file.copy(path, bak_path, overwrite = TRUE)
            message("Backup written to:        ", bak_path)
        }

        full_addition <- c(
            "",
            "<!-- COinS metadata for Zotero compatibility (auto-generated) -->",
            "",
            chunk
        )

        readr::write_lines(full_addition, path, append = TRUE)
        message("COinS chunk appended to:  ", path)
    }
}


# ── 8. Orchestrate: read → build pairs → render chunk → append/overwrite ───────
generate_and_append_coins <- function(file_path, backup = TRUE) {

    message("Processing: ", file_path)

    meta  <- read_yaml_header(file_path)
    pairs <- build_coins_pairs(meta, file_path = file_path)  # file_path enables
    chunk <- render_coins_chunk(pairs)                        # auto-resolution

    append_coins_to_file(path = file_path, chunk = chunk, backup = backup)

    # Print the generated chunk to the console for inspection
    message("\n\u2500\u2500 Generated COinS chunk ",
            strrep("\u2500", 51), "\n")
    cat(chunk, "\n")
    message(strrep("\u2500", 72), "\n")

    invisible(chunk)
}


# ── 9. Convenience wrapper ────────────────────────────────────────────────────
#' Generate and append COinS metadata to a Quarto post
#'
#' Automatically extracts bibliographic metadata from a Quarto post's YAML
#' front matter and injects it as a COinS (ContextObjects in Spans) metadata
#' chunk. COinS enables bibliographic tools like Zotero to detect and import
#' citation information from rendered HTML.
#'
#' @details
#'
#' ## Setup
#'
#' To use `add_coins()` effectively, configure your project's `.Rprofile`
#' (at the same level as `_quarto.yml`) with:
#'
#' ```r
#' options(
#'   qpost.lang    = "en",
#'   qpost.license = "CC BY 4.0"
#' )
#' ```
#'
#' Then restart your R session. These settings provide defaults for the
#' `lang` and `license` fields, which can be overridden per-post.
#'
#' ## Auto-resolution of Metadata Fields
#'
#' Four YAML fields are automatically resolved in this priority order:
#' 1. Value in the document's YAML header (if present and non-empty)
#' 2. Derived from `_quarto.yml` (`blog-title` and `url` only)
#' 3. From `.Rprofile` options (`lang` and `license` only)
#' 4. Omitted if not found anywhere
#'
#' The required fields `title` and `date` must be present in the YAML header.
#'
#' ## Generated Output
#'
#' The function appends a fenced R code cell (`{r}` block) with output
#' rendered as a hidden `<span class="Z3988">` containing the COinS query
#' string. This metadata is machine-readable but invisible in the browser.
#'
#' If a COinS chunk already exists (detected by the label `coins-code`),
#' the user is prompted to confirm overwrite, and a `.bak` backup is created.
#'
#' @param backup Logical. Create a `.bak` backup before modifying the file
#'   (default `TRUE`). Recommended for peace of mind during development.
#'
#' @return Invisibly returns the generated COinS chunk as a character string.
#'   Messages and the chunk code are printed to the console.
#'
#'
#' @examples
#' \dontrun{
#' # From an RStudio editor with a .qmd file open:
#' add_coins()
#'
#' # To skip backup:
#' add_coins(backup = FALSE)
#'
#' # To manually process a file path (no RStudio required):
#' generate_and_append_coins("path/to/post.qmd")
#' }
#' @export

add_coins <- function(backup = TRUE) {
    if (!rstudioapi::isAvailable()) {
        stop(
            "add_coins() requires RStudio. ",
            "Call generate_and_append_coins(file_path) directly.",
            call. = FALSE
        )
    }

    target_file <- rstudioapi::getSourceEditorContext()$path

    if (!nzchar(target_file)) {
        stop(
            "No active file detected. Open the target .qmd in the editor first.",
            call. = FALSE
        )
    }

    generate_and_append_coins(target_file, backup = backup)
}

