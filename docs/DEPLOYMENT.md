# 部署指南

构建结果是普通静态文件，可以部署到 GitHub Pages、对象存储、CDN、Nginx 或 Caddy。

```bash
moon run --target native cmd/main -- check docs
moon run --target native cmd/main -- build docs
```

只需要发布配置中 `build-dir` 对应的目录。`.moonbook-manifest` 用于后续增量构建，可以保留，但浏览器不会使用它。

## CI 建议

1. 固定或记录 MoonBit 工具链版本；
2. 运行 `moon check --target all` 和 `moon test --target all`；
3. 运行 `moonbook check`，依靠非零退出码阻断错误文档；
4. 构建站点并验证首页、主题和搜索索引存在；
5. 上传输出目录。

仓库中的 `.github/workflows/check.yml` 同时在 Ubuntu、macOS 和 Windows 构建 Native CLI，并在 Unix 环境构建两个示例站。
