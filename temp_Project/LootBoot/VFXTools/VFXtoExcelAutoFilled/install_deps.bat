@echo off
chcp 65001 >nul
echo [VFX Tool] 正在安装 Python 依赖...

python --version >nul 2>&1
if errorlevel 1 (
    echo 错误：未找到 python 命令，请确认 Python 已安装并已加入系统 PATH。
    echo 注意：Windows Store 版 Python 不兼容，请从 https://www.python.org 安装。
    pause
    exit /b 1
)

python -m pip install -r "%~dp0requirements.txt"
if errorlevel 1 (
    echo.
    echo 安装失败，请检查网络连接或手动运行：
    echo   pip install -r requirements.txt
    pause
    exit /b 1
)

echo.
echo 依赖安装完成。
pause
