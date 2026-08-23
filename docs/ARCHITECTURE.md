# 架构与公共包

MoonBook 将纯 MoonBit 核心与 Native 平台适配分离。核心构建使用内存输入输出，可在 Wasm、Wasm-GC、JavaScript 和 Native 后端测试；文件系统和本地 socket 由 CLI 中的最小 C 绑定负责。

## 分层包

| 包 | 主要职责 |
| --- | --- |
| `spectacleCase/moonbook/config` | 配置默认值、解析和诊断 |
| `spectacleCase/moonbook/book` | `Book`、`Chapter`、`Section` 与目录 |
| `spectacleCase/moonbook/renderer` | Markdown、主题和默认模板 |
| `spectacleCase/moonbook/search` | 静态全文索引 |
| `spectacleCase/moonbook/build` | 全量/增量内存构建与清单 |

根包保留完整 API，方便小型项目直接使用，也保持早期版本兼容。

## 构建流水线

1. 解析并诊断配置；
2. 解析 `SUMMARY.md` 并建立 `Book` 和章节顺序；
3. 读取章节，检查 Markdown 链接、锚点和资源；
4. 根据 `BuildContext` 和上次清单判断是否需要渲染；
5. 渲染 Markdown、模板、导航、本页目录和作者信息；
6. 生成主题、脚本和全文搜索索引；
7. CLI 写入变化文件、复制二进制资源并移除过期页面。

## 安全边界

- 章节路径不能是绝对路径或包含 `..` 越界；
- 原始 HTML 默认转义；
- 预览服务器只监听 `127.0.0.1` 并拒绝包含 `..` 的请求；
- 本地资源在构建前校验；
- 预览服务器不是生产服务器。
