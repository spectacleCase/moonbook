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
fn author_text(authors : Array[String]) -> String {
  let out = StringBuilder::new()
  for index, author in authors {
    if index > 0 {
      out.write_string("、")
    }
    out.write_string(author)
  }
  out.to_string()
}

///|
fn render_page_toc(sections : Array[Section]) -> String {
  if sections.is_empty() {
    return ""
  }
  let out = StringBuilder::new()
  out.write_string(
    "<nav class=\"page-toc\" aria-label=\"本页目录\"><strong>本页目录</strong><ol>",
  )
  for section in sections {
    out.write_string(
      "<li style=\"padding-left:\{(section.level - 2) * 14}px\"><a href=\"#\{escape_html(section.id)}\">\{escape_html(section.title)}</a></li>",
    )
  }
  out.write_string("</ol></nav>")
  out.to_string()
}

///|
fn apply_page_template(
  template : String,
  language : String,
  page_title : String,
  book_title : String,
  head : String,
  sidebar : String,
  breadcrumbs : String,
  toc : String,
  content : String,
  navigation : String,
  authors : String,
  scripts : String,
) -> String {
  template
  .replace(old="{{language}}", new=language)
  .replace(old="{{page_title}}", new=page_title)
  .replace(old="{{book_title}}", new=book_title)
  .replace(old="{{head}}", new=head)
  .replace(old="{{sidebar}}", new=sidebar)
  .replace(old="{{breadcrumbs}}", new=breadcrumbs)
  .replace(old="{{toc}}", new=toc)
  .replace(old="{{content}}", new=content)
  .replace(old="{{navigation}}", new=navigation)
  .replace(old="{{authors}}", new=authors)
  .replace(old="{{scripts}}", new=scripts)
}

///|
pub let default_page_template : String = "<!doctype html><html lang=\"{{language}}\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>{{page_title}} · {{book_title}}</title>{{head}}</head><body><div class=\"layout\"><aside class=\"sidebar\">{{sidebar}}</aside><main class=\"content\"><div class=\"breadcrumbs\">{{breadcrumbs}}</div>{{toc}}<article>{{content}}</article><div class=\"authors\">{{authors}}</div><nav class=\"chapter-nav\">{{navigation}}</nav></main></div>{{scripts}}</body></html>"

///|
fn render_page(
  config : BookConfig,
  items : Array[SummaryItem],
  chapters : Array[Chapter],
  index : Int,
  body : String,
  source : String,
  template : String?,
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
  let linked_body = body
    .replace(old=".md\"", new=".html\"")
    .replace(old=".md#", new=".html#")
  let authors = author_text(config.authors)
  let author_html = if authors.is_empty() {
    ""
  } else {
    "作者：\{escape_html(authors)}"
  }
  apply_page_template(
    template.unwrap_or(default_page_template),
    escape_html(config.language),
    escape_html(chapter.title),
    escape_html(config.title),
    "<link rel=\"stylesheet\" href=\"\{root}moonbook.css\">\{extra_links(config.additional_css, root, "css")}",
    render_sidebar(config.title, items, chapter.output_path, root),
    "\{escape_html(config.title)} / \{escape_html(chapter.title)}",
    render_page_toc(extract_sections(source)),
    linked_body,
    previous + next,
    author_html,
    "<script src=\"\{root}moonbook.js\"></script>\{extra_links(config.additional_js, root, "js")}",
  )
}

///|
fn markdown_links(source : String) -> Array[String] {
  let links : Array[String] = []
  let mut in_code = false
  for raw_line in source.split("\n") {
    let line = raw_line.to_owned()
    if line.trim().has_prefix("```") {
      in_code = !in_code
      continue
    }
    if in_code {
      continue
    }
    let mut pos = 0
    while pos < line.length() {
      let middle = find_text(line, "](", pos)
      if middle < 0 {
        break
      }
      let close = find_text(line, ")", middle + 2)
      if close < 0 {
        break
      }
      links.push(line[middle + 2:close].to_owned())
      pos = close + 1
    }
  }
  links
}

///|
fn target_parts(link : String) -> (String, String) {
  let hash = find_text(link, "#", 0)
  if hash < 0 {
    (link, "")
  } else {
    (link[0:hash].to_owned(), link[hash + 1:].to_owned())
  }
}

