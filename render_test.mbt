///|
test "markdown renders common book constructs safely" {
  let html = @moonbook.render_markdown(
    (
      #|# Hello MoonBit
      #|
      #|A **bold** [link](guide.md) and `code`.
      #|
      #|- [x] shipped
      #|- [ ] documented
      #|
      #|| Name | State |
      #|| --- | --- |
      #|| MoonBook | ready |
      #|
      #|```mbt
      #|let html = "<unsafe>"
      #|```
    ),
  )
  assert_true(html.contains("id=\"hello-moonbit\""))
  assert_true(html.contains("<strong>bold</strong>"))
  assert_true(html.contains("type=\"checkbox\" checked"))
  assert_true(html.contains("<table>"))
  assert_true(html.contains("&lt;unsafe&gt;"))
  assert_false(html.contains("<unsafe>"))
}

///|
test "site build emits pages, navigation, assets, and search" {
  let sources = [
    @moonbook.SourceFile::{
      path: "README.md",
      content: "# 首页\n\n前往[安装](guide/install.md)。",
    },
    @moonbook.SourceFile::{
      path: "guide/install.md",
      content: "# 安装\n\n返回[首页](../README.md)。",
    },
  ]
  match
    @moonbook.build_site(
      @moonbook.default_config("测试书籍"),
      "- [首页](README.md)\n  - [安装](guide/install.md)",
      sources,
    ) {
    Err(error) => fail(error.to_string())
    Ok(output) => {
      assert_eq(output.diagnostics.length(), 0)
      assert_eq(output.files.length(), 5)
      let mut install : @moonbook.GeneratedFile? = None
      for file in output.files {
        if file.path == "guide/install.html" {
          install = Some(file)
        }
      }
      match install {
        Some(file) => {
          assert_true(file.content.contains("href=\"../moonbook.css\""))
          assert_true(file.content.contains("测试书籍"))
          assert_true(file.content.contains("← 首页"))
        }
        None => fail("missing generated install page")
      }
    }
  }
}

///|
test "site build reports missing sources and links" {
  let sources = [
    @moonbook.SourceFile::{
      path: "README.md",
      content: "[missing](missing.md)",
    },
  ]
  match
    @moonbook.build_site(
      @moonbook.default_config("Broken"),
      "- [Home](README.md)\n- [Absent](absent.md)",
      sources,
    ) {
    Err(error) => fail(error.to_string())
    Ok(output) => assert_eq(output.diagnostics.length(), 2)
  }
}
