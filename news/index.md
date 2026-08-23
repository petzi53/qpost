# Changelog

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
