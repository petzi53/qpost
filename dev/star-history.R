# GitHub star history investigation
#
# The /stargazers/history endpoint works with a fine-grained
# GitHub personal access token (PAT).
#
# Required token permission:
#   Repository permissions -> Metadata -> Read-only
#
# The PAT is stored in .Renviron as GITHUB_PAT.
# Never store the actual token in this script.
#
# Initial investigation on 2026-09-30:
# qpost had 11 stars.
# GitHub returned 30 weeks of history (2026-03-08 to 2026-09-27).
# All weekly totals were 0, so no new stars were received during
# this period, including after the qpost 1.1.0 release.
#
# TODO:
# - convert response to a tidy data frame
# - include daily dates/counts
# - create a useful table/plot
# - possibly generalize this for other repositories


# Build request -----------------------------------------------------------

req <- httr2::request(
    "https://api.github.com/repos/petzi53/qpost/stargazers/history"
)

req <- httr2::req_auth_bearer_token(
    req,
    Sys.getenv("GITHUB_PAT")
)


# Perform request ---------------------------------------------------------

resp <- httr2::req_perform(req)


# Parse response ----------------------------------------------------------

stars <- httr2::resp_body_json(resp)


# Inspect current history -------------------------------------------------

str(stars)

as.POSIXct(
    stars[[1]]$week,
    origin = "1970-01-01",
    tz = "UTC"
)

as.POSIXct(
    stars[[length(stars)]]$week,
    origin = "1970-01-01",
    tz = "UTC"
)

vapply(
    stars,
    function(x) x$total,
    integer(1)
)
