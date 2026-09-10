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

**Changing the title**

When you modify the title in the dialog and click Done, you are asked
whether to create a new post directory for the new title:

- **Yes** — copies all files from the old post directory into a new
  directory named after the new title's kebab-case slug. The original
  directory is renamed to `_old-slug.bak/` and its `index.qmd` has
  `draft: true` set. The new file is opened in the editor automatically.

- **No** — updates only the YAML `title:` field; the directory name
  stays unchanged.

**Important:** if the post has already been published, creating a new
directory changes its URL. This will break existing links, bookmarks,
and search-engine entries pointing to the old address.

The backup directory is protected from accidental publication by two
independent mechanisms: the leading `_` in its name causes Quarto to
skip it during rendering (consistent with Quarto's own `_freeze/` and
`_site/` convention), and `draft: true` in the YAML acts as an
additional human-readable signal. To recover the old title, rename the
directory by removing the leading `_` and the `.bak` suffix.

The dialog shows a reminder in the title field as soon as it detects a
change, so you are always aware before clicking Done.

**`date-modified`**

This field is automatically set to today's date on every save.

## Examples

``` r
if (FALSE) { # interactive()
edit_post()
}
```
