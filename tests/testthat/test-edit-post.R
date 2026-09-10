# ── Helpers ──────────────────────────────────────────────────────────────────

# Minimal YAML front matter for a test post
minimal_qmd <- function(title = "Old Title", draft = FALSE) {
  paste0(
    "---\n",
    "title: \"", title, "\"\n",
    "date: \"2026-09-01\"\n",
    "draft: ", tolower(as.character(draft)), "\n",
    "---\n\n",
    "Post body.\n"
  )
}

# Build a fake posts/<date>-<slug>/index.qmd tree inside a temp dir and return
# the path to index.qmd.
make_post_dir <- function(tmp, slug = "2026-09-01-old-title",
                          title = "Old Title") {
  post_dir <- file.path(tmp, "posts", slug)
  dir.create(post_dir, recursive = TRUE)
  qmd_path <- file.path(post_dir, "index.qmd")
  writeLines(minimal_qmd(title), qmd_path)
  qmd_path
}

# Minimal get_args() return value that edit_post() expects
fake_params <- function(title, title_changed, date = "2026-09-01") {
  list(
    file_data   = list(
      title         = title,
      slug          = NA_character_,
      filename      = NA_character_,
      title_changed = title_changed
    ),
    author      = "Test Author",
    date        = date,
    image       = NULL,
    alt         = "",
    subtitle    = "",
    description = "",
    categories  = character(0),
    newcat      = ""
  )
}

# ── Tests: title_changed = FALSE (title unchanged) ───────────────────────────

test_that("title_ok() returns title_changed = FALSE when title is unchanged", {
  # We test the reactive output indirectly: when title_changed is FALSE,
  # edit_post() must NOT call yesno::yesno() at all.
  tmp <- withr::local_tempdir()
  qmd <- make_post_dir(tmp)

  call_count <- 0L
  local_mocked_bindings(isAvailable   = function(...) TRUE,  .package = "rstudioapi")
  local_mocked_bindings(documentOpen  = function(...) invisible(NULL), .package = "rstudioapi")

  # Patch working directory so relative paths resolve correctly
  withr::local_dir(tmp)

  local_mocked_bindings(
    get_args = function(...) fake_params("Old Title", title_changed = FALSE),
    .package = "qpost"
  )
  local_mocked_bindings(
    yesno = function(...) { call_count <<- call_count + 1L; FALSE },
    .package = "yesno"
  )

  edit_post(file_path = qmd, backup = FALSE)

  expect_equal(call_count, 0L,
    info = "yesno() must not be called when title has not changed")
})

# ── Tests: title_changed = TRUE (title changed) ───────────────────────────────

test_that("title_ok() returns title_changed = TRUE when title differs from default", {
  # When title_changed is TRUE, edit_post() must call yesno::yesno() exactly once.
  tmp <- withr::local_tempdir()
  qmd <- make_post_dir(tmp)

  call_count <- 0L
  local_mocked_bindings(isAvailable  = function(...) TRUE,  .package = "rstudioapi")
  local_mocked_bindings(documentOpen = function(...) invisible(NULL), .package = "rstudioapi")

  withr::local_dir(tmp)

  local_mocked_bindings(
    get_args = function(...) fake_params("New Title", title_changed = TRUE),
    .package = "qpost"
  )
  local_mocked_bindings(
    yesno = function(...) { call_count <<- call_count + 1L; FALSE },
    .package = "yesno"
  )

  edit_post(file_path = qmd, backup = FALSE)

  expect_equal(call_count, 1L,
    info = "yesno() must be called exactly once when title has changed")
})

# ── Tests: user chooses Yes — new directory created, old backed up ────────────

test_that("choosing Yes creates new directory and renames old to _slug.bak/", {
  skip_on_cran()

  tmp <- withr::local_tempdir()
  qmd <- make_post_dir(tmp)
  old_dir <- dirname(qmd)

  local_mocked_bindings(isAvailable  = function(...) TRUE,  .package = "rstudioapi")
  local_mocked_bindings(documentOpen = function(...) invisible(NULL), .package = "rstudioapi")

  withr::local_dir(tmp)

  local_mocked_bindings(
    get_args = function(...) fake_params("New Title", title_changed = TRUE),
    .package = "qpost"
  )
  local_mocked_bindings(
    yesno = function(...) TRUE,  # user says Yes
    .package = "yesno"
  )

  edit_post(file_path = qmd, backup = FALSE)

  new_dir <- file.path(tmp, "posts", "2026-09-01-new-title")
  bak_dir <- file.path(tmp, "posts", "_2026-09-01-old-title.bak")

  # New directory and its index.qmd exist
  expect_true(dir.exists(new_dir),  label = "new post directory created")
  expect_true(file.exists(file.path(new_dir, "index.qmd")),
              label = "index.qmd present in new directory")

  # Old directory has been renamed to backup
  expect_false(dir.exists(old_dir), label = "old directory no longer exists at original path")
  expect_true(dir.exists(bak_dir),  label = "backup directory exists")

  # Backup index.qmd has draft: true
  bak_content <- readLines(file.path(bak_dir, "index.qmd"))
  expect_true(any(grepl("^draft: true", bak_content)),
              label = "backup index.qmd has draft: true")
})

# ── Tests: safe fallback when new directory already exists ────────────────────

test_that("choosing Yes warns and falls back to YAML-only when new dir already exists", {
  skip_on_cran()

  tmp <- withr::local_tempdir()
  qmd <- make_post_dir(tmp)

  # Pre-create the would-be new directory to trigger the collision
  new_dir <- file.path(tmp, "posts", "2026-09-01-new-title")
  dir.create(new_dir, recursive = TRUE)

  local_mocked_bindings(isAvailable  = function(...) TRUE,  .package = "rstudioapi")
  local_mocked_bindings(documentOpen = function(...) invisible(NULL), .package = "rstudioapi")

  withr::local_dir(tmp)

  local_mocked_bindings(
    get_args = function(...) fake_params("New Title", title_changed = TRUE),
    .package = "qpost"
  )
  local_mocked_bindings(
    yesno = function(...) TRUE,  # user says Yes, but collision is detected
    .package = "yesno"
  )

  expect_warning(
    edit_post(file_path = qmd, backup = FALSE),
    "already exists"
  )

  old_dir <- dirname(qmd)
  bak_dir <- file.path(tmp, "posts", "_2026-09-01-old-title.bak")

  # Old directory must still be at its original location (no move happened)
  expect_true(dir.exists(old_dir),  label = "old directory still exists (no move)")
  expect_false(dir.exists(bak_dir), label = "backup directory was not created")

  # YAML title was still updated (fallback YAML-only path)
  content <- readLines(file.path(old_dir, "index.qmd"))
  expect_true(any(grepl("New Title", content)),
              label = "YAML title was updated despite directory collision")
})
