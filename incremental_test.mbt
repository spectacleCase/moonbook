///|
fn incremental_sources(second : String) -> Array[@moonbook.SourceFile] {
  [
    { path: "README.md", content: "# Home\n\n## Start\n\nHello" },
    { path: "guide.md", content: second },
  ]
}

///|
test "incremental build skips every unchanged generated file" {
  let config = @moonbook.default_config("Incremental")
  let summary = "- [Home](README.md)\n- [Guide](guide.md)"
  let first = @moonbook.build_site(
    config,
    summary,
    incremental_sources("# Guide"),
  )
  match first {
    Err(error) => fail(error.to_string())
    Ok(full) => {
      let context = @moonbook.BuildContext::incremental(full.manifest)
      match
        @moonbook.build_site_with_context(
          config,
          summary,
          incremental_sources("# Guide"),
          context,
        ) {
        Err(error) => fail(error.to_string())
        Ok(next) => {
          assert_eq(next.files.length(), 0)
          assert_eq(next.skipped, 5)
        }
      }
    }
  }
}

///|
test "incremental build invalidates changed chapter and search only" {
  let config = @moonbook.default_config("Incremental")
  let summary = "- [Home](README.md)\n- [Guide](guide.md)"
  match @moonbook.build_site(config, summary, incremental_sources("# Guide")) {
    Err(error) => fail(error.to_string())
    Ok(full) =>
      match
        @moonbook.build_site_with_context(
          config,
          summary,
          incremental_sources("# Guide\n\nChanged"),
          @moonbook.BuildContext::incremental(full.manifest),
        ) {
        Err(error) => fail(error.to_string())
        Ok(next) => {
          assert_eq(next.files.length(), 2)
          assert_eq(next.skipped, 3)
        }
      }
  }
}

///|
test "custom template receives toc authors and content" {
  let config =
    #|[book]
    #|title = "Template Book"
    #|authors = ["Alice", "Bob"]
    #|
    #|[output.html]
    #|theme = "rust"
  let context = @moonbook.BuildContext::{
    previous_hashes: Map([], capacity=0),
    template: Some(
      "<html><title>{{page_title}}</title>{{toc}}<main>{{content}}</main><footer>{{authors}}</footer></html>",
    ),
    force: true,
  }
  match
    @moonbook.build_site_with_context(
      config,
      "- [Home](README.md)",
      [{ path: "README.md", content: "# Home\n\n## Details\n\nText" }],
      context,
    ) {
    Err(error) => fail(error.to_string())
    Ok(output) => {
      let mut page = ""
      for file in output.files {
        if file.path == "README.html" {
          page = file.content
        }
      }
      assert_true(page.contains("本页目录"))
      assert_true(page.contains("href=\"#details\""))
      assert_true(page.contains("Alice、Bob"))
      assert_true(page.contains("<main>"))
    }
  }
}

///|
test "theme selection and unknown theme diagnostics" {
  let themes = @moonbook.available_themes()
  assert_eq(themes.length(), 3)
  assert_eq(themes[0], "light")
  assert_eq(themes[1], "rust")
  assert_eq(themes[2], "coal")
  assert_true(
    @moonbook.theme_css("coal").unwrap().contains("color-scheme:dark"),
  )
  let config = @moonbook.default_config("Book").replace(
    old="theme = \"light\"",
    new="theme = \"missing\"",
  )
  match
    @moonbook.build_site(config, "- [Home](README.md)", [
      { path: "README.md", content: "# Home" },
    ]) {
    Err(error) => fail(error.to_string())
    Ok(output) => assert_true(output.diagnostics.length() > 0)
  }
}
