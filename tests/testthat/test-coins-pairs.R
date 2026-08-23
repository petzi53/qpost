# Tests for qpost:::build_coins_pairs() function in R/coins_generation.R

test_that("build_coins_pairs requires title and date", {
  # Missing title
  expect_error(
    qpost:::build_coins_pairs(list(date = "2026-08-22")),
    "Missing required YAML fields: title"
  )
  
  # Missing date
  expect_error(
    qpost:::build_coins_pairs(list(title = "Test Post")),
    "Missing required YAML fields: date"
  )
  
  # Missing both
  expect_error(
    qpost:::build_coins_pairs(list()),
    "Missing required YAML fields:"
  )
})

test_that("build_coins_pairs includes required COinS metadata", {
  meta <- list(
    title = "Test Post",
    date = "2026-08-22"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  
  expect_equal(unname(result["ctx_ver"]), "Z39.88-2004")
  expect_equal(unname(result["rft_val_fmt"]), "info:ofi/fmt:kev:mtx:dc")
  expect_equal(unname(result["rft.type"]), "blogPost")
  expect_equal(unname(result["rft.title"]), "Test Post")
  expect_equal(unname(result["rft.date"]), "2026")
})

test_that("build_coins_pairs extracts year from date", {
  meta <- list(
    title = "Test",
    date = "2025-12-25"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.date"]), "2025")
})

test_that("build_coins_pairs combines title and subtitle with colon", {
  meta <- list(
    title = "Main Title",
    subtitle = "Subtitle",
    date = "2026-08-22"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.title"]), "Main Title: Subtitle")
})

test_that("build_coins_pairs ignores empty subtitle", {
  meta <- list(
    title = "Main Title",
    subtitle = "",
    date = "2026-08-22"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.title"]), "Main Title")
})

test_that("build_coins_pairs includes optional blog-title", {
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    `blog-title` = "My Blog"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.source"]), "My Blog")
})

test_that("build_coins_pairs omits missing blog-title", {
  meta <- list(
    title = "Test",
    date = "2026-08-22"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  # Named vector subsetting returns NA when key doesn't exist
  expect_true(is.na(result["rft.source"]))
})

test_that("build_coins_pairs includes optional URL", {
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    url = "https://example.com/post"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft_id"]), "https://example.com/post")
})

test_that("build_coins_pairs handles lang from .Rprofile option", {
  withr::local_options(qpost.lang = "de")
  
  meta <- list(
    title = "Test",
    date = "2026-08-22"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.language"]), "de")
})

test_that("build_coins_pairs prioritizes YAML lang over option", {
  withr::local_options(qpost.lang = "de")
  
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    lang = "en"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.language"]), "en")
})

test_that("build_coins_pairs handles license from .Rprofile option", {
  withr::local_options(`qpost.license` = "CC BY-SA 4.0")
  
  meta <- list(
    title = "Test",
    date = "2026-08-22"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.rights"]), "CC BY-SA 4.0")
})

test_that("build_coins_pairs prioritizes YAML license over option", {
  withr::local_options(`qpost.license` = "CC BY-SA 4.0")
  
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    license = "CC BY 4.0"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.rights"]), "CC BY 4.0")
})

test_that("build_coins_pairs includes description", {
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    description = "A test post about something"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.description"]), "A test post about something")
})

test_that("build_coins_pairs omits empty description", {
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    description = ""
  )
  
  result <- qpost:::build_coins_pairs(meta)
  # Named vector subsetting returns NA when key doesn't exist
  expect_true(is.na(result["rft.description"]))
})

test_that("build_coins_pairs formats single author", {
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    author = "John Smith"
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.au"]), "Smith, John")
})

test_that("build_coins_pairs handles multiple authors", {
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    author = list("John Smith", "Jane Doe")
  )
  
  result <- qpost:::build_coins_pairs(meta)
  # Both authors should be in the result as rft.au
  au_values <- result[names(result) == "rft.au"]
  expect_length(au_values, 2)
  expect_true("Smith, John" %in% au_values)
  expect_true("Doe, Jane" %in% au_values)
})

test_that("build_coins_pairs handles author as list with nested name", {
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    author = list(list(name = list(family = "Smith", given = "John")))
  )
  
  result <- qpost:::build_coins_pairs(meta)
  expect_equal(unname(result["rft.au"]), "Smith, John")
})

test_that("build_coins_pairs omits NULL author", {
  meta <- list(
    title = "Test",
    date = "2026-08-22",
    author = NULL
  )
  
  result <- qpost:::build_coins_pairs(meta)
  # Named vector subsetting returns NA when key doesn't exist
  expect_true(is.na(result["rft.au"]))
})
