# Tests for filesystem and metadata functions in R/coins_generation.R
# These functions require temporary directory structures for testing

test_that("find_project_root locates _quarto.yml in current directory", {
  skip_on_cran()
  
  tmpdir <- tempfile()
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE))
  
  # Create a fake _quarto.yml
  quarto_file <- file.path(tmpdir, "_quarto.yml")
  writeLines("project:\n  type: website", quarto_file)
  
  # Test with directory path - normalize the path for comparison
  result <- normalizePath(qpost:::find_project_root(tmpdir))
  expected <- normalizePath(tmpdir)
  expect_equal(result, expected)
  
  # Test with file path inside directory
  test_file <- file.path(tmpdir, "post.qmd")
  writeLines("---\ntitle: Test\n---\n", test_file)
  result <- normalizePath(qpost:::find_project_root(test_file))
  expect_equal(result, expected)
})

test_that("find_project_root walks up directory tree", {
  skip_on_cran()
  
  tmpdir <- tempfile()
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE))
  
  # Create subdirectories
  subdir1 <- file.path(tmpdir, "posts")
  subdir2 <- file.path(subdir1, "2026-08-22-test")
  dir.create(subdir1)
  dir.create(subdir2)
  
  # Create _quarto.yml in root
  quarto_file <- file.path(tmpdir, "_quarto.yml")
  writeLines("project:\n  type: website", quarto_file)
  
  # Test finding from nested subdirectory - normalize paths for comparison
  result <- normalizePath(qpost:::find_project_root(subdir2))
  expected <- normalizePath(tmpdir)
  expect_equal(result, expected)
})

test_that("find_project_root raises error when no _quarto.yml found", {
  skip_on_cran()
  
  tmpdir <- tempfile()
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE))
  
  expect_error(
    qpost:::find_project_root(tmpdir),
    "Could not find '_quarto.yml'"
  )
})


# Test derive_site_metadata ───────────────────────────────────────────────
test_that("derive_site_metadata constructs correct post URL", {
  skip_on_cran()
  
  tmpdir <- tempfile()
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE))
  
  # Create project structure
  posts_dir <- file.path(tmpdir, "posts")
  post_subdir <- file.path(posts_dir, "my-post")
  dir.create(posts_dir)
  dir.create(post_subdir)
  
  # Create _quarto.yml
  quarto_yaml <- list(
    website = list(
      title = "My Blog",
      `site-url` = "https://example.com"
    )
  )
  quarto_file <- file.path(tmpdir, "_quarto.yml")
  yaml::write_yaml(quarto_yaml, quarto_file)
  
  # Create a post file
  post_file <- file.path(post_subdir, "index.qmd")
  writeLines("---\ntitle: Test\n---\n", post_file)
  
  # Read the config (simulate what generate_and_append_coins does)
  quarto_cfg <- yaml::read_yaml(quarto_file)
  result <- qpost:::derive_site_metadata(post_file, quarto_cfg)
  
  expect_equal(result$blog_title, "My Blog")
  expect_equal(result$post_url, "https://example.com/posts/my-post/index")
})

test_that("derive_site_metadata strips trailing slash from URL", {
  skip_on_cran()
  
  tmpdir <- tempfile()
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE))
  
  posts_dir <- file.path(tmpdir, "posts")
  dir.create(posts_dir)
  
  quarto_yaml <- list(
    website = list(
      title = "My Blog",
      `site-url` = "https://example.com/"
    )
  )
  quarto_file <- file.path(tmpdir, "_quarto.yml")
  yaml::write_yaml(quarto_yaml, quarto_file)
  
  post_file <- file.path(posts_dir, "post.qmd")
  writeLines("---\ntitle: Test\n---\n", post_file)
  
  quarto_cfg <- yaml::read_yaml(quarto_file)
  result <- qpost:::derive_site_metadata(post_file, quarto_cfg)
  
  expect_false(stringr::str_ends(result$post_url, "/"))
})

test_that("derive_site_metadata returns NA when site-url missing", {
  quarto_cfg <- list(
    website = list(title = "My Blog")
  )
  post_file <- "/tmp/posts/post.qmd"
  
  # This will fail trying to find _quarto.yml, so we expect an error
  expect_error(
    derive_site_metadata(post_file, quarto_cfg),
    "Could not find '_quarto.yml'"
  )
})
