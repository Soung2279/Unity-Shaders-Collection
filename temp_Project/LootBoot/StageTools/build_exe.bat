@echo off
chcp 65001 >nul
setlocal

cd /d "%~dp0"
echo ============================================================
echo  Monster Point Query - PyInstaller 打包脚本
echo ============================================================

python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 python 命令。
    pause
    exit /b 1
)

python -m pip show xlrd >nul 2>&1
if errorlevel 1 (
    echo [1/3] 安装 xlrd...
    python -m pip install xlrd --quiet
    if errorlevel 1 goto :failed
) else (
    echo [1/3] xlrd 已安装。
)

python -m pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo [2/3] 安装 PyInstaller...
    python -m pip install pyinstaller --quiet
    if errorlevel 1 goto :failed
) else (
    echo [2/3] PyInstaller 已安装。
)

echo [3/3] 打包 monster_point_query.exe...
python -m PyInstaller --noconfirm --clean --onefile --noconsole --name monster_point_query --collect-all xlrd monster_point_query.py
if errorlevel 1 goto :failed

copy /y "dist\monster_point_query.exe" "monster_point_query.exe" >nul
rmdir /s /q "dist" 2>nul
rmdir /s /q "build" 2>nul
del /q "monster_point_query.spec" 2>nul

echo.
echo 打包完成：%~dp0monster_point_query.exe
echo Unity 工具将优先调用此 EXE，无需同事安装 Python。
pause
exit /b 0

:failed
echo.
echo [错误] 打包失败，请检查上方日志。
pause
exit /b 1
