## Second resubmission (2026-09-08)

Two post-submission bugs discovered during first interactive use have been fixed:

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

---

## First resubmission (2026-09-03)

This was a resubmission. Two issues raised by the CRAN team were fixed:

1. **`cat()` in package function** (`R/coins_generation.R`):  
   The `cat()` call in `generate_and_append_coins()` that printed the generated
   COinS chunk to the console has been replaced by `message()`, which can be
   suppressed by the user with `suppressMessages()`.

2. **Writing to home filespace in examples** (`R/coins_generation.R`):  
   A `\donttest{}` example has been added to `add_coins()` that creates all
   required files inside `tempdir()` and passes the path explicitly via
   `file_path =`. The existing `\dontrun{}` block for IDE-based workflows is
   retained.

1. **`cat()` in package function** (`R/coins_generation.R`):  
   The `cat()` call in `generate_and_append_coins()` that printed the generated
   COinS chunk to the console has been replaced by `message()`, which can be
   suppressed by the user with `suppressMessages()`.

2. **Writing to home filespace in examples** (`R/coins_generation.R`):  
   A `\donttest{}` example has been added to `add_coins()` that creates all
   required files inside `tempdir()` and passes the path explicitly via
   `file_path =`. The existing `\dontrun{}` block for IDE-based workflows is
   retained.

---

## Original submission note

This is a new package. It was previously developed on GitHub under the name
`quartopost`, but was never submitted to CRAN under that name. Version 1.0.0
renames the package and its exported functions, adds tests and vignettes,
and fixes a categories-formatting bug.

## Test environments

* local macOS aarch64 (R 4.6.1), via `devtools::check()`, 2026-09-08: 0 errors | 0 warnings | 0 notes
* win-builder (Windows R-release, 2026-08-23): 0 errors | 0 warnings | 1 note
* win-builder (Windows R-devel, 2026-09-03): 0 errors | 0 warnings | 1 note (see below)
* win-builder (macOS R-devel, 2026-08-23): succeeded
* R-hub (`rhub::check_for_cran()`, 2026-08-23): all platforms succeeded

## R CMD check results

0 errors | 0 warnings | 1 note (local: 0 notes)

* checking CRAN incoming feasibility ... NOTE
  New submission.
  Possibly misspelled words in DESCRIPTION: COinS, ContextObjects.
  Both are correctly spelled; COinS ("ContextObjects in Spans") is the
  standard name of the embedded-metadata format the package's `add_coins()`
  function implements (see https://en.wikipedia.org/wiki/COinS), and is
  capitalized consistently throughout the package's documentation and
  vignettes.

## Additional checks

* `devtools::spell_check()`: no misspellings found beyond proper nouns and
  domain-specific terms (e.g., COinS, OpenURL, Zotero, RStudio).
* `urlchecker::url_check()`: all URLs resolve without redirects or errors.

## Downstream dependencies

There are currently no downstream dependencies for this package (new submission).
