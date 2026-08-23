///|
fn join_path(base : String, child : String) -> String {
  if base == "." || base.is_empty() {
    child
  } else {
    base.trim_end(chars="/").to_owned() + "/" + child
  }
}

///|
fn usage() -> Unit {
  println(
    (
      #|MoonBook v\{@moonbook.version}
      #|
      #|用法：moonbook <命令> [目录] [选项]
      #|
      #|命令：
      #|  init   [目录]          初始化一本书
      #|  build  [目录]          构建静态 HTML
      #|  check  [目录]          检查目录、章节与内部链接
      #|  serve  [目录] [端口]   构建并启动预览服务器（默认 3000）
      #|
      #|选项：
      #|  -h, --help             显示帮助
      #|  -V, --version          显示版本
    ),
  )
}

///|
fn initialize(root : String) -> Bool {
  let files = [
    (
      join_path(root, "moonbook.toml"),
      @moonbook.default_config("我的 MoonBook"),
    ),
    (
      join_path(root, "src/SUMMARY.md"),
      "# Summary\n\n- [简介](README.md)\n- [开始使用](getting-started.md)\n",
    ),
    (
      join_path(root, "src/README.md"),
      "# 简介\n\n欢迎使用 **MoonBook**。\n\n前往[开始使用](getting-started.md)。\n",
    ),
    (
      join_path(root, "src/getting-started.md"),
      "# 开始使用\n\n```bash\nmoonbook build\nmoonbook serve\n```\n\n- [x] 编写目录\n- [ ] 完善内容\n",
    ),
  ]
  for path_content in files {
    let (path, content) = path_content
    if file_exists(path) {
      println("跳过已存在文件：\{path}")
    } else if write_file(path, content) < 0 {
      println("无法写入：\{path}")
      return false
    } else {
      println("创建：\{path}")
    }
  }
  true
}

///|
fn load_project(
  root : String,
) -> (String, @moonbook.BookConfig, String, Array[@moonbook.SourceFile])? {
  let config_path = join_path(root, "moonbook.toml")
  let config_text = match read_file(config_path) {
    Some(text) => text
    None => {
      println("找不到配置文件：\{config_path}")
      return None
    }
  }
  let config = @moonbook.parse_config(config_text)
  let summary_path = join_path(root, join_path(config.source_dir, "SUMMARY.md"))
  let summary = match read_file(summary_path) {
    Some(text) => text
    None => {
      println("找不到目录文件：\{summary_path}")
      return None
    }
  }
  let items = match @moonbook.parse_summary(summary) {
    Ok(value) => value
    Err(error) => {
      println(error.to_string())
      return None
    }
  }
  let sources : Array[@moonbook.SourceFile] = []
  for chapter in @moonbook.summary_chapters(items) {
    let path = join_path(
      root,
      join_path(config.source_dir, chapter.source_path),
    )
    match read_file(path) {
      Some(content) => sources.push({ path: chapter.source_path, content })
      None => ()
    }
  }
  Some((config_text, config, summary, sources))
}

///|
fn load_template(root : String, config : @moonbook.BookConfig) -> String?? {
  match config.template {
    None => Some(None)
    Some(path) =>
      match read_file(join_path(root, path)) {
        None => {
          println("模板文件不存在：\{path}")
          None
        }
        Some(template) =>
          if !template.contains("{{content}}") {
            println("模板必须包含 {{content}} 占位符：\{path}")
            None
          } else {
            Some(Some(template))
          }
      }
  }
}

///|
fn check_assets(
  root : String,
  config : @moonbook.BookConfig,
  sources : Array[@moonbook.SourceFile],
) -> Bool {
  let mut valid = true
  let seen : Map[String, Bool] = Map([], capacity=16)
  for source in sources {
    for asset in @moonbook.referenced_assets(source.path, source.content) {
      if seen.contains(asset) {
        continue
      }
      seen[asset] = true
      let path = if asset.has_prefix("/") {
        join_path(
          root,
          join_path(config.static_dir, asset.trim_start(chars="/").to_owned()),
        )
      } else {
        join_path(root, join_path(config.source_dir, asset))
      }
      if !file_exists(path) {
        println("error: \{source.path}: 静态资源不存在：\{asset}")
        valid = false
      }
    }
  }
  valid
}

