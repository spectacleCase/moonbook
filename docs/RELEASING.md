# 发布检查清单

## 自动验证

```bash
moon fmt
moon info
moon check --target all
moon test --target all
moon build --target native
moon run --target native cmd/main -- check examples/basic
moon run --target native cmd/main -- check examples/advanced
moon publish --dry-run
```

## 发布前检查

- `moon.mod` 与 `@moonbook.version` 版本一致；
- README、CHANGELOG 和迁移说明已更新；
- Git 工作区干净且 CI 通过；
- 两个示例可构建并可通过本地 HTTP 访问；
- 包含 MPL-2.0 LICENSE 和上游来源说明；
- 创建版本标签并发布到 mooncakes.io。

当前仓库已准备 `0.3.0` 发布材料。根据项目维护者要求，正式 mooncakes.io 发布暂缓，执行发布时不需要修改核心代码。
