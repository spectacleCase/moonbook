# 配置参考

MoonBook 从项目根目录读取 `moonbook.toml`。未知字段产生警告，格式错误和非法布尔值产生错误。

## book

```toml
[book]
title = "项目文档"
authors = ["作者 A", "作者 B"]
language = "zh-CN"
src = "src"
```

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `title` | `MoonBook` | 书籍和页面标题 |
| `authors` | `[]` | 显示在章节底部的作者列表 |
| `language` | `zh-CN` | HTML `lang` 属性 |
| `src` | `src` | `SUMMARY.md` 和章节目录 |

## build

```toml
[build]
build-dir = "book"
incremental = true
```

启用增量构建后，输出目录中的 `.moonbook-manifest` 记录输入签名。配置、目录、模板或章节变化只重新生成受影响输出；目录删除章节时会删除旧 HTML。

## output.html

```toml
[output.html]
theme = "rust"
template = "theme/page.html"
static-dir = "static"
additional-css = ["theme/custom.css"]
additional-js = ["theme/custom.js"]
```

- `theme` 支持 `light`、`rust`、`coal`；
- `template` 为空时使用内置模板；
- `static-dir` 内容复制到站点根目录，不存在时允许为空；
- 附加 CSS/JS 相对于项目根目录，并写入所有页面。

## search

```toml
[output.html.search]
enable = true
```

启用后生成 `search-index.json`，浏览器按标题、完整章节路径和正文搜索。
