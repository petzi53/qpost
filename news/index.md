# Changelog

## qpost 1.2.1

- Fixed Windows line-ending bug in
  [`edit_post()`](https://www.peter-baumgartner.net/qpost/reference/edit_post.md):
  [`readr::read_file()`](https://readr.tidyverse.org/reference/read_file.html)
  reads in binary mode so files with CRLF line endings caused the
  YAML-replacement regex to silently fail on Windows. Line endings are
  now normalised (CRLF → LF) immediately after reading, before the regex
  is applied.
- Same CRLF normalisation applied to
  [`add_coins()`](https://www.peter-baumgartner.net/qpost/reference/add_coins.md)
  for consistency.

## qpost 1.2.0

- [`edit_post()`](https://www.peter-baumgartner.net/qpost/reference/edit_post.md)
  now handles title changes interactively:
  - When the title is modified in the dialog, the title field shows an
    amber warning reminding the user that a directory decision will
    follow
  - After clicking Done, the user is asked whether to create a new post
    directory for the new title
  - **Yes**: all files are copied to a new directory named after the new
    title’s kebab-case slug; the old directory is renamed to
    `_old-slug.bak/` (hidden from Quarto rendering by the leading `_`)
    and its `index.qmd` has `draft: true` set as an additional safety
    signal; the new file is opened automatically in the editor
  - **No**: only the YAML `title:` field is updated; the directory name
    stays unchanged
  - If the target new directory already exists, the operation falls back
    to a YAML-only update with a warning

## qpost 1.1.0

- New exported function
  [`edit_post()`](https://www.peter-baumgartner.net/qpost/reference/edit_post.md)
  for editing existing post YAML metadata via dialog
  - Pre-populates dialog with current YAML values
  - Auto-updates `date-modified` to today on every save
  - Preserves post body; only replaces YAML front matter
  - Optional `.bak` backup before modification
  - Available as RStudio/Positron addin
- Fixed critical bug: YAML rendering now correctly escapes quotation
  marks in user input
  - User intent is preserved (e.g., titles with quotes render exactly as
    typed)
  - New internal helper `escape_yaml_dq()` handles escaping
  - All text fields (title, subtitle, author, image-alt) now safe for
    special characters

## qpost 1.0.0

- Package renamed from `quartopost` to `qpost`
- Main function renamed from `quartopost()` to
  [`qpost()`](https://www.peter-baumgartner.net/qpost/reference/qpost.md)
- New exported function
  [`add_coins()`](https://www.peter-baumgartner.net/qpost/reference/add_coins.md)
  for COinS metadata generation
- [`add_coins()`](https://www.peter-baumgartner.net/qpost/reference/add_coins.md)
  gains a `file_path` argument, so it can be used outside
  RStudio/Positron by passing the target file explicitly
- All option names updated from `quartopost.*` prefix to `qpost.*`
