# 命令行工具

## init

初始化新书籍，不覆盖已经存在的文件。

```bash
moonbook init docs
```

## check

检查目录、缺失章节、内部链接和标题锚点，但不写入文件。

```bash
moonbook check docs
```

## build

生成 HTML、CSS、JavaScript 和 `search-index.json`。

```bash
moonbook build docs
```

## serve

在本机启动开发预览服务器：

```bash
moonbook serve docs 3000
```

> 预览服务器只监听 `127.0.0.1`，定位是本地开发工具，而不是生产服务器。
