# 目录与构建

`SUMMARY.md` 决定章节顺序和嵌套关系。

## 嵌套章节

使用两个空格缩进子章节：

```markdown
# Summary

# 基础
- [欢迎](README.md)
  - [安装](guide/install.md)
---
- [附录](appendix.md)
```

分组标题只负责组织侧栏，不会生成页面。分隔线可用于区分正文与附录。

## 构建过程

```bash
moon run --target native cmd/main -- check examples/basic
moon run --target native cmd/main -- build examples/basic
```

构建器依次执行：

1. 解析 `moonbook.toml`；
2. 校验 `SUMMARY.md` 和章节路径；
3. 检查内部链接与标题锚点；
4. 渲染 Markdown 和页面导航；
5. 生成主题资源与搜索索引；
6. 只写入内容发生变化的文件。

返回[欢迎页](../README.md)。
