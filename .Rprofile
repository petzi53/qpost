# renv configuration: allow access to packages outside lockfile
options(renv.config.external.libraries = "/Users/petzi/Library/R/arm64/4.6/library")

# Load rprofile with dev = FALSE to prevent auto-loading package in dev mode
# This is critical for vignettes and help pages to work correctly from the installed copy
if (requireNamespace("rprofile", quietly = TRUE)) rprofile::load(dev = FALSE)
