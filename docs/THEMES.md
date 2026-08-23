# 主题与模板

## 内置主题

- `light`：纸张色浅色主题；
- `rust`：暖棕色技术文档主题；
- `coal`：深灰色暗色主题。

主题只影响内置 `moonbook.css`，导航、复制按钮、提示块和移动端布局在三套主题中保持一致。

## 附加样式和脚本

通过 `additional-css`、`additional-js` 扩展主题。资源会按原路径复制到输出目录，重复构建时未变化文件不会重写。

## 自定义页面模板

模板至少必须包含 `{{content}}`，可使用以下占位符：

| 占位符 | 内容 |
| --- | --- |
| `{{language}}` | HTML 页面语言 |
| `{{page_title}}` | 当前章节标题 |
| `{{book_title}}` | 书籍标题 |
| `{{head}}` | 主题和附加 CSS |
| `{{sidebar}}` | 章节侧栏和搜索框 |
| `{{breadcrumbs}}` | 面包屑 |
| `{{toc}}` | 当前页面标题目录 |
| `{{content}}` | 渲染后的章节 HTML |
| `{{authors}}` | 作者信息 |
| `{{navigation}}` | 前后章导航 |
| `{{scripts}}` | MoonBook 和附加脚本 |

完整示例位于 `examples/advanced/theme/page.html`。
