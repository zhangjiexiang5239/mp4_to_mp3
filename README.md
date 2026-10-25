# MP4 批量转 MP3（Windows）

一个用于在 Windows 上批量提取 MP4 视频音频的小工具。将视频放入指定目录，双击批处理脚本，即可调用项目附带的 FFmpeg，把音频重新编码为 MP3。

## 功能

- 批量处理 `mp4` 文件夹内的 `.mp4` 文件，逐个执行转换。
- 使用 `libmp3lame` 编码器，以 `-q:a 2` 设置音频质量。
- 将结果保存到 `convert_output` 文件夹，保留原文件名，仅将扩展名改为 `.mp3`。
- 自动创建输出文件夹；不删除或修改输入视频。
- 使用脚本所在位置定位文件，不依赖运行命令时的工作目录。

## 目录结构

```text
mp4_to_mp3_win/
├── extract_mp3.bat   # 转换入口，双击运行
├── ffmpeg.zip.part-* # 分卷的 Windows 64 位 FFmpeg 压缩包
├── mp4/              # 输入目录：将待转换的 MP4 放在这里
├── convert_output/   # 输出目录：生成的 MP3 保存在这里
└── README.md
```

**注意：脚本只读取 `mp4` 文件夹内的文件。放在项目根目录或 `mp4` 子文件夹中的视频不会被处理。**

## 运行要求

- Windows 64 位系统，能够运行附带的 FFmpeg；自动解压需要 Windows PowerShell 5.0 或更高版本。
- 保持 `extract_mp3.bat` 和全部 `ffmpeg.zip.part-*` 文件（或已解压的 `ffmpeg.exe`）位于同一目录。
- 确保存在 `mp4` 输入文件夹，且输出位置有写入权限和足够空间。

无需安装 Python、Node.js，也无需单独配置 FFmpeg 的环境变量。当前提供的是 Windows 批处理脚本和 FFmpeg 压缩包，不能直接在 macOS 或 Linux 上运行。

## 获取项目

通过 Git 克隆或 GitHub 的 Download ZIP 获取项目后，确认 `ffmpeg.zip.part-00` 到 `ffmpeg.zip.part-03` 都位于 `extract_mp3.bat` 同级目录。首次运行脚本时，如果找不到 `ffmpeg.exe`，脚本会先合并分卷，再使用 Windows PowerShell 自动解压；之后会直接复用已解压的 `ffmpeg.exe`。

前三个分卷各为 20 MiB，最后一个约为 5.3 MiB，合并后的压缩包约为 65 MiB，解压后的 `ffmpeg.exe` 约为 183 MiB。自动解压失败时，可按编号顺序合并分卷后手动解压，确保 `ffmpeg.exe` 与 `extract_mp3.bat` 位于同一目录。合并后的 `ffmpeg.zip` 和解压后的 `ffmpeg.exe` 已加入 `.gitignore`，不会被重复提交。

## 快速使用

1. 将需要转换的 `.mp4` 文件放入项目下的 `mp4` 文件夹。
2. 双击 `extract_mp3.bat`。
3. 在命令窗口中查看转换日志，等待处理结束。
4. 打开 `convert_output` 文件夹，检查生成的 `.mp3` 文件。
5. 按任意键关闭脚本窗口。

例如，将 `会议记录.mp4` 放入 `mp4` 后，结果会保存为 `convert_output\会议记录.mp3`。

也可以在项目目录打开命令提示符（CMD）执行：

```bat
extract_mp3.bat
```

在 PowerShell 中执行：

```powershell
.\extract_mp3.bat
```

**同名输出文件会被直接覆盖。** 脚本使用了 FFmpeg 的 `-y` 参数，再次运行前请备份需要保留的 MP3。

## 工作原理

脚本先检查 FFmpeg 是否存在，缺失时合并分卷并解压，再检查输入目录，按需创建输出目录，然后循环调用以下命令：

```bat
"%FFMPEG_PATH%" -y -i "%%f" -vn -acodec libmp3lame -q:a 2 "%OUTPUT_DIR%\%%~nf.mp3"
```

| 参数或变量 | 作用 |
| --- | --- |
| `%FFMPEG_PATH%` | FFmpeg 可执行文件路径 |
| `-y` | 自动覆盖已有的同名输出文件 |
| `-i "%%f"` | 指定当前循环处理的视频文件 |
| `-vn` | 不输出视频流 |
| `-acodec libmp3lame` | 使用 MP3 编码器重新编码音频 |
| `-q:a 2` | 设置音频质量；脚本未指定固定码率 |
| `%%~nf` | 取得输入文件名，不包含路径和扩展名 |

脚本开头通过 `chcp 65001` 设置 UTF-8 控制台代码页，用于显示中文提示。

## 修改输入和输出目录

使用文本编辑器打开 `extract_mp3.bat`，修改以下配置：

```bat
set "SOURCE_DIR=%SCRIPT_DIR%mp4"
set "OUTPUT_DIR=%SCRIPT_DIR%convert_output"
set "FFMPEG_PATH=%SCRIPT_DIR%ffmpeg.exe"
```

其中 `%SCRIPT_DIR%` 为脚本所在目录。也可以将输入、输出目录替换为绝对路径，例如：

```bat
set "SOURCE_DIR=D:\Videos"
set "OUTPUT_DIR=D:\Audio"
```

保留原有的引号写法，以便处理带空格的路径。自定义的输入目录需要提前创建，输出目录由脚本按需创建。

## 常见问题

| 问题 | 检查方式 |
| --- | --- |
| 提示未找到 `ffmpeg.exe` 或压缩包分卷 | 确认 `ffmpeg.zip.part-00` 到 `ffmpeg.zip.part-03` 与脚本位于同一目录，或修改 `FFMPEG_PATH` 指向实际位置。 |
| 提示压缩包合并或解压失败 | 检查四个分卷是否完整、脚本目录是否可写，也可手动合并解压后重试。 |
| 提示未找到 `mp4` 输入目录 | 在脚本旁创建 `mp4` 文件夹，或修改 `SOURCE_DIR`。 |
| 视频没有被转换 | 确认文件扩展名为 `.mp4`，并直接放在输入目录中；脚本不递归扫描子目录。 |
| FFmpeg 报错或没有生成 MP3 | 查看窗口中的 FFmpeg 日志，检查视频是否有音轨、文件能否正常读取，以及输出目录是否可写。 |
| 之前的 MP3 被替换 | 当前脚本默认覆盖同名输出，需在重新运行前自行备份。 |

## 当前限制

- 仅匹配输入目录第一层的 `.mp4` 文件，未提供其他格式或子目录递归处理。
- 转换为 MP3 会重新编码音频，不是无损复制原音轨。
- 没有图形界面、命令行参数解析或转换成功/失败统计。
- 未单独处理输入目录中没有 MP4 的情况，也未逐个检查 FFmpeg 的退出状态。
- 末尾的“全部完成！”表示脚本执行到了结尾，不能据此确认每个文件都转换成功；请结合 FFmpeg 日志和输出文件检查结果。
