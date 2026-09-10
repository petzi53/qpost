# Changelog

## qpost 1.1.0

- New exported function
  [`edit_post()`](https://www.peter-baumgartner.net/qpost/reference/edit_post.md)
  for editing existing post YAML metadata via dialog
  - Pre-populates dialog with current YAML values
  - Auto-updates `date-modified` to today on every save
  - Preserves post body; only replaces YAML front matter
  - Optional `.bak` backup before modification
  - Available as RStudio/Positron addin
- Fixed critical bug: YAML rendering now correctly escapes quotation
  marks in user input
  - User intent is preserved (e.g., titles with quotes render exactly as
    typed)
  - New internal helper `escape_yaml_dq()` handles escaping
  - All text fields (title, subtitle, author, image-alt) now safe for
    special characters

## qpost 1.0.0

- Package renamed from `quartopost` to `qpost`
- Main function renamed from `quartopost()` to
  [`qpost()`](https://www.peter-baumgartner.net/qpost/reference/qpost.md)
- New exported function
  [`add_coins()`](https://www.peter-baumgartner.net/qpost/reference/add_coins.md)
  for COinS metadata generation
- [`add_coins()`](https://www.peter-baumgartner.net/qpost/reference/add_coins.md)
  gains a `file_path` argument, so it can be used outside
  RStudio/Positron by passing the target file explicitly
- All option names updated from `quartopost.*` prefix to `qpost.*`
