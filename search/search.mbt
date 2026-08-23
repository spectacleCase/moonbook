///|
pub fn build_index(
  chapters : Array[@moonbook.Chapter],
  sources : Array[@moonbook.SourceFile],
) -> String {
  @moonbook.generate_search_index(chapters, sources)
}
