///|
/// Stable non-cryptographic fingerprint used by the incremental manifest.
pub fn content_hash(source : String) -> String {
  let mut hash = 2166136261U
  for i in 0..<source.length() {
    hash = (hash ^ source.code_unit_at(i).to_uint()) * 16777619U
  }
  hash.to_string()
}

///|
pub fn parse_manifest(source : String) -> Map[String, String] {
  let hashes : Map[String, String] = Map([], capacity=16)
  for raw_line in source.split("\n") {
    let line = raw_line.to_owned()
    let tab = find_text(line, "\t", 0)
    if tab > 0 && tab + 1 < line.length() {
      hashes[line[0:tab].to_owned()] = line[tab + 1:].to_owned()
    }
  }
  hashes
}

///|
pub fn render_manifest(hashes : Map[String, String]) -> String {
  let entries : Array[(String, String)] = []
  hashes.each(fn(path, hash) { entries.push((path, hash)) })
  entries.sort_by(fn(left, right) { left.0.compare(right.0) })
  let out = StringBuilder::new()
  for path_hash in entries {
    let (path, hash) = path_hash
    out.write_string("\{path}\t\{hash}\n")
  }
  out.to_string()
}

///|
pub fn BuildContext::incremental(
  manifest : String,
  template? : String? = None,
) -> BuildContext {
  { previous_hashes: parse_manifest(manifest), template, force: false }
}
