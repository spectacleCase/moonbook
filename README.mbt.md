# MoonBook

MoonBook 是一个使用 MoonBit 编写的 Markdown 文档站与在线书籍生成器，参考 [mdBook](https://github.com/rust-lang/mdBook) 的文档组织方式。它读取 `moonbook.toml` 和 `SUMMARY.md`，生成可直接部署的 HTML、CSS、JavaScript 与搜索索引。

当前版本提供可工作的 `init`、`build`、`check` 和 `serve` 命令，以及配置、Book 模型、Markdown 渲染、页面生成、搜索、资源检查和增量构建 API。

## 功能

- 使用 `SUMMARY.md` 管理章节、嵌套章节、分组标题和分隔项；
- 支持标题锚点、代码块、表格、任务列表、引用、图片、自动链接、有序列表、粗体、斜体、删除线、高亮与提示块；
- 生成响应式侧边栏、面包屑和前后章导航；
- 生成页面内二到四级标题目录，并在页面展示作者信息；
- 输出静态全文搜索索引，并提供章节标题即时筛选；
- 检查缺失章节、不安全路径、重复章节、锚点和静态资源；
- 提供 `light`、`rust`、`coal` 三套主题与自定义 HTML 页面模板；
- 自动复制章节资源、静态目录、附加 CSS 和 JavaScript；
- 使用构建清单跳过未变化页面，并清理不再存在的生成页面；
- 配置、Book、渲染、搜索和构建能力提供独立公共包；
- 提供只监听 `127.0.0.1` 的开发预览服务器。

## 快速开始

作为 MoonBit 库依赖安装：

```bash
moon add spectacleCase/moonbook@0.3.1
```

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
template = ""
static-dir = "static"
additional-css = ["theme/custom.css"]
additional-js = ["theme/custom.js"]

[output.html.search]
enable = true
```

附加资源路径相对于项目根目录。章节源目录内的图片等非 Markdown 文件保持目录结构复制，`static-dir` 则复制到站点根目录。

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

分层包可单独导入：

```text
spectacleCase/moonbook/config
spectacleCase/moonbook/book
spectacleCase/moonbook/renderer
spectacleCase/moonbook/search
spectacleCase/moonbook/build
```

## 开发与验证

要求 MoonBit 编译器版本不低于 `v0.10.9`。

```bash
moon fmt
moon check --target all --deny-warn
moon test --target all --deny-warn
moon build --target native
moon info
```

`examples/basic` 提供完整功能展示，`examples/advanced` 验证中文路径、深色主题、自定义模板和静态目录。测试覆盖配置诊断、目录、安全路径、Markdown、模板、主题、资源、搜索、链接与增量构建。

## 文档

- [安装与运行](docs/INSTALLATION.md)
- [配置参考](docs/CONFIGURATION.md)
- [主题与模板](docs/THEMES.md)
- [架构与公共包](docs/ARCHITECTURE.md)
- [部署指南](docs/DEPLOYMENT.md)
- [mdBook 迁移说明](docs/MIGRATION.md)
- [发布检查清单](docs/RELEASING.md)

## 范围说明

MoonBook 首版面向常见技术文档，不宣称完整兼容 CommonMark 或 mdBook。暂不包含 PDF/EPUB 输出、第三方预处理器协议、在线协作和生产级 Web 服务。Markdown 原始 HTML 会被转义，以降低生成不可信文档时的风险。

## 移植与许可证

- 参考项目：mdBook
- 原项目：https://github.com/rust-lang/mdBook
- 原项目许可证：Mozilla Public License 2.0
- MoonBook 许可证：Mozilla Public License 2.0

MoonBook 使用 MoonBit 原生数据模型和测试方式重新实现核心流程，没有复制 Rust crate 结构。平台文件与 socket 操作由最小 C 绑定提供，解析、检查、构建和渲染逻辑使用 MoonBit 实现。
