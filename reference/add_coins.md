# Generate and append COinS metadata to a Quarto post

Automatically extracts bibliographic metadata from a Quarto post's YAML
front matter and injects it as a COinS (ContextObjects in Spans)
metadata chunk. COinS enables bibliographic tools like Zotero to detect
and import citation information from rendered HTML.

## Usage

``` r
add_coins(file_path = NULL, backup = TRUE)
```

## Arguments

- file_path:

  Path to the `.qmd` file to process. If `NULL` (the default), the file
  is auto-detected as described in "Determining the Target File" below.

- backup:

  Logical. Create a `.bak` backup before modifying the file (default
  `TRUE`). Recommended for peace of mind during development.

## Value

Invisibly returns the generated COinS chunk as a character string.
Messages and the chunk code are printed to the console.

## Details

### Setup

To use `add_coins()` effectively, configure your project's `.Rprofile`
(at the same level as `_quarto.yml`) with:

    options(
      qpost.lang    = "en",
      qpost.license = "CC BY 4.0"
    )

Then restart your R session. These settings provide defaults for the
`lang` and `license` fields, which can be overridden per-post.

### Auto-resolution of Metadata Fields

Four YAML fields are automatically resolved in this priority order:

1.  Value in the document's YAML header (if present and non-empty)

2.  Derived from `_quarto.yml` (`blog-title` and `url` only)

3.  From `.Rprofile` options (`lang` and `license` only)

4.  Omitted if not found anywhere

The required fields `title` and `date` must be present in the YAML
header.

### Generated Output

The function appends a fenced R code cell (`{r}` block) with output
rendered as a hidden `<span class="Z3988">` containing the COinS query
string. This metadata is machine-readable but invisible in the browser.

If a COinS chunk already exists (detected by the label `coins-code`),
the user is prompted to confirm overwrite, and a `.bak` backup is
created.

### Determining the Target File

`file_path` is resolved in this order:

1.  The `file_path` argument, if supplied.

2.  The active document in RStudio or Positron, via `rstudioapi`.

3.  An interactive file picker
    ([`file.choose()`](https://rdrr.io/r/base/file.choose.html)) in
    other interactive R sessions (e.g. a plain R console).

4.  Otherwise, the function stops with a message asking for `file_path`
    to be supplied directly.

## Examples

``` r
# \donttest{
# Create a minimal Quarto project in a temporary directory
tmp <- tempdir()
writeLines(
  c("project:", "  type: website", "website:", "  title: My Blog",
    "  site-url: https://example.com"),
  file.path(tmp, "_quarto.yml")
)
post_file <- file.path(tmp, "index.qmd")
writeLines(
  c("---", "title: Test Post", "date: 2026-01-01", "---", "", "Content."),
  post_file
)
add_coins(file_path = post_file, backup = FALSE)
#> Processing: /tmp/RtmpBUkOLc/index.qmd
#> COinS chunk appended to:  /tmp/RtmpBUkOLc/index.qmd
#> 
#> ── Generated COinS chunk ───────────────────────────────────────────────────
#> ```{r}
#> #| label: coins-code
#> #| results: asis
#> #| echo: false
#> 
#> coins_metadata <- "title='ctx_ver=Z39.88-2004&rft_val_fmt=info%3aofi%2ffmt%3akev%3amtx%3adc&rft.type=blogPost&rft.title=Test%20Post&rft.date=2026&rft.source=My%20Blog&rft_id=https://example.com/index'"
#> 
#> coins_html <- paste0('<span class="Z3988" ', coins_metadata, '></span>')
#> 
#> cat(coins_html)
#> ```
#> ────────────────────────────────────────────────────────────────────────
# }

if (FALSE) { # \dontrun{
# From an RStudio or Positron editor with a .qmd file open:
add_coins()

# To skip backup:
add_coins(backup = FALSE)

# To process a file directly (no IDE required):
add_coins(file_path = "path/to/post.qmd")
} # }
```
