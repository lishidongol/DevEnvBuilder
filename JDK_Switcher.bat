@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title JDK Switcher

fltmc >nul 2>&1 || (
    echo Warning: For permanent switch, run as Administrator!
    echo.
)

cls
echo ==============================================
echo      Fixed X:\jdk JDK Switcher
echo ==============================================
echo Scanning JDK from X:\jdk ...
echo.

set "JDK_LIST="
set "idx=0"
:: 固定只扫描 X:\jdk
set "SCAN_DIRS=X:\jdk"

for %%d in (%SCAN_DIRS%) do (
    if exist "%%d\" (
        for /d %%j in ("%%d\*") do (
            if exist "%%j\bin\java.exe" (
                set /a idx+=1
                set "JDK[!idx!]=%%~fj"
                set "JDK_LIST=!JDK_LIST! !idx!"
            )
        )
    )
)

if !idx! equ 0 (
    echo No valid JDK found in X:\jdk
    pause >nul
    exit /b
)

echo Found JDK list:
echo ----------------------------------------------
for %%i in (%JDK_LIST%) do (
    echo  %%i^) !JDK[%%i]!
)
echo ----------------------------------------------
echo  T - Temporary switch (current CMD only)
echo  V - Show current Java version
echo  0 - Exit
echo.
echo Current JAVA_HOME: %JAVA_HOME%
echo.

set "choice="
set /p "choice=Enter your choice: "

if /i "%choice%"=="0" goto end

if /i "%choice%"=="V" (
    echo.
    java -version
    echo.
    pause
    goto end
)

set "TEMP_MODE=0"
if /i "%choice%"=="T" (
    set "TEMP_MODE=1"
    set /p "choice=Enter JDK number: "
)

if not defined JDK[%choice%] (
    echo Invalid number!
    pause
    goto end
)

set "TARGET_JDK=!JDK[%choice%]!"
set "TARGET_BIN=!TARGET_JDK!\bin"
echo.
echo Selected JDK: !TARGET_JDK!
echo.

if !TEMP_MODE! equ 1 (
    echo Switch to TEMP mode.
    set "JAVA_HOME=!TARGET_JDK!"
    set "PATH=!TARGET_BIN!;%PATH%"
) else (
    fltmc >nul 2>&1 || (
        echo ERROR: Run as Administrator!
        pause
        goto end
    )
    :: 设置系统 JAVA_HOME
    setx JAVA_HOME "!TARGET_JDK!" /M >nul
    :: 把 JDK/bin 加到系统Path最前
    setx Path "!TARGET_BIN!;%Path%" /M >nul
    set "JAVA_HOME=!TARGET_JDK!"
    set "PATH=!TARGET_BIN!;%PATH%"
    echo System JAVA_HOME and Path updated.
)

echo.
echo Current Java version:
java -version
echo.
echo Switch completed!
pause >nul

:end
endlocal
