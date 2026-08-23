# Create a New Quarto Blog Post

`qpost()` opens an interactive dialog for entering a post's title and
other metadata, then scaffolds the corresponding blog post file.

## Usage

``` r
qpost()
```

## Value

Nothing. What matters are the side effects:

- create a folder named with the date followed by the kebab-case post
  title

- create an `index.qmd` file

- copy the (optional) image file into the folder

- populate the YAML front matter

- open the new file in RStudio or Positron for editing

## Details

`qpost()` requires a pane-capable IDE (RStudio or Positron) because it
relies on rstudioapi to display the dialog and open the resulting file.
It cannot be used in a plain R console or non-interactive script.

## Examples

``` r
if (FALSE) { # interactive()
qpost()
}
```
