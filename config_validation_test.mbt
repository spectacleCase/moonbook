///|
test "configuration reports malformed and unknown values" {
  let diagnostics = @moonbook.validate_config(
    (
      #|[book]
      #|title = "Docs"
      #|unknown = true
      #|
      #|[build]
      #|incremental = maybe
      #|broken line
    ),
  )
  assert_eq(diagnostics.length(), 3)
  assert_eq(diagnostics[0].severity, "warning")
  assert_eq(diagnostics[1].severity, "error")
  assert_eq(diagnostics[2].severity, "error")
}

///|
test "configuration parses template static directory and authors" {
  let config = @moonbook.parse_config(
    (
      #|[book]
      #|authors = ["A", "B"]
      #|
      #|[output.html]
      #|theme = "coal"
      #|template = "theme/page.html"
      #|static-dir = "public"
    ),
  )
  assert_eq(config.authors.length(), 2)
  assert_eq(config.theme, "coal")
  assert_true(config.template is Some("theme/page.html"))
  assert_eq(config.static_dir, "public")
}

///|
test "book model combines configuration and summary" {
  match
    @moonbook.parse_book(
      @moonbook.default_config("Book"),
      "- [Home](README.md)",
    ) {
    Err(error) => fail(error.to_string())
    Ok(book) => {
      assert_eq(book.config.title, "Book")
      assert_eq(book.chapters.length(), 1)
      assert_eq(book.summary.length(), 1)
    }
  }
}
