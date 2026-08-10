# MoonBit API

MoonBook 的核心流水线使用内存输入输出，因此可以嵌入其他工具。

## Markdown 渲染

```moonbit
let html = @moonbook.render_markdown("# Hello MoonBit")
```

## 解析目录

```moonbit
match @moonbook.parse_summary(summary) {
  Ok(items) => println("目录有效：\{items.length()} 项")
  Err(error) => println(error.to_string())
}
```

## 构建站点

```moonbit
let sources = [
  @moonbook.SourceFile::{
    path: "README.md",
    content: "# 首页",
  },
]

let result = @moonbook.build_site(config, summary, sources)
```

返回的 `BuildOutput` 包含生成文件和结构化诊断，调用方可以决定写入磁盘、上传对象存储或继续加工。
