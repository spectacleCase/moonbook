# 配置参考

配置文件名固定为 `moonbook.toml`。

## 书籍信息

| 字段 | 默认值 | 用途 |
| --- | --- | --- |
| `title` | `MoonBook` | 页面标题与侧栏品牌 |
| `authors` | `[]` | 作者列表 |
| `language` | `zh-CN` | HTML 页面语言 |
| `src` | `src` | Markdown 源目录 |

## 输出配置

```toml
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

附加资源相对于项目根目录。构建时会复制到输出目录，并自动插入页面。
