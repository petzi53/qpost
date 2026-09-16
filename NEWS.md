# qpost 1.1.0

* New exported function `edit_post()` for editing existing post YAML metadata via dialog
  - Pre-populates dialog with current YAML values
  - Auto-updates `date-modified` to today on every save
  - Preserves post body; only replaces YAML front matter
  - Optional `.bak` backup before modification
  - Available as RStudio/Positron addin
* `edit_post()` handles title changes interactively:
  - When the title is modified in the dialog, the title field shows an amber
    warning reminding the user that a directory decision will follow
  - After clicking Done, the user is asked whether to create a new post
    directory for the new title
  - **Yes**: all files are copied to a new directory named after the new
    title's kebab-case slug; the old directory is renamed to
    `_old-slug.bak/` (hidden from Quarto rendering by the leading `_`) and
    its `index.qmd` has `draft: true` set as an additional safety signal;
    the new file is opened automatically in the editor
  - **No**: only the YAML `title:` field is updated; the directory name stays
    unchanged
  - If the target new directory already exists, the operation falls back to
    a YAML-only update with a warning
* Bug fixes:
  - `add_coins()` now uses `rstudioapi::getSourceEditorContext()` instead of
    `rstudioapi::getActiveDocumentContext()`, so it resolves the target file
    correctly even when the R Console has focus
  - `add_coins()` auto-resolves a directory argument to the `index.qmd` file
    inside it, with a clear error if no such file exists
  - The `\donttest{}` example of `add_coins()` uses `tempfile()` instead of
    `tempdir()`, so repeated runs no longer hit a stale COinS chunk and a
    `readline()` prompt in a non-interactive context
  - YAML rendering now correctly escapes quotation marks in user input via the
    new internal helper `escape_yaml_dq()`; all text fields (title, subtitle,
    author, image-alt) are safe for special characters
  - the YAML block replacement in `edit_post()` now splices text with
    `str_locate()`/`str_sub()` instead of `str_replace()`: ICU replacement
    strings treat backslash and `$` as escape characters, which silently
    undid the quote escaping on every edit
  - Fixed Windows line-ending bug: `readr::read_file()` reads in binary mode,
    so files with CRLF line endings caused the YAML-replacement regex to
    silently fail on Windows; line endings are now normalised (CRLF -> LF)
    immediately after reading in both `edit_post()` and `add_coins()`

# qpost 1.0.0

* Package renamed from `quartopost` to `qpost`
* Main function renamed from `quartopost()` to `qpost()`
* New exported function `add_coins()` for COinS metadata generation
* `add_coins()` gains a `file_path` argument, so it can be used outside RStudio/Positron by passing the target file explicitly
* All option names updated from `quartopost.*` prefix to `qpost.*`

# quartopost 0.3.0

* New UI: Bigger window holds all fields in one tab
* Add proof if title is valid inside the dialog window.
* Provide feedback of status of title field after loosing focus
* Remove failed file creation if title is not valid (not needed anymore)
* Add configuration for draft post status
* Add configuration to show or hide empty fields
* Resolve bug: Put cursor at the end of the YAML front matter.

# quartopost 0.2.2

* Find the first YAML header to prevent that YAML from R code example is taken 


# quartopost 0.2.1

* Resolved bug to find YAML header

# quartopost 0.2.0

* Added configuration settings
    - verbose = FALSE: 
      - Do not ask user for confirmation before action 
      - Do not show error message when user cancels


* Added checks for user input
    - Is it a quarto website?
    - Is a title provided?
    - Does the file name already exist?

# quartopost 0.1.0

* Added a `NEWS.md` file to track changes to the package.
