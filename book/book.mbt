///|
pub fn parse(
  config : String,
  summary : String,
) -> Result[@moonbook.Book, @moonbook.MoonBookError] {
  @moonbook.parse_book(config, summary)
}

///|
pub fn parse_summary(
  source : String,
) -> Result[Array[@moonbook.SummaryItem], @moonbook.MoonBookError] {
  @moonbook.parse_summary(source)
}

///|
pub fn chapters(
  items : Array[@moonbook.SummaryItem],
) -> Array[@moonbook.Chapter] {
  @moonbook.summary_chapters(items)
}

///|
pub fn sections(markdown : String) -> Array[@moonbook.Section] {
  @moonbook.extract_sections(markdown)
}