///|
fn build(root : String, write : Bool) -> Bool {
  let loaded = match load_project(root) {
    Some(value) => value
    None => return false
  }
  let (config_text, config, summary, sources) = loaded
  let template = match load_template(root, config) {
    Some(value) => value
    None => return false
  }
  let manifest_path = join_path(
    root,
    join_path(config.build_dir, ".moonbook-manifest"),
  )
  let manifest = if config.incremental && write {
    read_file(manifest_path).unwrap_or("")
  } else {
    ""
  }
  let context = if config.incremental && write {
    @moonbook.BuildContext::incremental(manifest, template~)
  } else {
    @moonbook.BuildContext::{
      previous_hashes: Map([], capacity=0),
      template,
      force: true,
    }
  }
  if config.incremental && write {
    let expected : Array[String] = ["moonbook.css", "moonbook.js"]
    if config.search {
      expected.push("search-index.json")
    }
    match @moonbook.parse_summary(summary) {
      Ok(items) =>
        for chapter in @moonbook.summary_chapters(items) {
          expected.push(chapter.output_path)
        }
      Err(_) => ()
    }
    for path in expected {
      if !file_exists(join_path(root, join_path(config.build_dir, path))) {
        context.previous_hashes[path] = ""
      }
    }
  }
  let output = match
    @moonbook.build_site_with_context(config_text, summary, sources, context) {
    Ok(value) => value
    Err(error) => {
      println(error.to_string())
      return false
    }
  }
  let mut valid = true
  for diagnostic in output.diagnostics {
    println("\{diagnostic.severity}: \{diagnostic.path}: \{diagnostic.message}")
    if diagnostic.severity == "error" {
      valid = false
    }
  }
  if !check_assets(root, config, sources) {
    valid = false
  }
  if !valid || !write {
    return valid
  }
  let mut changed = 0
  for file in output.files {
    let destination = join_path(root, join_path(config.build_dir, file.path))
    let status = write_file(destination, file.content)
    if status < 0 {
      println("写入失败：\{destination}")
      valid = false
    } else if status > 0 {
      changed += 1
    }
  }
  for asset in config.additional_css + config.additional_js {
    match read_file(join_path(root, asset)) {
      Some(content) => {
        let status = write_file(
          join_path(root, join_path(config.build_dir, asset)),
          content,
        )
        if status < 0 {
          println("资源写入失败：\{asset}")
          valid = false
        } else if status > 0 {
          changed += 1
        }
      }
      None => {
        println("资源不存在：\{asset}")
        valid = false
      }
    }
  }
  let source_assets = copy_tree(
    join_path(root, config.source_dir),
    join_path(root, config.build_dir),
    true,
  )
  if source_assets < 0 {
    println("源目录静态资源复制失败")
    valid = false
  } else {
    changed += source_assets
  }
  if !config.static_dir.is_empty() {
    let static_assets = copy_tree(
      join_path(root, config.static_dir),
      join_path(root, config.build_dir),
      false,
    )
    if static_assets < 0 {
      println("静态目录复制失败：\{config.static_dir}")
      valid = false
    } else {
      changed += static_assets
    }
  }
  if valid && write_file(manifest_path, output.manifest) < 0 {
    println("增量构建清单写入失败")
    valid = false
  }
  println(
    "构建完成：\{output.files.length() + output.skipped} 个生成文件，更新 \{changed} 个，跳过渲染 \{output.skipped} 个",
  )
  valid
}

///|
fn parse_port(value : String) -> Int {
  let parsed = try @string.parse_int(value) |> Ok catch {
    _ => Err(())
  }
  match parsed {
    Ok(port) if port > 0 && port < 65536 => port
    _ => 3000
  }
}

///|
fn main {
  let args : Array[String] = @env.args()
  if args.length() < 2 || args[1] == "--help" || args[1] == "-h" {
    usage()
    return
  }
  if args[1] == "--version" || args[1] == "-V" {
    println(@moonbook.version)
    return
  }
  let command = args[1]
  let root = if args.length() > 2 { args[2] } else { "." }
  let success = match command {
    "init" => initialize(root)
    "build" => build(root, true)
    "check" => {
      let valid = build(root, false)
      if valid {
        println("检查通过")
      }
      valid
    }
    "serve" =>
      if build(root, true) {
        let config = match read_file(join_path(root, "moonbook.toml")) {
          Some(text) => @moonbook.parse_config(text)
          None => return
        }
        let port = if args.length() > 3 { parse_port(args[3]) } else { 3000 }
        println("预览地址：http://127.0.0.1:\{port}")
        if serve_directory(join_path(root, config.build_dir), port) < 0 {
          println("预览服务器启动失败，请检查端口是否可用")
          false
        } else {
          true
        }
      } else {
        false
      }
    _ => {
      println("未知命令：\{command}")
      usage()
      false
    }
  }
  if !success {
    exit_process(1)
  }
}
