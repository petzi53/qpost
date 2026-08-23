# Adding COinS Metadata for Zotero

## What is COinS?

**COinS** stands for **ContextObjects in Spans**. It’s a simple,
standardized way to embed bibliographic metadata directly into HTML
pages so that specialized software can read and extract it.

Think of it like this: when you visit a website, humans see the text and
can understand what a blog post is about. But reference managers like
Zotero need machine-readable metadata to know the title, author,
publication date, and other citation details without requiring manual
data entry.

COinS solves this by embedding bibliographic information in an invisible
HTML `<span>` element on your page. When Zotero visits your blog post,
it detects the COinS metadata and can automatically add the post to your
library with all the correct fields filled in.

------------------------------------------------------------------------

## Why Use COinS?

### The Problem

Without COinS, Zotero has to guess your post’s metadata by examining the
HTML structure. This often fails for blog posts because:

- Blog post titles might be in an `<h1>` tag, but so might many other
  things
- The publication date might be hidden in an obscure `<time>` element or
  embedded in a longer text string
- Authors are rarely marked up consistently across different blog
  platforms
- Categories or tags have no standard HTML representation

### The Solution

COinS eliminates guessing. When you add a COinS span to your post,
Zotero can:

1.  **Automatically detect the post’s metadata** — no manual entry
    needed
2.  **Save the post to your personal library** — with correct author,
    date, title, and keywords
3.  **Use correct citation formatting** — because Zotero knows the post
    is a blog article, not a book or journal article
4.  **Reference it in your writing** — Zotero generates correct
    citations in your preferred style (Chicago, APA, etc.)

This is especially valuable for academic writers who rely on reference
managers for literature management.

------------------------------------------------------------------------

## The Standard Behind COinS

COinS is based on the **OpenURL** standard (ANSI/NISO Z39.88-2004),
which was originally designed to help libraries link users to full-text
content. The “ContextObject” is the standardized metadata package at the
heart of OpenURL.

The clever part of COinS is that it **embeds an OpenURL ContextObject
invisibly in HTML** using a `<span>` element:

``` html
<span class="Z3988" title="ctx_ver=Z39.88-2004&rft.title=...&rft.au=..."></span>
```

The `class="Z3988"` tells processors like Zotero that this span contains
COinS metadata. The actual data is in the `title` attribute (which is
counterintuitive—it’s not displayed as a tooltip; it’s just a container
for the encoded metadata).

### Why a span?

Using a `<span>` allows COinS metadata to be placed anywhere in a web
page without breaking the HTML structure or being visible to human
readers. Other approaches (like storing metadata in `<meta>` tags in the
page’s `<head>`) are more restrictive—you can only have one set of
metadata per page. With COinS, you can embed metadata for multiple items
on the same page.

------------------------------------------------------------------------

## Websites Using COinS

COinS has been adopted by many major platforms and content providers:

- **Wikipedia** — embedded in citation templates and bibliographic data
- **Academic repositories** — CiteULike, Citebase, Hubmed, ResearchGate
- **Library catalogs** — Copac, WorldCat, VuFind
- **Publishing platforms** — WordPress blogs, Institutional repositories
- **Specialized services** — Zotero itself can generate COinS for shared
  bibliographies

------------------------------------------------------------------------

## How Zotero Uses COinS

When you’re browsing a blog post with COinS in your Zotero-enabled
browser:

1.  Zotero’s browser extension scans the page and finds the
    `<span class="Z3988">` element
2.  It decodes the embedded metadata
3.  It displays a **save icon** (📖) in your browser address bar,
    indicating that Zotero can capture the page
4.  You click the icon to save the post to your library
5.  Zotero populates the entry with all the metadata from COinS: title,
    author, date, description, etc.

Without COinS, Zotero might not recognize the page as a citable item,
and you’d have to manually enter all the metadata.

------------------------------------------------------------------------

## How to Use add_coins()

