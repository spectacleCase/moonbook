///|
pub fn markdown(source : String) -> String {
  @moonbook.render_markdown(source)
}

///|
pub fn theme(name : String) -> String? {
  @moonbook.theme_css(name)
}

///|
pub fn themes() -> Array[String] {
  @moonbook.available_themes()
}

///|
pub let default_template : String = @moonbook.default_page_template
