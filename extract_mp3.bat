@echo off
chcp 65001 >nul

echo ------------------------------
echo 自动提取 mp4 到 mp3
echo ------------------------------

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"

REM 默认输入、输出目录
set "SOURCE_DIR=%SCRIPT_DIR%mp4"
set "OUTPUT_DIR=%SCRIPT_DIR%convert_output"
set "FFMPEG_PATH=%SCRIPT_DIR%ffmpeg.exe"
set "FFMPEG_ZIP=%SCRIPT_DIR%ffmpeg.zip"

echo 脚本所在目录: %SCRIPT_DIR%
echo 输入目录: %SOURCE_DIR%
echo 输出目录: %OUTPUT_DIR%
echo ffmpeg 路径: %FFMPEG_PATH%
echo ---------------------------------------

REM 合并项目附带的 FFmpeg 分卷压缩包并解压
if not exist "%FFMPEG_PATH%" (
    if not exist "%SCRIPT_DIR%ffmpeg.zip.part-00" (
        echo [错误] 未找到 ffmpeg.exe 或 FFmpeg 压缩包分卷
        pause
        exit /b
    )
    echo 正在合并并解压 FFmpeg 压缩包...
    copy /b /y "%SCRIPT_DIR%ffmpeg.zip.part-00"+"%SCRIPT_DIR%ffmpeg.zip.part-01"+"%SCRIPT_DIR%ffmpeg.zip.part-02"+"%SCRIPT_DIR%ffmpeg.zip.part-03" "%FFMPEG_ZIP%" >nul
    if errorlevel 1 (
        echo [错误] 合并 FFmpeg 压缩包失败
        pause
        exit /b
    )
    powershell -NoProfile -Command "Expand-Archive -LiteralPath $env:FFMPEG_ZIP -DestinationPath $env:SCRIPT_DIR -Force -ErrorAction Stop"
    if not exist "%FFMPEG_PATH%" (
        echo [错误] ffmpeg.zip 解压失败
        pause
        exit /b
    )
)

REM 检查 mp4 输入目录
if not exist "%SOURCE_DIR%" (
    echo [错误] 未找到 mp4 输入目录: %SOURCE_DIR%
    pause
    exit /b
)

REM 创建输出目录
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
)

echo 开始处理 mp4 文件...
echo ------------------------------

REM 循环处理所有 mp4 文件
for %%f in ("%SOURCE_DIR%\*.mp4") do (
    echo 正在处理: %%~nxf
    "%FFMPEG_PATH%" -y -i "%%f" -vn -acodec libmp3lame -q:a 2 "%OUTPUT_DIR%\%%~nf.mp3"
)

echo ------------------------------
echo 全部完成！
pause
