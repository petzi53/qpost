## Second resubmission

Version 1.0.0 was sent to CRAN on 2026-09-03 and accepted on 2026-09-12.
This update (1.1.0) consolidates all changes made since then into a single
resubmission: five bug fixes and two new features.

### Bug fixes since 1.0.0

1. **`resolve_target_file()` used wrong rstudioapi call** (`R/coins_generation.R`):
   `rstudioapi::getActiveDocumentContext()` returns `""` when the R Console has focus
   (which is always the case when calling `add_coins()` from the console). Replaced with
   `rstudioapi::getSourceEditorContext()`, which returns the path of the open source
   editor regardless of pane focus.

2. **No guard for directory paths in `add_coins()`** (`R/coins_generation.R`):
   Quarto blog posts live in `slug/index.qmd` directories. When a user passed the post
   directory rather than the `.qmd` file, `readr::read_lines()` crashed on the directory.
   `add_coins()` now auto-resolves a directory argument to `index.qmd` inside it, with
   a clear error if no such file exists.

3. **`\donttest{}` example used `tempdir()` instead of `tempfile()`** (`R/coins_generation.R`):
   `tempdir()` is the same directory for an entire R session. On a second example run the
   `index.qmd` already contained a COinS chunk, causing a `readline()` prompt in a
   non-interactive context and a silent no-op. Changed to `tempfile(); dir.create(tmp)`
   for a fresh directory each run.

4. **Quotation marks in user input broke the generated YAML** (`R/utils.R`,
   `R/edit_post.R`): Titles or other fields containing double quotes produced
   invalid YAML. A new internal helper `escape_yaml_dq()` escapes quotation
   marks in all text fields (title, subtitle, author, image-alt), preserving
   user intent exactly as typed. In addition, `edit_post()` now splices the new
   YAML block with `str_locate()`/`str_sub()` instead of `str_replace()`: ICU
   replacement strings treat backslash and `$` as escape characters, which
   silently undid the quote escaping on every edit.

5. **CRLF line endings broke YAML replacement on Windows** (`R/edit_post.R`,
   `R/coins_generation.R`): `readr::read_file()` reads in binary mode, so files
   with CRLF line endings caused the YAML-replacement regex to silently fail on
   Windows. Line endings are now normalised (CRLF -> LF) immediately after
   reading, before the regex is applied.

### New features since 1.0.0

1. **New exported function `edit_post()`** (`R/edit_post.R`): edit the YAML
   front matter of an existing post via an RStudio/Positron dialog. The dialog
   is pre-populated with current YAML values, auto-updates `date-modified` on
   every save, preserves the post body (only the YAML front matter is
   replaced), and optionally writes a `.bak` backup before modification.
   Also available as an RStudio addin.

2. **Title-change handling in `edit_post()`** (`R/edit_post.R`, `R/get_args.R`):
   When the user changes the title in the dialog, the title field shows an
   amber warning before the user clicks Done. After clicking Done, the user is
   asked whether to also create a new post directory for the new title. Choosing
   Yes copies all files to a new directory named after the new slug, renames the
   old directory to `_old-slug.bak/` (the leading `_` causes Quarto to skip it
   during rendering), and sets `draft: true` in the backup's `index.qmd` as an
   additional safety signal. The new file is opened in the editor automatically.
   Choosing No updates only the YAML `title:` field. If the target directory
   already exists, the operation falls back to a YAML-only update with a warning.

---

## Test environments

* local macOS aarch64 (R 4.6.1), via `devtools::check()`, 2026-09-16: 0 errors | 0 warnings | 0 notes
* win-builder (Windows R-release, 2026-09-16): 0 errors | 0 warnings | 1 note (see below)
* win-builder (Windows R-devel, 2026-09-16): 0 errors | 0 warnings | 1 note (see below)
* R-hub (`rhub::rhub_check()` on linux, m1-san, macos, macos-arm64, windows,
  2026-09-16): all platforms succeeded

## R CMD check results

0 errors | 0 warnings | 1 note (local: 0 notes)

* checking CRAN incoming feasibility ... NOTE
  Days since last update: 4

  We ask for an exception to the usual update cadence: this update fixes
  bugs discovered during first interactive use of the version accepted on
  2026-09-12. Two of them break basic functionality (add_coins() fails when
  the R Console has focus; edit_post() produces invalid YAML for titles
  containing quotation marks), so we would like to get the fixes to users
  quickly rather than wait out the customary interval.

## Additional checks

* `devtools::spell_check()`: no misspellings found beyond proper nouns and
  domain-specific terms (e.g., COinS, OpenURL, Zotero, RStudio).
* `urlchecker::url_check()`: all URLs resolve without redirects or errors.

## Downstream dependencies

qpost 1.0.0 has no reverse dependencies on CRAN.
