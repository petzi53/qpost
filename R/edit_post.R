# ── Helper: flatten a YAML author field to a plain string ─────────────────────
#
# YAML author entries can be a plain string, a list with a "name" key, or
# a nested list with "given"/"family". Returns a single display string.
#
extract_author_string <- function(author) {
  if (is.null(author)) return("")
  if (is.character(author)) return(author[[1]])
  if (is.list(author)) {
    a <- author[[1]]
    if (is.character(a)) return(a)
    if (is.list(a)) {
      nm <- a$name
      if (is.character(nm)) return(nm)
      if (is.list(nm)) {
        given  <- nm$given  %||% ""
        family <- nm$family %||% ""
        return(stringr::str_trim(paste(given, family)))
      }
    }
  }
  as.character(author)
}


#' Edit an Existing Quarto Blog Post's YAML Header
#'
#' `edit_post()` opens the same interactive dialog as [qpost()], pre-populated
#' with the metadata from an existing post. On submit it rewrites only the YAML
#' front matter, leaving the post body untouched.
#'
#' @details
#' `edit_post()` requires a pane-capable IDE (RStudio or Positron) because it
#' relies on \pkg{rstudioapi} to display the dialog. It cannot be used in a
#' plain R console or non-interactive script.
#'
#' **Changing the title**
#'
#' When you modify the title in the dialog and click Done, you are asked
#' whether to create a new post directory for the new title:
#'
#' - **Yes** — copies all files from the old post directory into a new
#'   directory named after the new title's kebab-case slug. The original
#'   directory is renamed to `_old-slug.bak/` and its `index.qmd` has
#'   `draft: true` set. The new file is opened in the editor automatically.
#' - **No** — updates only the YAML `title:` field; the directory name
#'   stays unchanged.
#'
#' **Important:** if the post has already been published, creating a new
#' directory changes its URL. This will break existing links, bookmarks,
#' and search-engine entries pointing to the old address.
#'
#' The backup directory is protected from accidental publication by two
#' independent mechanisms: the leading `_` in its name causes Quarto to
#' skip it during rendering (consistent with Quarto's own `_freeze/` and
#' `_site/` convention), and `draft: true` in the YAML acts as an
#' additional human-readable signal. To recover the old title, rename the
#' directory by removing the leading `_` and the `.bak` suffix.
#'
#' The dialog shows a reminder in the title field as soon as it detects
#' a change, so you are always aware before clicking Done.
#'
#' **`date-modified`**
#'
#' This field is automatically set to today's date on every save.
#'
#' @param file_path Optional path to a `.qmd` file. When `NULL` (the default),
#'   `edit_post()` uses the file currently open in the RStudio or Positron
#'   editor.
#' @param backup Logical. If `TRUE` (the default), a `.bak` copy of the
#'   original file is created before any changes are made.
#'
#' @return Nothing. The side effect is an updated YAML front matter in the
#'   target `.qmd` file.
#' @export
#'
#' @examplesIf interactive()
#' edit_post()
#'
edit_post <- function(file_path = NULL, backup = TRUE) {
  if (!rstudioapi::isAvailable()) {
    stop("edit_post() requires a pane-capable IDE (RStudio or Positron). ",
         "Please run it from within RStudio or Positron.")
  }

  # Resolve the target file
  if (is.null(file_path)) {
    file_path <- resolve_target_file()
  }
  if (!fs::file_exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  # Read existing YAML header
  yaml_header <- read_yaml_header(file_path)

  # Build the defaults list that pre-populates the dialog
  defaults <- list(
    title         = yaml_header$title         %||% "",
    subtitle      = yaml_header$subtitle      %||% "",
    author        = extract_author_string(yaml_header$author),
    date          = tryCatch(as.Date(yaml_header$date),
                             error = function(e) lubridate::today()),
    alt           = yaml_header[["image-alt"]] %||% "",
    categories    = if (!is.null(yaml_header$categories))
                      unlist(yaml_header$categories)
                    else character(0),
    description   = stringr::str_trim(yaml_header$description %||% ""),
    current_image = yaml_header$image         %||% ""
  )

  # Retrieve per-post or global options
  show_empty_fields <- getOption("qpost.show_empty_fields") %||% TRUE
  draft <- yaml_header$draft %||% getOption("qpost.draft") %||% TRUE

  # Open the pre-populated dialog
  params <- get_args(defaults = defaults)

  if (is.null(params)) return(invisible())

  # -- Title-change: optionally create a new directory -------------------------
  title_changed <- isTRUE(params$file_data$title_changed)
  create_new_dir <- FALSE

  if (title_changed) {
    old_dir  <- fs::path_dir(file_path)
    old_slug <- fs::path_file(old_dir)
    new_slug <- paste0(params$date, "-", title_kebab(params$file_data$title))
    new_dir  <- fs::path(fs::path_dir(old_dir), new_slug)
    bak_dir  <- fs::path(fs::path_dir(old_dir), paste0("_", old_slug, ".bak"))

    create_new_dir <- yesno::yesno(
      "The title changed. Create a new post directory for the new title?\n\n",
      "  New directory : posts/", new_slug, "/\n",
      "  Old directory : posts/", old_slug, "/ -> backed up as ",
                        "_", old_slug, ".bak/\n\n",
      "WARNING: If this post is already published, the old URL will stop\n",
      "working. Fix any links pointing to the old address before publishing.\n",
      "The backup directory (prefixed with '_') is hidden from Quarto rendering\n",
      "and can be restored by removing the leading '_' and '.bak' from its name.\n\n",
      "Yes = create new directory + backup old one + update YAML title\n",
      "No  = update YAML title only, directory unchanged"
    )
  }

  if (create_new_dir) {
    if (fs::dir_exists(new_dir)) {
      warning(
        "Directory '", new_dir, "' already exists - ",
        "directory not created; only the YAML title was updated.",
        call. = FALSE
      )
      create_new_dir <- FALSE  # safe fallback: YAML-only update
    } else {
      # Copy all files to new directory
      fs::dir_copy(old_dir, new_dir)
      # Rename old directory to _old-slug.bak/ (underscore hides from Quarto)
      fs::file_move(old_dir, bak_dir)
      # Set draft: true in the backup's index.qmd as a secondary safety signal
      bak_qmd <- fs::path(bak_dir, "index.qmd")
      if (fs::file_exists(bak_qmd)) {
        bak_content <- readr::read_file(bak_qmd)
        bak_content <- stringr::str_replace(
          bak_content,
          stringr::regex("^draft:.*$", multiline = TRUE),
          "draft: true"
        )
        readr::write_file(bak_content, bak_qmd)
      }
      # Switch file_path to the new location
      file_path <- fs::path(new_dir, "index.qmd")
      message("New directory created  : ", new_dir)
      message("Old directory backed up: ", bak_dir,
              " (hidden from Quarto rendering)")
    }
  }

  # Image: use the newly uploaded file, or keep the existing one
  image_name <- if (!is.null(params$image)) params$image$name else defaults$current_image

  # Build the updated YAML, stamping date-modified with today
  description <- prepare_description(params$description)
  cats        <- prepare_categories(params$categories, params$newcat)
  new_yaml    <- prepare_yaml(
    params, description, image_name, cats, draft, show_empty_fields,
    date_modified = as.character(lubridate::today())
  )

  # Backup before any modification
  if (backup) {
    fs::file_copy(file_path, paste0(file_path, ".bak"), overwrite = TRUE)
  }

  # Replace only the YAML block; preserve everything after the closing ---
  content <- readr::read_file(file_path)
  # Normalize CRLF to LF so the regex works on Windows too
  content <- stringr::str_replace_all(content, "\r\n", "\n")
  new_content <- stringr::str_replace(
    content,
    stringr::regex("^---[\\s\\S]*?^---\\n", multiline = TRUE),
    new_yaml
  )
  readr::write_file(new_content, file_path)

  # Copy a newly uploaded image into the post directory
  if (!is.null(params$image)) {
    fs::file_copy(
      params$image$datapath,
      fs::path(fs::path_dir(file_path), params$image$name),
      overwrite = TRUE
    )
  }

  message("YAML header updated: ", file_path)

  # Open the new file when the directory was created
  if (create_new_dir) {
    rstudioapi::documentOpen(file_path)
  }

  invisible()
}
