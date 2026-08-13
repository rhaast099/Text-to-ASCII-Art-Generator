# Text to ASCII Art Generator

一个完全本地运行的文字转 ASCII Art 工具，内置 328 种由 Git 管理的 FIGlet 字体，支持字体搜索、样式过滤、全字体预览、文本复制以及 TXT/PNG 导出。

## 1 功能

- 实时将输入文字转换为 ASCII Art。
- 内置 328 种 FIGlet 字体，包括 3D、Shadow、Graffiti 等样式。
- 按字体名称搜索，或按 3D、Shadow、Block、Script、Small 分类过滤。
- 使用 `Test all fonts` 一次预览全部字体。
- 单字体和全字体预览卡片均支持复制、TXT 下载和 PNG 导出。
- 完全离线运行，不会向外部服务发送输入内容。
- 默认使用端口 `4173`，端口被占用时自动尝试后续端口。

## 2 环境要求

源码运行和重新打包需要：

- Windows 10 或 Windows 11。
- Node.js 18 或更高版本。
- npm。

已经生成的独立 EXE 或移植包不要求目标机器安装 Node.js。

## 3 安装与运行

克隆仓库并安装依赖：

```powershell
git clone https://github.com/rhaast099/Text-to-ASCII-Art-Generator.git
cd Text-to-ASCII-Art-Generator
npm install
```

启动本地程序：

```powershell
npm start
```

程序会自动打开浏览器。默认地址为 `http://localhost:4173`；如果该端口已被占用，会自动切换到 `4174`、`4175` 等可用端口。

## 4 使用方法

1. 在 `Input text` 中输入文字。
2. 使用 `Search fonts` 或 `Style filter` 缩小字体范围。
3. 在 `ASCII font` 中选择字体并查看实时结果。
4. 使用 `Copy text`、`Download TXT` 或 `Export PNG` 导出当前结果。
5. 点击 `Test all fonts` 浏览全部样式，并在每张字体卡片上单独复制或导出。

FIGlet 字体主要面向 ASCII 字符。中文和部分扩展 Unicode 字符可能无法正确生成。

## 5 测试

运行自动测试：

```powershell
npm test
```

测试覆盖基础渲染、多行文本、标点、未知字符、完整字体库、字体回退和宽 3D 字体不自动换行。

## 6 打包与分发

### 6.1 图形化一键打包

双击项目根目录中的 `Build-Distribution.cmd`，然后选择：

- `Build standalone EXE`：生成可直接运行的单文件 EXE。
- `Build portable project ZIP`：生成包含 Node.js 运行时、FIGlet 字库和启动脚本的移植包。

输出文件保存在 `dist` 目录中。

### 6.2 命令行生成 EXE

```powershell
npm run package:win
```

输出文件为 `dist/ASCII-Art-Studio.exe`。

## 7 仓库内容

仓库包含完整源码、测试、依赖锁文件和一键打包脚本：

```text
app.js                       Frontend behavior
ascii.js                     Basic ASCII renderer and helpers
index.html                   Application page
server.js                    Local server and FIGlet API
styles.css                   Interface styles
fonts/                       Git-managed FIGlet .flf files
test/                        Automated tests
tools/Build-Distribution.ps1 Distribution builder
Build-Distribution.cmd       Double-click builder launcher
package.json                 npm scripts and dependencies
package-lock.json            Locked dependency versions
```

以下内容不会提交到 Git：

- `node_modules/`：可通过 `npm install` 根据锁文件恢复；程序字体已单独保存在 `fonts/` 并提交到 Git。
- `dist/`：由打包脚本生成的 EXE 和 ZIP 构建产物。

因此 GitHub 仓库直接包含全部 FIGlet 字体和完整的可重建项目，但不存储可恢复的依赖目录与二进制产物。

## 8 技术栈

- 原生 HTML、CSS 和 JavaScript。
- Node.js 本地 HTTP 服务。
- `figlet` 字体渲染库。
- `caxa` Windows 单文件打包工具。
