///|
fn json_escape(source : String) -> String {
  let out = StringBuilder::new(size_hint=source.length())
  for i in 0..<source.length() {
    match Int::unsafe_to_char(source.code_unit_at(i).to_int()) {
      '"' => out.write_string("\\\"")
      '\\' => out.write_string("\\\\")
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      ch => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn find_source(sources : Array[SourceFile], path : String) -> String? {
  for source in sources {
    if source.path == path {
      return Some(source.content)
    }
  }
  None
}

///|
fn relative_root(path : String) -> String {
  let mut depth = 0
  for i in 0..<path.length() {
    if path.code_unit_at(i).to_int() == '/'.to_int() {
      depth += 1
    }
  }
  let out = StringBuilder::new()
  for _ in 0..<depth {
    out.write_string("../")
  }
  out.to_string()
}

///|
fn render_sidebar(
  title : String,
  items : Array[SummaryItem],
  active : String,
  root : String,
) -> String {
  let out = StringBuilder::new()
  out.write_string("<a class=\"brand\" href=\"")
  let chapters = summary_chapters(items)
  if !chapters.is_empty() {
    out.write_string(root + chapters[0].output_path)
  } else {
    out.write_string("#")
  }
  out.write_string(
    "\">\{escape_html(title)}</a><input class=\"search\" data-search placeholder=\"搜索章节…\"><ul class=\"toc\">",
  )
  for item in items {
    match item {
      Chapter(chapter) => {
        let active_class = if chapter.output_path == active {
          " class=\"active\""
        } else {
          ""
        }
        out.write_string(
          "<li data-title=\"\{escape_html(chapter.title)}\" style=\"padding-left:\{chapter.level * 14}px\"><a\{active_class} href=\"\{root}\{escape_html(chapter.output_path)}\">\{escape_html(chapter.number)} \{escape_html(chapter.title)}</a></li>",
        )
      }
      PartTitle(part) =>
        out.write_string("<li class=\"part\">\{escape_html(part)}</li>")
      Separator => out.write_string("<li><hr></li>")
    }
  }
  out.write_string("</ul>")
  out.to_string()
}

///|
fn extra_links(paths : Array[String], root : String, kind : String) -> String {
  let out = StringBuilder::new()
  for path in paths {
    if kind == "css" {
      out.write_string(
        "<link rel=\"stylesheet\" href=\"\{root}\{escape_html(path)}\">",
      )
    } else {
      out.write_string("<script src=\"\{root}\{escape_html(path)}\"></script>")
    }
  }
  out.to_string()
}

///|
fn render_page(
  config : BookConfig,
  items : Array[SummaryItem],
  chapters : Array[Chapter],
  index : Int,
  body : String,
) -> String {
  let chapter = chapters[index]
  let root = relative_root(chapter.output_path)
  let previous = if index > 0 {
    "<a rel=\"prev\" href=\"\{root}\{chapters[index - 1].output_path}\">← \{escape_html(chapters[index - 1].title)}</a>"
  } else {
    "<span></span>"
  }
  let next = if index + 1 < chapters.length() {
    "<a rel=\"next\" href=\"\{root}\{chapters[index + 1].output_path}\">\{escape_html(chapters[index + 1].title)} →</a>"
  } else {
    "<span></span>"
  }
  "<!doctype html><html lang=\"\{escape_html(config.language)}\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>\{escape_html(chapter.title)} · \{escape_html(config.title)}</title><link rel=\"stylesheet\" href=\"\{root}moonbook.css\">\{extra_links(config.additional_css, root, "css")}</head><body><div class=\"layout\"><aside class=\"sidebar\">\{render_sidebar(config.title, items, chapter.output_path, root)}</aside><main class=\"content\"><div class=\"breadcrumbs\">\{escape_html(config.title)} / \{escape_html(chapter.title)}</div><article>\{body}</article><nav class=\"chapter-nav\">\{previous}\{next}</nav></main></div><script src=\"\{root}moonbook.js\"></script>\{extra_links(config.additional_js, root, "js")}</body></html>"
}

///|
fn markdown_links(source : String) -> Array[String] {
  let links : Array[String] = []
  let mut pos = 0
  while pos < source.length() {
    let middle = find_text(source, "](", pos)
    if middle < 0 {
      break
    }
    let close = find_text(source, ")", middle + 2)
    if close < 0 {
      break
    }
    links.push(source[middle + 2:close].to_owned())
    pos = close + 1
  }
  links
}

///|
fn normalize_link(source_path : String, target : String) -> String {
  let slash = find_last_char(source_path, '/')
  let mut base = if slash >= 0 {
    source_path[0:slash + 1].to_owned()
  } else {
    ""
  }
  let mut rest = target
  while rest.has_prefix("../") {
    rest = rest[3:].to_owned()
    let clean_base = base.trim_end(chars="/").to_owned()
    let parent = find_last_char(clean_base, '/')
    base = if parent >= 0 { clean_base[0:parent + 1].to_owned() } else { "" }
  }
  base + rest.trim_start(chars="./").to_owned()
}

///|
/// Validate internal Markdown links against the declared book sources.
pub fn check_links(
  chapters : Array[Chapter],
  sources : Array[SourceFile],
) -> Array[Diagnostic] {
  let known : Map[String, Bool] = Map([], capacity=chapters.length())
  for chapter in chapters {
    known[chapter.source_path] = true
  }
  let diagnostics : Array[Diagnostic] = []
  for chapter in chapters {
    match find_source(sources, chapter.source_path) {
      None =>
        diagnostics.push({
          severity: "error",
          path: chapter.source_path,
          message: "SUMMARY.md 引用了不存在的章节",
        })
      Some(content) =>
        for link in markdown_links(content) {
          let target = link.split("#").next().unwrap_or("").to_owned()
          if target.is_empty() ||
            target.has_prefix("http://") ||
            target.has_prefix("https://") ||
            target.has_prefix("mailto:") {
            continue
          }
          if target.has_suffix(".md") {
            let normalized = normalize_link(chapter.source_path, target)
            if !known.contains(normalized) {
              diagnostics.push({
                severity: "error",
                path: chapter.source_path,
                message: "内部章节链接不存在：\{target}",
              })
            }
          }
        }
    }
  }
  diagnostics
}

///|
fn search_index(
  chapters : Array[Chapter],
  sources : Array[SourceFile],
) -> String {
  let out = StringBuilder::new()
  out.write_char('[')
  for i, chapter in chapters {
    if i > 0 {
      out.write_char(',')
    }
    let text = match find_source(sources, chapter.source_path) {
      Some(content) => plain_text(content)
      None => ""
    }
    out.write_string(
      "{\"title\":\"\{json_escape(chapter.title)}\",\"path\":\"\{json_escape(chapter.output_path)}\",\"body\":\"\{json_escape(text)}\"}",
    )
  }
  out.write_char(']')
  out.to_string()
}

///|
/// Build a complete static book from in-memory inputs.
pub fn build_site(
  config_text : String,
  summary_text : String,
  sources : Array[SourceFile],
) -> Result[BuildOutput, MoonBookError] {
  let config = parse_config(config_text)
  match parse_summary(summary_text) {
    Err(error) => Err(error)
    Ok(items) => {
      let chapters = summary_chapters(items)
      let diagnostics = check_links(chapters, sources)
      let files : Array[GeneratedFile] = [
        { path: "moonbook.css", content: default_theme_css },
        { path: "moonbook.js", content: default_theme_js },
      ]
      for i, chapter in chapters {
        match find_source(sources, chapter.source_path) {
          Some(content) =>
            files.push({
              path: chapter.output_path,
              content: render_page(
                config,
                items,
                chapters,
                i,
                render_markdown(content),
              ),
            })
          None => ()
        }
      }
      if config.search {
        files.push({
          path: "search-index.json",
          content: search_index(chapters, sources),
        })
      }
      Ok({ files, diagnostics })
    }
  }
}
