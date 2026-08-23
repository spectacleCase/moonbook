# Markdown 展示

![MoonBook 构建流程](assets/pipeline.svg)

> MoonBook 面向常见技术文档提供安全的 Markdown 子集。

| 能力 | 状态 |
| --- | --- |
| 标题锚点 | 已支持 |
| 围栏代码 | 已支持 |
| 任务列表 | 已支持 |

- [x] 编写章节
- [x] 运行检查
- [ ] 部署站点

行内支持 **粗体**、`代码` 和[内部链接](README.md)。

还支持 *斜体*、~~删除内容~~、==重点高亮== 和自动链接 <https://www.moonbitlang.com>。

## 有序步骤

1. 编写 Markdown；
2. 运行文档检查；
3. 构建静态站点；
4. 部署输出目录。

## 提示块

> [!NOTE]
> NOTE 适合补充背景信息和使用边界。

> [!TIP]
> TIP 适合给出更高效的操作方式。

> [!WARNING]
> WARNING 适合提示兼容性和潜在副作用。

> [!DANGER]
> DANGER 适合强调不可逆或高风险操作。

## 引用

> 好文档不只是 API 清单，也应该解释边界、取舍和可以运行的例子。

## MoonBit 代码

```moonbit
pub fn greeting(name : String) -> String {
  "Hello, \{name}!"
}

test "greeting" {
  assert_eq(greeting("MoonBit"), "Hello, MoonBit!")
}
```

## HTML 转义

代码块中的 `<script>` 会显示为文本，不会作为页面脚本执行。

---

需要自定义视觉效果时，可以继续阅读[配置参考](reference/config.md)。
