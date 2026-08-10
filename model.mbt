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
    additional_css: [],
    additional_js: [],
    search: true,
    incremental: true,
  }
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
