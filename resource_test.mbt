///|
test "resource discovery resolves relative and root assets" {
  let assets = @moonbook.referenced_assets(
    "guide/start.md",
    (
      #|![Local](images/local.png)
      #|![Root](/logo.svg)
      #|[Download](files/demo.zip)
      #|[Chapter](next.md)
      #|[Web](https://example.com/a.png)
    ),
  )
  assert_eq(assets.length(), 3)
  assert_eq(assets[0], "guide/images/local.png")
  assert_eq(assets[1], "/logo.svg")
  assert_eq(assets[2], "guide/files/demo.zip")
}

///|
test "sections ignore title and fenced headings" {
  let sections = @moonbook.extract_sections(
    (
      #|# Page
      #|## Intro
      #|```markdown
      #|## Not a section
      #|```
      #|#### Details
    ),
  )
  assert_eq(sections.length(), 2)
  assert_eq(sections[0].id, "intro")
  assert_eq(sections[1].level, 4)
}

///|
test "search script preserves nested chapter paths" {
  assert_true(
    @moonbook.default_theme_js.contains("absolute.slice(base.length)"),
  )
}
