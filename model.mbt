///|
/// Current project version.
pub let version : String = "0.2.0"

///|
pub(all) struct BookConfig {
  mut title : String
  mut authors : Array[String]
  mut language : String
  mut source_dir : String
  mut build_dir : String
  mut theme : String
  mut template : String?
  mut static_dir : String
  mut additional_css : Array[String]
  mut additional_js : Array[String]
  mut search : Bool
  mut incremental : Bool
}

///|
pub fn BookConfig::default() -> BookConfig {
  {
    title: "MoonBook",
    authors: [],
    language: "zh-CN",
    source_dir: "src",
    build_dir: "book",
    theme: "light",
    template: None,
    static_dir: "static",
    additional_css: [],
    additional_js: [],
    search: true,
    incremental: true,
  }
}

///|
/// A complete parsed book ready for validation or rendering.
pub(all) struct Book {
  config : BookConfig
  summary : Array[SummaryItem]
  chapters : Array[Chapter]
}

///|
/// A heading extracted from one chapter for page-local navigation.
pub(all) struct Section {
  title : String
  id : String
  level : Int
}

///|
pub(all) struct Chapter {
  title : String
  source_path : String
  output_path : String
  level : Int
  number : String
}

///|
pub(all) enum SummaryItem {
  Chapter(Chapter)
  PartTitle(String)
  Separator
}

///|
pub(all) struct SourceFile {
  path : String
  content : String
}

///|
pub(all) struct GeneratedFile {
  path : String
  content : String
}

///|
pub(all) struct Diagnostic {
  severity : String
  path : String
  message : String
}

///|
pub(all) struct BuildOutput {
  files : Array[GeneratedFile]
  diagnostics : Array[Diagnostic]
  skipped : Int
  manifest : String
}

///|
/// Inputs controlling an incremental in-memory build.
pub(all) struct BuildContext {
  previous_hashes : Map[String, String]
  template : String?
  force : Bool
}

///|
pub fn BuildContext::default() -> BuildContext {
  { previous_hashes: Map([], capacity=0), template: None, force: true }
}

///|
pub(all) struct MoonBookError {
  kind : String
  line : Int
  message : String
}

///|
pub impl Show for MoonBookError with fn to_string(self) {
  if self.line > 0 {
    "\{self.kind} error at line \{self.line}: \{self.message}"
  } else {
    "\{self.kind} error: \{self.message}"
  }
}
