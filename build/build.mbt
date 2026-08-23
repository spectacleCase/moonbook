///|
pub fn all(
  config : String,
  summary : String,
  sources : Array[@moonbook.SourceFile],
) -> Result[@moonbook.BuildOutput, @moonbook.MoonBookError] {
  @moonbook.build_site(config, summary, sources)
}

///|
pub fn incremental(
  config : String,
  summary : String,
  sources : Array[@moonbook.SourceFile],
  context : @moonbook.BuildContext,
) -> Result[@moonbook.BuildOutput, @moonbook.MoonBookError] {
  @moonbook.build_site_with_context(config, summary, sources, context)
}

///|
pub fn parse_manifest(source : String) -> Map[String, String] {
  @moonbook.parse_manifest(source)
}
