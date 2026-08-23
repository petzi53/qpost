# Generate and append COinS metadata to a Quarto post

Automatically extracts bibliographic metadata from a Quarto post's YAML
front matter and injects it as a COinS (ContextObjects in Spans)
metadata chunk. COinS enables bibliographic tools like Zotero to detect
and import citation information from rendered HTML.

## Usage

``` r
add_coins(backup = TRUE)
```

## Arguments

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

## Examples

``` r
if (FALSE) { # \dontrun{
# From an RStudio editor with a .qmd file open:
add_coins()

# To skip backup:
add_coins(backup = FALSE)

# To manually process a file path (no RStudio required):
generate_and_append_coins("path/to/post.qmd")
} # }
```
