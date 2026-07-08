@echo off
chcp 65001 >nul
echo ============================================================
echo  VFX Excel Tool - PyInstaller 打包脚本
echo ============================================================
echo.

:: 检查 python 是否可用
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 python 命令，请确认 Python 已安装并加入 PATH。
    echo        建议从 https://www.python.org 下载安装，不要使用 Windows Store 版本。
    pause
    exit /b 1
)

:: 切换到本脚本所在目录
cd /d "%~dp0"

:: 安装依赖（xlrd==1.2.0 必须锁版本，2.x 不支持 .xls）
echo [1/3] 安装 Python 依赖...
python -m pip install xlrd==1.2.0 xlwt xlutils --quiet
if errorlevel 1 (
    echo [错误] 依赖安装失败，请检查网络或 pip 配置。
    pause
    exit /b 1
)

:: 安装 PyInstaller
python -m pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo       正在安装 PyInstaller...
    python -m pip install pyinstaller --quiet
    if errorlevel 1 (
        echo [错误] PyInstaller 安装失败。
        pause
        exit /b 1
    )
)

:: 打包为单文件 exe，--noconsole 禁止弹出黑色 cmd 窗口
echo [2/3] 正在打包 vfx_excel_tool.py ...
python -m PyInstaller --onefile --noconsole --name vfx_excel_tool vfx_excel_tool.py
if errorlevel 1 (
    echo [错误] PyInstaller 打包失败，请查看上方日志。
    pause
    exit /b 1
)

:: 将产物移动到当前目录
echo [3/3] 整理产物...
if exist "dist\vfx_excel_tool.exe" (
    copy /y "dist\vfx_excel_tool.exe" "vfx_excel_tool.exe" >nul
    echo       vfx_excel_tool.exe 已生成到当前目录。
) else (
    echo [错误] 未找到打包产物 dist\vfx_excel_tool.exe。
    pause
    exit /b 1
)

:: 清理临时文件
if exist "dist"               rmdir /s /q "dist"
if exist "build"              rmdir /s /q "build"
if exist "vfx_excel_tool.spec" del /q "vfx_excel_tool.spec"

echo.
echo ============================================================
echo  完成！请将 vfx_excel_tool.exe 与工程一起提交/分发。
echo  Unity 工具会优先调用同目录的 exe，无需目标机器安装 Python。
echo ============================================================
pause
