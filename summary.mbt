///|
fn safe_source_path(path : String) -> Bool {
  !path.is_empty() &&
  !path.has_prefix("/") &&
  !path.has_prefix("\\") &&
  !path.contains("../") &&
  !path.contains("..\\") &&
  path != ".." &&
  path.has_suffix(".md")
}

///|
fn chapter_output_path(path : String) -> String {
  path[0:path.length() - 3].to_owned() + ".html"
}

///|
fn find_text(source : String, needle : String, start : Int) -> Int {
  if needle.is_empty() {
    return start
  }
  let mut i = start
  while i + needle.length() <= source.length() {
    let mut matches = true
    for j in 0..<needle.length() {
      if source.code_unit_at(i + j) != needle.code_unit_at(j) {
        matches = false
        break
      }
    }
    if matches {
      return i
    }
    i += 1
  }
  -1
}

///|
fn find_last_char(source : String, target : Char) -> Int {
  let mut i = source.length() - 1
  while i >= 0 {
    if source.code_unit_at(i).to_int() == target.to_int() {
      return i
    }
    i -= 1
  }
  -1
}

///|
fn parse_link(line : String) -> (String, String)? {
  let open = find_text(line, "[", 0)
  let middle = find_text(line, "](", 0)
  let close = find_last_char(line, ')')
  if open >= 0 && open < middle && middle + 2 < close {
    Some((line[open + 1:middle].to_owned(), line[middle + 2:close].to_owned()))
  } else {
    None
  }
}

///|
/// Parse an mdBook-compatible `SUMMARY.md` file.
pub fn parse_summary(
  source : String,
) -> Result[Array[SummaryItem], MoonBookError] {
  let items : Array[SummaryItem] = []
  let seen : Map[String, Bool] = Map([], capacity=16)
  let counters = [0, 0, 0, 0, 0, 0]
  let mut line_number = 0
  for raw_line in source.split("\n") {
    line_number += 1
    let trimmed = raw_line.trim().to_owned()
    if trimmed.is_empty() || trimmed == "# Summary" {
      continue
    }
    if trimmed == "---" || trimmed == "***" {
      items.push(Separator)
      continue
    }
    match parse_link(raw_line.to_owned()) {
      Some((title, path)) => {
        if !safe_source_path(path) {
          return Err({
            kind: "summary",
            line: line_number,
            message: "章节路径必须是安全的 .md 相对路径：\{path}",
          })
        }
        if seen.contains(path) {
          return Err({
            kind: "summary",
            line: line_number,
            message: "章节路径重复：\{path}",
          })
        }
        seen[path] = true
        let mut spaces = 0
        while spaces < raw_line.length() &&
              raw_line.code_unit_at(spaces).to_int() == 32 {
          spaces += 1
        }
        let level = spaces / 2
        let bounded = if level > 5 { 5 } else { level }
        counters[bounded] += 1
        for i in (bounded + 1)..<counters.length() {
          counters[i] = 0
        }
        let number = StringBuilder::new()
        let mut wrote_number = false
        for i in 0..<=bounded {
          if counters[i] > 0 {
            if wrote_number {
              number.write_char('.')
            }
            number.write_string(counters[i].to_string())
            wrote_number = true
          }
        }
        items.push(
          Chapter({
            title,
            source_path: path,
            output_path: chapter_output_path(path),
            level,
            number: number.to_string(),
          }),
        )
      }
      None =>
        if trimmed.has_prefix("#") {
          items.push(PartTitle(trimmed.trim_start(chars="# ").to_owned()))
        } else {
          return Err({
            kind: "summary",
            line: line_number,
            message: "无法识别目录项：\{trimmed}",
          })
        }
    }
  }
  if items.is_empty() {
    Err({ kind: "summary", line: 0, message: "目录中没有章节" })
  } else {
    Ok(items)
  }
}

///|
pub fn summary_chapters(items : Array[SummaryItem]) -> Array[Chapter] {
  let chapters : Array[Chapter] = []
  for item in items {
    match item {
      Chapter(chapter) => chapters.push(chapter)
      _ => ()
    }
  }
  chapters
}
