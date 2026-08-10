///|
fn unquote(value : String) -> String {
  let value = value.trim().to_owned()
  if value.length() >= 2 {
    let first = value.code_unit_at(0).to_int()
    let last = value.code_unit_at(value.length() - 1).to_int()
    if (first == '"'.to_int() && last == '"'.to_int()) ||
      (first == '\''.to_int() && last == '\''.to_int()) {
      return value[1:value.length() - 1].to_owned()
    }
  }
  value
}

///|
fn parse_bool(value : String, fallback : Bool) -> Bool {
  match value.trim().to_lower() {
    "true" => true
    "false" => false
    _ => fallback
  }
}

///|
fn parse_string_array(value : String) -> Array[String] {
  let value = value.trim().to_owned()
  if value.length() < 2 || !value.has_prefix("[") || !value.has_suffix("]") {
    return []
  }
  let result : Array[String] = []
  for item in value[1:value.length() - 1].to_owned().split(",") {
    let item = unquote(item.to_owned())
    if !item.is_empty() {
      result.push(item)
    }
  }
  result
}

///|
/// Parse the practical subset of `moonbook.toml` used by MoonBook.
pub fn parse_config(source : String) -> BookConfig {
  let config = BookConfig::default()
  let mut section = ""
  for raw_line in source.split("\n") {
    let line = raw_line.trim().to_owned()
    if line.is_empty() || line.has_prefix("#") {
      continue
    }
    if line.has_prefix("[") && line.has_suffix("]") {
      section = line[1:line.length() - 1].to_owned()
      continue
    }
    let equal = find_text(line, "=", 0)
    if equal < 0 {
      continue
    }
    let key = line[0:equal].trim().to_owned()
    let value = line[equal + 1:].trim().to_owned()
    match (section, key) {
      ("book", "title") => config.title = unquote(value)
      ("book", "authors") => config.authors = parse_string_array(value)
      ("book", "language") => config.language = unquote(value)
      ("book", "src") => config.source_dir = unquote(value)
      ("build", "build-dir") => config.build_dir = unquote(value)
      ("build", "incremental") =>
        config.incremental = parse_bool(value, config.incremental)
      ("output.html", "theme") => config.theme = unquote(value)
      ("output.html", "additional-css") =>
        config.additional_css = parse_string_array(value)
      ("output.html", "additional-js") =>
        config.additional_js = parse_string_array(value)
      ("output.html.search", "enable") =>
        config.search = parse_bool(value, config.search)
      _ => ()
    }
  }
  config
}

///|
pub fn default_config(title : String) -> String {
  "[book]\ntitle = \"\{title}\"\nauthors = []\nlanguage = \"zh-CN\"\nsrc = \"src\"\n\n[build]\nbuild-dir = \"book\"\nincremental = true\n\n[output.html]\ntheme = \"light\"\nadditional-css = []\nadditional-js = []\n\n[output.html.search]\nenable = true\n"
}
