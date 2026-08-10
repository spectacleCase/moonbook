# 部署指南

MoonBook 的输出是普通静态文件。运行构建后，只需发布 `book/` 目录。

## GitHub Pages

典型 CI 流程包括：

1. 安装 MoonBit 工具链；
2. 执行 `moonbook check`；
3. 执行 `moonbook build`；
4. 上传 `book/` 目录；
5. 部署到 Pages。

## 静态服务器

Nginx、Caddy、对象存储和 CDN 都可以直接托管构建结果。

| 输出 | 缓存建议 |
| --- | --- |
| HTML | 短缓存或协商缓存 |
| CSS / JS | 内容更新后刷新缓存 |
| 图片与字体 | 长缓存 |
| 搜索索引 | 与 HTML 同步更新 |

部署前建议先运行 `moonbook check`，避免上线后出现失效链接。
