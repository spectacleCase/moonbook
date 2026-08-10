# 快速开始

## 1. 初始化项目

```bash
moon run --target native cmd/main -- init my-book
```

MoonBook 会创建配置、目录和两个示例章节，而且不会覆盖已有文件。

## 2. 编写内容

打开 `my-book/src/README.md`：

```markdown
# 我的第一本书

这里可以编写 **Markdown** 内容。
```

## 3. 检查并构建

```bash
moon run --target native cmd/main -- check my-book
moon run --target native cmd/main -- build my-book
```

- [x] 初始化目录
- [x] 编写首页
- [x] 检查内部链接
- [ ] 部署到静态托管平台

下一步了解[目录与构建](build.md)。
