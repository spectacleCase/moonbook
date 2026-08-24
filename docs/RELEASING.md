# 发布检查清单

## 自动验证

```bash
moon fmt
moon info
moon check --target all --deny-warn
moon test --target all --deny-warn
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

`spectacleCase/moonbook@0.3.0` 已于 2026-08-23 发布到 mooncakes.io。`0.3.1` 使用 MoonBit 编译器 `v0.10.9` 完成验证并于 2026-08-24 发布，服务端返回 `200 OK`。后续发布必须先按照语义化版本更新 `moon.mod` 和 `@moonbook.version`。
