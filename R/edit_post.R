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
#' `edit_post()` requires a pane-capable IDE (RStudio or Positron) because it
#' relies on \pkg{rstudioapi} to display the dialog. It cannot be used in a
#' plain R console or non-interactive script.
#'
#' The `date-modified` field is automatically set to today's date on every
#' save; all other fields reflect exactly what was entered in the dialog.
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
  invisible()
}