///|
fn has_heading_anchor(source : String, anchor : String) -> Bool {
  for raw_line in source.split("\n") {
    let line = raw_line.trim().to_owned()
    if line.has_prefix("#") {
      let mut level = 0
      while level < line.length() &&
            line.code_unit_at(level).to_int() == '#'.to_int() {
        level += 1
      }
      if slugify(line[level:].trim().to_owned()) == anchor {
        return true
      }
    }
  }
  false
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
/// Return local non-Markdown resources referenced by a chapter.
pub fn referenced_assets(
  source_path : String,
  content : String,
) -> Array[String] {
  let assets : Array[String] = []
  for link in markdown_links(content) {
    let (target, _) = target_parts(link)
    if target.is_empty() ||
      target.has_suffix(".md") ||
      target.has_prefix("http://") ||
      target.has_prefix("https://") ||
      target.has_prefix("mailto:") ||
      target.has_prefix("data:") {
      continue
    }
    if target.has_prefix("/") {
      assets.push(target)
    } else {
      assets.push(normalize_link(source_path, target))
    }
  }
  assets
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
          let (target, anchor) = target_parts(link)
          if target.has_prefix("http://") ||
            target.has_prefix("https://") ||
            target.has_prefix("mailto:") {
            continue
          }
          if target.is_empty() {
            if !anchor.is_empty() && !has_heading_anchor(content, anchor) {
              diagnostics.push({
                severity: "error",
                path: chapter.source_path,
                message: "当前章节锚点不存在：#\{anchor}",
              })
            }
          } else if target.has_suffix(".md") {
            let normalized = normalize_link(chapter.source_path, target)
            if !known.contains(normalized) {
              diagnostics.push({
                severity: "error",
                path: chapter.source_path,
                message: "内部章节链接不存在：\{target}",
              })
            } else if !anchor.is_empty() {
              match find_source(sources, normalized) {
                Some(target_content) if !has_heading_anchor(
                    target_content, anchor,
                  ) =>
                  diagnostics.push({
                    severity: "error",
                    path: chapter.source_path,
                    message: "章节锚点不存在：\{link}",
                  })
                _ => ()
              }
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
pub fn generate_search_index(
  chapters : Array[Chapter],
  sources : Array[SourceFile],
) -> String {
  search_index(chapters, sources)
}

///|
fn needs_generation(
  context : BuildContext,
  path : String,
  signature : String,
) -> Bool {
  if context.force {
    return true
  }
  match context.previous_hashes.get(path) {
    Some(previous) => previous != signature
    None => true
  }
}

///|
/// Build a static book and skip rendering outputs whose input signature is unchanged.
pub fn build_site_with_context(
  config_text : String,
  summary_text : String,
  sources : Array[SourceFile],
  context : BuildContext,
) -> Result[BuildOutput, MoonBookError] {
  let config = parse_config(config_text)
  match parse_summary(summary_text) {
    Err(error) => Err(error)
    Ok(items) => {
      let chapters = summary_chapters(items)
      let diagnostics = check_links(chapters, sources)
      for diagnostic in validate_config(config_text) {
        diagnostics.push(diagnostic)
      }
      let css = match theme_css(config.theme) {
        Some(value) => value
        None => {
          diagnostics.push({
            severity: "error",
            path: "moonbook.toml",
            message: "未知主题：\{config.theme}，可用主题为 light、rust、coal",
          })
          default_theme_css
        }
      }
      let files : Array[GeneratedFile] = []
      let hashes : Map[String, String] = Map([], capacity=chapters.length() + 3)
      let mut skipped = 0
      let css_hash = content_hash(css)
      hashes["moonbook.css"] = css_hash
      if needs_generation(context, "moonbook.css", css_hash) {
        files.push({ path: "moonbook.css", content: css })
      } else {
        skipped += 1
      }
      let js_hash = content_hash(default_theme_js)
      hashes["moonbook.js"] = js_hash
      if needs_generation(context, "moonbook.js", js_hash) {
        files.push({ path: "moonbook.js", content: default_theme_js })
      } else {
        skipped += 1
      }
      for i, chapter in chapters {
        match find_source(sources, chapter.source_path) {
          Some(content) => {
            let signature = content_hash(
              config_text +
              "\n" +
              summary_text +
              "\n" +
              content +
              "\n" +
              context.template.unwrap_or(""),
            )
            hashes[chapter.output_path] = signature
            if needs_generation(context, chapter.output_path, signature) {
              files.push({
                path: chapter.output_path,
                content: render_page(
                  config,
                  items,
                  chapters,
                  i,
                  render_markdown(content),
                  content,
                  context.template,
                ),
              })
            } else {
              skipped += 1
            }
          }
          None => ()
        }
      }
      if config.search {
        let index = search_index(chapters, sources)
        let index_hash = content_hash(index)
        hashes["search-index.json"] = index_hash
        if needs_generation(context, "search-index.json", index_hash) {
          files.push({ path: "search-index.json", content: index })
        } else {
          skipped += 1
        }
      }
      Ok({ files, diagnostics, skipped, manifest: render_manifest(hashes) })
    }
  }
}

///|
/// Build a complete static book from in-memory inputs.
pub fn build_site(
  config_text : String,
  summary_text : String,
  sources : Array[SourceFile],
) -> Result[BuildOutput, MoonBookError] {
  build_site_with_context(
    config_text,
    summary_text,
    sources,
    BuildContext::default(),
  )
}
