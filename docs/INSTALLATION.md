# 安装与运行

## 环境要求

- MoonBit 2026 年工具链或更新版本；
- 可用的 Native C 编译环境；
- Git，仅从仓库获取源码时需要。

## 从源码运行

```bash
git clone https://github.com/spectacleCase/moonbook.git
cd moonbook
moon build --target native
moon run --target native cmd/main -- --version
```

MoonBook 核心包已经发布到 mooncakes.io：

```bash
moon add spectacleCase/moonbook@0.3.0
```

CLI 当前推荐通过仓库源码运行：

```bash
moon run --target native cmd/main -- init my-book
moon run --target native cmd/main -- check my-book
moon run --target native cmd/main -- build my-book
moon run --target native cmd/main -- serve my-book 3000
```

## 本地可执行文件

Native 构建完成后，可执行文件位于 `_build/native/debug/build/cmd/main/main.exe`。文件后缀由 MoonBit 构建系统统一使用，在 macOS 和 Linux 上同样可以运行。

## 退出状态

- 成功、帮助和版本命令返回 `0`；
- 配置、目录、链接、资源或写入错误返回非零状态；
- 因此 `moonbook check` 可以直接用于 CI 阻断发布。
