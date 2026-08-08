# MoonBook

MoonBook 是一个计划使用 MoonBit 实现的 Markdown 文档站与在线书籍生成器，参考 Rust 生态的 [mdBook](https://github.com/rust-lang/mdBook)。项目希望为 MoonBit 库、工具链、教程和开源项目提供轻量、可移植的静态文档生成能力。

> 当前状态：项目仅完成申报阶段的工程初始化，文档构建功能尚未实现。通过比赛初审后再进入正式开发。

## 项目定位

MoonBook 计划读取由 Markdown 文件组成的文档目录，根据 `SUMMARY.md` 生成章节结构、导航关系和静态 HTML 页面。生成结果不依赖服务端运行环境，可以部署到 GitHub Pages、静态文件服务器或对象存储。

项目不会重新实现完整 Markdown 标准，而是优先复用 MoonBit 生态中已有的 Markdown、HTML、HTTP 和文件系统能力，重点实现文档工程组织、构建流程、主题系统、搜索索引和本地预览服务。

## 计划功能

- `moonbook init`：创建文档项目、配置文件、章节目录和示例页面；
- `moonbook build`：读取配置与章节文件，生成完整静态网站；
- `moonbook serve`：启动本地预览服务；
- 使用 `SUMMARY.md` 描述章节、分组和嵌套目录；
- 支持上一页、下一页、侧边栏、面包屑和章节锚点；
- 支持主题、附加 CSS、JavaScript 和静态资源复制；
- 生成客户端全文搜索索引；
- 检查章节路径、内部链接和资源引用；
- 支持代码块、表格、任务列表等常用 Markdown 内容；
- 提供配置解析、章节模型、构建器和渲染器的 MoonBit API；
- 提供示例文档、自动化测试、CI 和发布说明。

## 暂不包含

- PDF、EPUB 等排版输出；
- 与 mdBook 完全兼容的第三方预处理器生态；
- 在线协作编辑、账号和权限系统；
- 云端托管平台或内容管理系统。

## 当前工程

当前仓库提供可构建的 MoonBit 模块、CLI 入口、基础测试和项目申报材料。

```bash
moon check
moon test
moon run cmd/main
```

预期输出：

```text
MoonBook v0.1.0
项目骨架已初始化，文档构建功能将在项目通过初审后开发。
```

## 计划目录

```text
moonbook/
├── cmd/main/          # MoonBook CLI
├── config/            # 配置模型与解析
├── book/              # 章节、目录与文档模型
├── renderer/          # HTML 页面和主题渲染
├── search/            # 搜索索引生成
├── server/            # 本地预览服务
├── examples/          # 可实际构建的示例文档
└── PROJECT_APPLICATION.md
```

目录会随正式开发逐步建立，当前不会提前创建空包。

## 移植与许可证

- 参考项目：mdBook
- 原项目地址：https://github.com/rust-lang/mdBook
- 原项目许可证：Mozilla Public License 2.0
- 本项目许可证：Mozilla Public License 2.0

MoonBook 将采用 MoonBit 原生包结构、类型系统和测试方式重新组织实现，不复刻 Rust crate 结构。后续使用或移植上游代码时会保留必要的版权、许可证和来源说明。

## 许可证

MPL-2.0
