# Create a new quarto blog post

`qpost()` opens a dialog window to input title and other desired data to
create the file for the blog post.

## Usage

``` r
qpost()
```

## Value

Nothing. What matters are the side effects:

- create a folder in kebab notation with the name of date followed by
  the post title

- create a "index.qmd" file

- copy the (optional) image file into the folder

- populate the YAML field

- open the new file in RStudio for editing

## Examples

``` r
if (FALSE) { # interactive()
qpost()
}
```
