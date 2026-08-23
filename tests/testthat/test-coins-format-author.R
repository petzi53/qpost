# Tests for format_author() function in R/coins_generation.R

test_that("format_author handles single-word names", {
  expect_equal(qpost:::format_author("Madonna"), "Madonna")
  expect_equal(qpost:::format_author("Prince"), "Prince")
})

test_that("format_author formats two-part names as 'Last, First'", {
  expect_equal(qpost:::format_author("John Smith"), "Smith, John")
  expect_equal(qpost:::format_author("Jane Doe"), "Doe, Jane")
})

test_that("format_author formats three-part names with last name and rest", {
  expect_equal(qpost:::format_author("Johann Sebastian Bach"), "Bach, Johann Sebastian")
  expect_equal(qpost:::format_author("Jean Paul Sartre"), "Sartre, Jean Paul")
})

test_that("format_author handles multiple middle names", {
  # The function treats the last word-token as the family name
  expect_equal(
    qpost:::format_author("William Henry Gates III"),
    "III, William Henry Gates"
  )
})


# Test with list format (nested name structure) ────────────────────────────
test_that("format_author handles list with name$family and name$given", {
  author <- list(name = list(family = "Smith", given = "John"))
  expect_equal(qpost:::format_author(author), "Smith, John")
})

test_that("format_author handles list with flat family and given", {
  author <- list(family = "Doe", given = "Jane")
  expect_equal(qpost:::format_author(author), "Doe, Jane")
})

test_that("format_author handles list with only family name", {
  author <- list(name = list(family = "Madonna"))
  # When given is empty "", the function still appends ", "
  result <- qpost:::format_author(author)
  expect_match(result, "^Madonna")
})

test_that("format_author handles list with only given name", {
  author <- list(name = list(given = "Prince"))
  expect_equal(qpost:::format_author(author), "Prince")
})

test_that("format_author handles list with empty given name", {
  author <- list(name = list(family = "Smith", given = ""))
  # When given is empty, function still concatenates with ", "
  result <- qpost:::format_author(author)
  expect_match(result, "^Smith")
})

test_that("format_author handles list with empty family name", {
  author <- list(name = list(family = "", given = "John"))
  expect_equal(qpost:::format_author(author), "John")
})

test_that("format_author falls back from name$given to given", {
  author <- list(given = "Jane", name = list(family = "Doe"))
  expect_equal(qpost:::format_author(author), "Doe, Jane")
})

test_that("format_author falls back from name$family to family", {
  author <- list(family = "Smith", name = list(given = "John"))
  expect_equal(qpost:::format_author(author), "Smith, John")
})


# Test with non-character/non-list types ──────────────────────────────────
test_that("format_author coerces other types to character", {
  expect_equal(qpost:::format_author(12345), "12345")
  expect_equal(qpost:::format_author(TRUE), "TRUE")
})

test_that("format_author handles NULL gracefully", {
  # The function uses %||% for NULL handling
  author <- list(name = list(family = NULL, given = NULL))
  # Both should become empty strings via %||%
  result <- qpost:::format_author(author)
  expect_equal(result, "")
})
