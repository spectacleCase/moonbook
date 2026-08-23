///|
fn escape_html(source : String) -> String {
  let out = StringBuilder::new(size_hint=source.length())
  for i in 0..<source.length() {
    match Int::unsafe_to_char(source.code_unit_at(i).to_int()) {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&#39;")
      ch => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn slugify(title : String) -> String {
  let out = StringBuilder::new()
  let mut separator = false
  for i in 0..<title.length() {
    let ch = Int::unsafe_to_char(title.code_unit_at(i).to_int())
    if (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') || ch.to_int() > 127 {
      out.write_char(ch)
      separator = false
    } else if ch >= 'A' && ch <= 'Z' {
      out.write_char(Int::unsafe_to_char(ch.to_int() + 32))
      separator = false
    } else if !separator {
      out.write_char('-')
      separator = true
    }
  }
  out.to_string().trim(chars="-").to_owned()
}

///|
/// Extract level 2-4 headings for the page-local table of contents.
pub fn extract_sections(source : String) -> Array[Section] {
  let sections : Array[Section] = []
  let mut in_code = false
  for raw_line in source.split("\n") {
    let line = raw_line.trim().to_owned()
    if line.has_prefix("```") {
      in_code = !in_code
      continue
    }
    if in_code || !line.has_prefix("#") {
      continue
    }
    let mut level = 0
    while level < line.length() &&
          level < 6 &&
          line.code_unit_at(level).to_int() == '#'.to_int() {
      level += 1
    }
    if level >= 2 && level <= 4 {
      let title = line[level:].trim().to_owned()
      sections.push({ title, id: slugify(title), level })
    }
  }
  sections
}

///|
fn inline_markdown(source : String) -> String {
  let out = StringBuilder::new()
  let mut pos = 0
  while pos < source.length() {
    if source.code_unit_at(pos).to_int() == '`'.to_int() {
      let close = find_text(source, "`", pos + 1)
      if close > pos {
        out.write_string("<code>")
        out.write_string(escape_html(source[pos + 1:close].to_owned()))
        out.write_string("</code>")
        pos = close + 1
        continue
      }
    }
    if pos + 1 < source.length() && source[pos:pos + 2].to_owned() == "**" {
      let close = find_text(source, "**", pos + 2)
      if close > pos {
        out.write_string("<strong>")
        out.write_string(inline_markdown(source[pos + 2:close].to_owned()))
        out.write_string("</strong>")
        pos = close + 2
        continue
      }
    }
    if pos + 1 < source.length() && source[pos:pos + 2].to_owned() == "~~" {
      let close = find_text(source, "~~", pos + 2)
      if close > pos {
        out.write_string("<del>")
        out.write_string(inline_markdown(source[pos + 2:close].to_owned()))
        out.write_string("</del>")
        pos = close + 2
        continue
      }
    }
    if pos + 1 < source.length() && source[pos:pos + 2].to_owned() == "==" {
      let close = find_text(source, "==", pos + 2)
      if close > pos {
        out.write_string("<mark>")
        out.write_string(inline_markdown(source[pos + 2:close].to_owned()))
        out.write_string("</mark>")
        pos = close + 2
        continue
      }
    }
    if pos + 1 < source.length() && source[pos:pos + 2].to_owned() == "![" {
      let middle = find_text(source, "](", pos + 2)
      let close = if middle >= 0 {
        find_text(source, ")", middle + 2)
      } else {
        -1
      }
      if middle > pos && close > middle {
        let alt = source[pos + 2:middle].to_owned()
        let src = source[middle + 2:close].to_owned()
        out.write_string("<img src=\"")
        out.write_string(escape_html(src))
        out.write_string("\" alt=\"")
        out.write_string(escape_html(alt))
        out.write_string("\" loading=\"lazy\">")
        pos = close + 1
        continue
      }
    }
    if source.code_unit_at(pos).to_int() == '['.to_int() {
      let middle = find_text(source, "](", pos + 1)
      let close = if middle >= 0 {
        find_text(source, ")", middle + 2)
      } else {
        -1
      }
      if middle > pos && close > middle {
        let label = source[pos + 1:middle].to_owned()
        let href = source[middle + 2:close].to_owned()
        out.write_string("<a href=\"")
        out.write_string(escape_html(href))
        out.write_string("\">")
        out.write_string(inline_markdown(label))
        out.write_string("</a>")
        pos = close + 1
        continue
      }
    }
    if source.code_unit_at(pos).to_int() == '*'.to_int() {
      let close = find_text(source, "*", pos + 1)
      if close > pos + 1 {
        out.write_string("<em>")
        out.write_string(inline_markdown(source[pos + 1:close].to_owned()))
        out.write_string("</em>")
        pos = close + 1
        continue
      }
    }
    if source.code_unit_at(pos).to_int() == '<'.to_int() {
      let close = find_text(source, ">", pos + 1)
      if close > pos {
        let url = source[pos + 1:close].to_owned()
        if url.has_prefix("https://") || url.has_prefix("http://") {
          out.write_string("<a href=\"")
          out.write_string(escape_html(url))
          out.write_string("\">")
          out.write_string(escape_html(url))
          out.write_string("</a>")
          pos = close + 1
          continue
        }
      }
    }
    let ch = Int::unsafe_to_char(source.code_unit_at(pos).to_int())
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      _ => out.write_char(ch)
    }
    pos += 1
  }
  out.to_string()
}

///|
fn ordered_item(line : String) -> String? {
  let mut pos = 0
  while pos < line.length() {
    let ch = Int::unsafe_to_char(line.code_unit_at(pos).to_int())
    if ch < '0' || ch > '9' {
      break
    }
    pos += 1
  }
  if pos > 0 &&
    pos + 1 < line.length() &&
    line.code_unit_at(pos).to_int() == '.'.to_int() &&
    line.code_unit_at(pos + 1).to_int() == ' '.to_int() {
    Some(line[pos + 2:].to_owned())
  } else {
    None
  }
}

///|
fn split_cells(line : String) -> Array[String] {
  let cells : Array[String] = []
  let clean = line.trim().trim(chars="|").to_owned()
  for cell in clean.split("|") {
    cells.push(cell.trim().to_owned())
  }
  cells
}

///|
fn is_table_rule(line : String) -> Bool {
  let cells = split_cells(line)
  if cells.is_empty() {
    return false
  }
  for cell in cells {
    let clean = cell.trim(chars=" :-").to_owned()
    if !clean.is_empty() || !cell.contains("-") {
      return false
    }
  }
  true
}

///|
fn render_table_row(out : StringBuilder, line : String, header : Bool) -> Unit {
  let tag = if header { "th" } else { "td" }
  out.write_string("<tr>")
  for cell in split_cells(line) {
    out.write_string("<\{tag}>")
    out.write_string(inline_markdown(cell))
    out.write_string("</\{tag}>")
  }
  out.write_string("</tr>\n")
}

///|
/// Render a safe, practical Markdown subset without emitting raw HTML.
pub fn render_markdown(source : String) -> String {
  let lines : Array[String] = []
  for line in source.split("\n") {
    lines.push(line.to_owned())
  }
  let out = StringBuilder::new(size_hint=source.length() + 256)
  let mut i = 0
  let mut in_code = false
  let mut code_language = ""
  let mut in_list = false
  let mut ordered_list = false
  while i < lines.length() {
    let line = lines[i]
    let trimmed = line.trim().to_owned()
    if trimmed.has_prefix("```") {
      if in_code {
        out.write_string("</code></pre>\n")
        in_code = false
      } else {
        if in_list {
          out.write_string(if ordered_list { "</ol>\n" } else { "</ul>\n" })
          in_list = false
        }
        code_language = trimmed[3:].trim().to_owned()
        out.write_string("<pre><code")
        if !code_language.is_empty() {
          out.write_string(" class=\"language-\{escape_html(code_language)}\"")
        }
        out.write_string(">")
        in_code = true
      }
      i += 1
      continue
    }
    if in_code {
      out.write_string(escape_html(line))
      out.write_char('\n')
      i += 1
      continue
    }
    if i + 1 < lines.length() &&
      trimmed.contains("|") &&
      is_table_rule(lines[i + 1]) {
      if in_list {
        out.write_string(if ordered_list { "</ol>\n" } else { "</ul>\n" })
        in_list = false
      }
      out.write_string("<div class=\"table-wrap\"><table><thead>")
      render_table_row(out, line, true)
      out.write_string("</thead><tbody>\n")
      i += 2
      while i < lines.length() &&
            lines[i].contains("|") &&
            !lines[i].trim().is_empty() {
        render_table_row(out, lines[i], false)
        i += 1
      }
      out.write_string("</tbody></table></div>\n")
      continue
    }
    let numbered = ordered_item(trimmed)
    let unordered = trimmed.has_prefix("- ") || trimmed.has_prefix("* ")
    if unordered || numbered is Some(_) {
      let wants_ordered = numbered is Some(_)
      if in_list && wants_ordered != ordered_list {
        out.write_string(if ordered_list { "</ol>\n" } else { "</ul>\n" })
        in_list = false
      }
      if !in_list {
        ordered_list = wants_ordered
        out.write_string(if ordered_list { "<ol>\n" } else { "<ul>\n" })
        in_list = true
      }
      let mut item = match numbered {
        Some(content) => content
        None => trimmed[2:].to_owned()
      }
      let mut checkbox = ""
      if item.has_prefix("[ ] ") {
        checkbox = "<input type=\"checkbox\" disabled> "
        item = item[4:].to_owned()
      } else if item.has_prefix("[x] ") || item.has_prefix("[X] ") {
        checkbox = "<input type=\"checkbox\" checked disabled> "
        item = item[4:].to_owned()
      }
      out.write_string("<li>\{checkbox}\{inline_markdown(item)}</li>\n")
      i += 1
      continue
    }
    if in_list {
      out.write_string(if ordered_list { "</ol>\n" } else { "</ul>\n" })
      in_list = false
    }
    if trimmed.is_empty() {
      i += 1
      continue
    }
    if trimmed.has_prefix("#") {
      let mut level = 0
      while level < trimmed.length() &&
            level < 6 &&
            trimmed.code_unit_at(level).to_int() == 35 {
        level += 1
      }
      let title = trimmed[level:].trim().to_owned()
      let slug = slugify(title)
      out.write_string(
        "<h\{level} id=\"\{escape_html(slug)}\"><a class=\"anchor\" href=\"#\{escape_html(slug)}\">#</a>\{inline_markdown(title)}</h\{level}>\n",
      )
    } else if trimmed.has_prefix("> [!") && trimmed.has_suffix("]") {
      let kind = trimmed[4:trimmed.length() - 1].to_lower().to_owned()
      let title = kind.to_upper()
      out.write_string(
        "<aside class=\"callout callout-\{escape_html(kind)}\"><strong>\{escape_html(title)}</strong>",
      )
      i += 1
      while i < lines.length() && lines[i].trim().has_prefix(">") {
        let content = lines[i].trim()[1:].trim().to_owned()
        if !content.is_empty() {
          out.write_string("<p>\{inline_markdown(content)}</p>")
        }
        i += 1
      }
      out.write_string("</aside>\n")
      continue
    } else if trimmed.has_prefix("> ") {
      out.write_string(
        "<blockquote><p>\{inline_markdown(trimmed[2:].to_owned())}</p></blockquote>\n",
      )
    } else if trimmed == "---" || trimmed == "***" {
      out.write_string("<hr>\n")
    } else {
      out.write_string("<p>\{inline_markdown(trimmed)}</p>\n")
    }
    i += 1
  }
  if in_code {
    out.write_string("</code></pre>\n")
  }
  if in_list {
    out.write_string(if ordered_list { "</ol>\n" } else { "</ul>\n" })
  }
  out.to_string()
}

///|
fn plain_text(markdown : String) -> String {
  let out = StringBuilder::new()
  let mut space = false
  for i in 0..<markdown.length() {
    let ch = Int::unsafe_to_char(markdown.code_unit_at(i).to_int())
    if ch == '#' ||
      ch == '*' ||
      ch == '`' ||
      ch == '[' ||
      ch == ']' ||
      ch == '(' ||
      ch == ')' ||
      ch == '|' {
      if !space {
        out.write_char(' ')
        space = true
      }
    } else if ch == '\n' || ch == '\r' || ch == '\t' {
      if !space {
        out.write_char(' ')
        space = true
      }
    } else {
      out.write_char(ch)
      space = ch == ' '
    }
  }
  out.to_string().trim().to_owned()
}
