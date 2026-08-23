test_that("qpost() errors when rstudioapi::isAvailable() is FALSE", {
  local_mocked_bindings(
    isAvailable = function(...) FALSE,
    .package = "rstudioapi"
  )

  expect_error(
    qpost(),
    "requires a pane-capable IDE"
  )
})
