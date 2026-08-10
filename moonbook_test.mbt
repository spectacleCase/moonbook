///|
test "default and custom configuration" {
  let defaults = @moonbook.BookConfig::default()
  assert_eq(defaults.source_dir, "src")
  assert_true(defaults.search)
  let config = @moonbook.parse_config(
    (
      #|[book]
      #|title = "MoonBit 指南"
      #|authors = ["Alice", "Bob"]
      #|language = "zh-CN"
      #|src = "docs"
      #|
      #|[build]
      #|build-dir = "dist"
      #|incremental = false
      #|
      #|[output.html.search]
      #|enable = false
    ),
  )
  assert_eq(config.title, "MoonBit 指南")
  assert_eq(config.authors.length(), 2)
  assert_eq(config.source_dir, "docs")
  assert_eq(config.build_dir, "dist")
  assert_false(config.incremental)
  assert_false(config.search)
}

///|
test "summary supports groups, nesting, and separators" {
  let result = @moonbook.parse_summary(
    (
      #|# Summary
      #|
      #|# 入门
      #|- [介绍](README.md)
      #|  - [安装](guide/install.md)
      #|---
      #|- [附录](appendix.md)
    ),
  )
  match result {
    Ok(items) => {
      let chapters = @moonbook.summary_chapters(items)
      assert_eq(chapters.length(), 3)
      assert_eq(chapters[0].number, "1")
      assert_eq(chapters[1].number, "1.1")
      assert_eq(chapters[1].output_path, "guide/install.html")
    }
    Err(error) => fail(error.to_string())
  }
}

///|
test "summary rejects unsafe and duplicate paths" {
  assert_true(@moonbook.parse_summary("- [Bad](../secret.md)").is_err())
  assert_true(@moonbook.parse_summary("- [A](a.md)\n- [Again](a.md)").is_err())
}
