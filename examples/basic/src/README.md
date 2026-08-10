# 欢迎使用 MoonBook

MoonBook 把一组 Markdown 文件转换成可以独立部署的文档网站。它专为 MoonBit 项目、教程、课程和开源库文档设计。

> 这是一个功能展示站。左侧目录、前后章导航、全文搜索和页面锚点都由 MoonBook 自动生成。

## 从这里开始

- 用 3 分钟完成[快速开始](guide/quick-start.md)；
- 了解如何组织[目录与构建](guide/build.md)；
- 查看完整的[Markdown 展示](syntax.md)；
- 准备好后把站点[部署](deployment.md)。

## 为什么选择 MoonBook

| 特性 | 说明 |
| --- | --- |
| MoonBit 原生 | 配置、解析、检查与渲染核心使用 MoonBit 实现 |
| 静态输出 | 不需要数据库或线上运行时 |
| 开发体验 | 提供初始化、检查、构建和本地预览命令 |
| 安全路径 | 拒绝越界章节路径并转义原始 HTML |
| 可维护 | 内存构建 API 可独立测试并支持四种后端 |

## 一个最小示例

```markdown
# Summary

- [简介](README.md)
- [安装](install.md)
```

运行 `moonbook build` 后，就会得到带导航和搜索的静态网站。