The
[`add_coins()`](https://petzi53.github.io/qpost/reference/add_coins.md)
function automates the entire process.

### Prerequisites

- A completed Quarto blog post in `posts/your-post/index.qmd`
- A `_quarto.yml` file in your blog’s root directory with at least
  `site-url:` specified

### Basic Usage

``` r

library(qpost)

# Add COinS to the currently open post in RStudio
add_coins()

# Or specify a file path explicitly
add_coins(file_path = "posts/my-post/index.qmd")
```

### What Happens

When you call
[`add_coins()`](https://petzi53.github.io/qpost/reference/add_coins.md),
it:

1.  **Reads your post’s YAML** — extracts title, author, date,
    categories, description
2.  **Queries `_quarto.yml`** — reads site URL and language settings
3.  **Applies auto-resolution** — fills gaps from `_quarto.yml` and
    `.Rprofile` options
4.  **Generates COinS metadata** — creates key-value pairs (title,
    author, date, language, license, etc.)
5.  **Appends a hidden R code chunk** to render the COinS `<span>` at
    the end of your post
6.  **Opens the edited file** — so you can review and commit

### What Gets Generated

At the bottom of your `index.qmd`,
[`add_coins()`](https://petzi53.github.io/qpost/reference/add_coins.md)
appends:

This code: - Uses an R chunk with `echo: false` and `results: asis` so
it’s invisible to readers - Outputs the COinS `<span>` as raw HTML - Is
placed **at the end** of your post, so Zotero sees the complete content
first

## Configuration

By default,
[`add_coins()`](https://petzi53.github.io/qpost/reference/add_coins.md)
reads everything it needs from your post YAML and `_quarto.yml`. You
only need to configure `.Rprofile` for optional fallback values:

``` r

# Project-level .Rprofile (in your blog's root directory)
options(
  qpost.lang = "en",           # Fallback language if not in post or _quarto.yml
  qpost.license = "CC-BY-4.0"  # License code for all posts
)
```

### Auto-resolution Priority

For each field,
[`add_coins()`](https://petzi53.github.io/qpost/reference/add_coins.md)
looks in this order:

1.  **Post YAML** (e.g., `lang:`, `license:` in your post’s front
    matter)
2.  **`_quarto.yml`** (e.g., `lang:` in your blog config)
3.  **`.Rprofile` options** (e.g., `getOption("qpost.lang")`,
    `getOption("qpost.license")`)
4.  **Omitted** if not found anywhere

This design means: - Most of the time, you don’t need `.Rprofile` setup
— your post YAML and `_quarto.yml` suffice - Set `qpost.license` once in
`.Rprofile` to apply it to all posts automatically - Post-level values
always override defaults

------------------------------------------------------------------------

## Editing COinS After Creation

The COinS span is just an R code chunk at the end of your post. You can:

1.  **Edit it manually** — change metadata values directly in the
    `title` attribute
2.  **Regenerate it** — delete the chunk and run
    [`add_coins()`](https://petzi53.github.io/qpost/reference/add_coins.md)
    again
3.  **Remove it** — delete the chunk entirely (though this defeats the
    purpose!)

To re-run
[`add_coins()`](https://petzi53.github.io/qpost/reference/add_coins.md)
on an existing post: 1. Delete the `coins` code chunk at the bottom 2.
Run `add_coins(file_path = "posts/your-post/index.qmd")` 3. Review and
commit the changes

------------------------------------------------------------------------

## Backup Mode

By default, `add_coins(backup = TRUE)` creates a backup of your post
before modifying it:

``` r

add_coins(file_path = "posts/my-post/index.qmd", backup = TRUE)
```

This creates a file like `posts/my-post/index.qmd.bak` as a safety
measure. If something goes wrong, you can restore the original.

To disable backups:

``` r

add_coins(file_path = "posts/my-post/index.qmd", backup = FALSE)
```

------------------------------------------------------------------------

## Testing Your COinS

Once you’ve added COinS to a post, you can test it:

1.  **Render your blog** with `quarto preview` or `quarto render`
2.  **Open the post in your browser**
3.  **Install Zotero** browser extension (if you haven’t already) from
    [zotero.org](https://www.zotero.org/download/)
4.  **Click the Zotero save icon** in your browser address bar
5.  **Verify the metadata** — Zotero should pre-fill the title, author,
    date, and other fields automatically

If the save icon doesn’t appear, check that: - The HTML output contains
the COinS `<span>` (view page source in your browser) - The metadata in
the `title` attribute is properly URL-encoded - Your Zotero browser
extension is enabled

------------------------------------------------------------------------

## Integration with Academic Workflow

COinS is particularly valuable if you:

- **Write papers that cite your own blog posts** — Zotero can cite them
  with proper formatting
- **Build a personal knowledge base** — Zotero can organize your posts
  alongside other research
- **Share research** — Others can easily add your posts to their Zotero
  libraries
- **Track citations** — Zotero note-taking features work with your posts
  as regular bibliographic items

------------------------------------------------------------------------

## Further Reading

- [OpenURL Standard
  (Z39.88-2004)](https://www.niso.org/standards/standard_detail.cfm?std_id=783)
  — The official specification
- [COinS Specification (Wayback
  Archive)](https://web.archive.org/web/20161223121044/http://www.ocoins.info/)
  — Original COinS documentation
- [Zotero Browser Extension](https://www.zotero.org/download/) —
  Download and documentation
- [Zotero Support: Saving
  Items](https://www.zotero.org/support/adding_items_to_zotero) — How
  Zotero captures web content

------------------------------------------------------------------------

## See Also

- [`qpost()`](https://petzi53.github.io/qpost/reference/qpost.md) —
  Create new Quarto blog posts interactively
- [Quarto Blog
  Documentation](https://quarto.org/docs/websites/website-blog.html)
