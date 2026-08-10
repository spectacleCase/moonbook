# MoonBook

MoonBook 是一个使用 MoonBit 编写的 Markdown 文档站与在线书籍生成器，参考 [mdBook](https://github.com/rust-lang/mdBook) 的文档组织方式。它读取 `moonbook.toml` 和 `SUMMARY.md`，生成可直接部署的 HTML、CSS、JavaScript 与搜索索引。

当前版本已经提供可工作的 `init`、`build`、`check` 和 `serve` 命令，以及配置、目录、Markdown 渲染、页面生成、搜索与链接检查 API。

## 功能

- 使用 `SUMMARY.md` 管理章节、嵌套章节、分组标题和分隔项；
- 支持标题锚点、代码块、表格、任务列表、引用、图片、自动链接、有序列表、粗体、斜体、删除线、高亮与提示块；
- 生成响应式侧边栏、面包屑和前后章导航；
- 输出静态全文搜索索引，并提供章节标题即时筛选；
- 检查缺失章节、不安全路径、重复章节和内部 Markdown 链接；
- 支持附加 CSS、JavaScript 和中文内容；
- 内容未变化时跳过文件写入，提供基础增量构建；
- 提供只监听 `127.0.0.1` 的开发预览服务器。

## 快速开始

MoonBook CLI 当前使用 Native 后端：

```bash
moon run --target native cmd/main -- init my-book
moon run --target native cmd/main -- build my-book
moon run --target native cmd/main -- serve my-book 3000
```

初始化后的目录如下：

```text
my-book/
├── moonbook.toml
└── src/
    ├── SUMMARY.md
    ├── README.md
    └── getting-started.md
```

构建结果默认写入 `book/`。该目录可以直接部署到 GitHub Pages、对象存储或任意静态文件服务器。

## 命令

```text
moonbook init  [目录]          初始化书籍工程，不覆盖已有文件
moonbook build [目录]          检查并生成静态站点
moonbook check [目录]          只检查，不写入构建结果
moonbook serve [目录] [端口]   构建并启动本地预览，默认端口 3000
```

省略目录时使用当前目录。`serve` 是开发工具，不应作为生产服务器使用。

## 配置

```toml
[book]
title = "MoonBit 学习指南"
authors = ["作者"]
language = "zh-CN"
src = "src"

[build]
build-dir = "book"
incremental = true

[output.html]
theme = "light"
additional-css = ["theme/custom.css"]
additional-js = ["theme/custom.js"]

[output.html.search]
enable = true
```

附加资源路径相对于项目根目录，构建时会复制到输出目录并写入页面引用。

## 目录语法

```markdown
# Summary

# 第一部分
- [简介](README.md)
  - [安装](guide/install.md)
---
- [附录](appendix.md)
```

章节必须使用安全的 `.md` 相对路径。绝对路径、包含 `..` 越界的路径和重复路径会被拒绝。

## MoonBit API

核心逻辑不依赖文件系统，可直接从其他 MoonBit 包调用：

```moonbit nocheck
///|
let config = @moonbook.parse_config(config_text)

///|
let items = @moonbook.parse_summary(summary_text)

///|
let html = @moonbook.render_markdown("# Hello")

///|
let output = @moonbook.build_site(config_text, summary_text, sources)
```

主要公开类型包括 `BookConfig`、`Chapter`、`SummaryItem`、`SourceFile`、`GeneratedFile`、`Diagnostic` 和 `BuildOutput`。

## 开发与验证

```bash
moon fmt
moon check --target all
moon test --target all
moon build --target native
moon info
```

`examples/basic` 提供一个多层中文示例。测试覆盖配置、目录、安全路径、Markdown 转义、表格、任务列表、导航、搜索、链接诊断和内存端到端构建。

## 范围说明

MoonBook 首版面向常见技术文档，不宣称完整兼容 CommonMark 或 mdBook。暂不包含 PDF/EPUB 输出、第三方预处理器协议、在线协作和生产级 Web 服务。Markdown 原始 HTML 会被转义，以降低生成不可信文档时的风险。

## 移植与许可证

- 参考项目：mdBook
- 原项目：https://github.com/rust-lang/mdBook
- 原项目许可证：Mozilla Public License 2.0
- MoonBook 许可证：Mozilla Public License 2.0

MoonBook 使用 MoonBit 原生数据模型和测试方式重新实现核心流程，没有复制 Rust crate 结构。平台文件与 socket 操作由最小 C 绑定提供，解析、检查、构建和渲染逻辑使用 MoonBit 实现。
