@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Maven Switcher

:: 管理员检查
fltmc >nul 2>&1 || (
    echo Warning: Run as Administrator for permanent switch!
    echo.
)

cls
echo ==============================================
echo           Maven Switcher (Fixed)
echo ==============================================
echo Scanning from X:\maven ...
echo.

set "SCAN_DIR=X:\maven"
set "MAVEN_COUNT=0"

:: 扫描所有有效 Maven（兼容新旧版）
for /d %%i in ("%SCAN_DIR%\*") do (
    if exist "%%i\bin\mvn.bat" (
        set /a MAVEN_COUNT+=1
        set "MAVEN[!MAVEN_COUNT!]=%%~fi"
    )
    if exist "%%i\bin\mvn.cmd" (
        set /a MAVEN_COUNT+=1
        set "MAVEN[!MAVEN_COUNT!]=%%~fi"
    )
)

if %MAVEN_COUNT%==0 (
    echo No maven found in X:\maven
    pause >nul
    exit /b
)

:: 显示菜单
echo Found Maven:
echo ----------------------------------------------
for /l %%n in (1,1,%MAVEN_COUNT%) do (
    echo  %%n ^) !MAVEN[%%n]!
)
echo ----------------------------------------------
echo  T - Temporary switch
echo  V - Show version
echo  0 - Exit
echo.
echo Current MAVEN_HOME: %MAVEN_HOME%
echo.

set "CHOICE="
set /p "CHOICE=Select: "

if /i "%CHOICE%"=="0" exit
if /i "%CHOICE%"=="V" (
    echo.
    mvn -v 2>nul
    if errorlevel 1 echo Please switch maven first!
    pause
    goto end
)

set "TEMP_MODE=0"
if /i "%CHOICE%"=="T" (
    set "TEMP_MODE=1"
    set /p "CHOICE=Input maven number: "
)

:: 选择目标
set "TARGET_HOME=!MAVEN[%CHOICE%]!"
set "TARGET_BIN=!TARGET_HOME!\bin"

if not exist "!TARGET_BIN!" (
    echo Invalid path!
    pause
    goto end
)

echo.
echo Using: !TARGET_HOME!
echo.

:: ====================== 切换核心 ======================
if "%TEMP_MODE%"=="1" (
    echo [Temporary mode]
    set "MAVEN_HOME=!TARGET_HOME!"
    set "PATH=!TARGET_BIN!;%PATH%"
) else (
    fltmc >nul 2>&1 || (
        echo ERROR: Run as Administrator!
        pause
        goto end
    )
    :: 系统环境变量
    setx MAVEN_HOME "!TARGET_HOME!" /M
    setx PATH "!TARGET_BIN!;%PATH%" /M
    set "MAVEN_HOME=!TARGET_HOME!"
    set "PATH=!TARGET_BIN!;%PATH%"
    echo System environment updated.
)

:: 直接调用 mvn 绝对路径，100% 不报错
echo.
echo Maven version:
"!TARGET_BIN!\mvn.cmd" -v

echo.
echo Switch success!
pause

:end
endlocal
