# Edit an Existing Quarto Blog Post's YAML Header

`edit_post()` opens the same interactive dialog as
[`qpost()`](https://www.peter-baumgartner.net/qpost/reference/qpost.md),
pre-populated with the metadata from an existing post. On submit it
rewrites only the YAML front matter, leaving the post body untouched.

## Usage

``` r
edit_post(file_path = NULL, backup = TRUE)
```

## Arguments

- file_path:

  Optional path to a `.qmd` file. When `NULL` (the default),
  `edit_post()` uses the file currently open in the RStudio or Positron
  editor.

- backup:

  Logical. If `TRUE` (the default), a `.bak` copy of the original file
  is created before any changes are made.

## Value

Nothing. The side effect is an updated YAML front matter in the target
`.qmd` file.

## Details

`edit_post()` requires a pane-capable IDE (RStudio or Positron) because
it relies on rstudioapi to display the dialog. It cannot be used in a
plain R console or non-interactive script.

The `date-modified` field is automatically set to today's date on every
save; all other fields reflect exactly what was entered in the dialog.

## Examples

``` r
if (FALSE) { # interactive()
edit_post()
}
```
