# mdBook 迁移说明

MoonBook 参考 mdBook 的工程体验，但不是逐行翻译，也不承诺完整 CLI 或插件兼容。

| mdBook 能力 | MoonBook 对应能力 |
| --- | --- |
| `book.toml` | `moonbook.toml` |
| `SUMMARY.md` | 兼容核心章节、嵌套、分组和分隔语法 |
| `mdbook init` | `moonbook init` |
| `mdbook build` | `moonbook build` |
| `mdbook serve` | `moonbook serve` |
| HTML renderer | 内置安全 Markdown 子集和模板渲染 |
| theme directory | 三套内置主题、附加资源和页面模板 |
| search | 静态 JSON 索引和浏览器端搜索 |

## 有意差异

- 不支持 mdBook 第三方预处理器和 renderer 插件协议；
- 不支持 PDF、EPUB 等输出；
- 原始 HTML 默认转义；
- 配置仅实现 MoonBook 使用的明确子集；
- 本地服务器定位为开发预览；
- MoonBit 核心 API 是一等交付物，可以不经过文件系统构建站点。

## 来源与许可证

- 参考项目：https://github.com/rust-lang/mdBook
- mdBook 许可证：Mozilla Public License 2.0
- MoonBook 许可证：Mozilla Public License 2.0

MoonBook 没有复制 Rust crate 结构，核心功能使用 MoonBit 数据模型重新实现。若未来引入上游源码或测试向量，将在对应文件中保留版权和来源说明。
