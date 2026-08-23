///|
/// Parse MoonBook configuration using defaults for omitted values.
pub fn parse(source : String) -> @moonbook.BookConfig {
  @moonbook.parse_config(source)
}

///|
/// Return structured errors and warnings for configuration input.
pub fn validate(source : String) -> Array[@moonbook.Diagnostic] {
  @moonbook.validate_config(source)
}

///|
pub fn default_text(title : String) -> String {
  @moonbook.default_config(title)
}
