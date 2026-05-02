@echo off
setlocal enabledelayedexpansion

set SD=%~dp0
set VP=
set T=0
set OK=0
set FL=0

title VHDX Compactor

if /i "%~1"=="/?" goto help
if /i "%~1"=="-h" goto help
if not "%~1"=="" set VP=%~1
goto check

:help
echo Usage: %~nx0 [VHDX_file_path]
pause
exit /b 0

:check
net session >NUL
if errorlevel 1 (
    echo ERROR: Run as Administrator
    pause
    exit /b 1
)

cls
echo.
echo ============================================================
echo                  VHDX Compactor
echo ============================================================
echo.

if defined VP (
    call :run "%VP%"
    goto end
)

echo Dir: %SD%
echo.

set N=0
for %%f in ("%SD%*.vhdx") do (
    set /a N+=1
    set F!N!=%%f
)

if !N! equ 0 (
    echo No VHDX files
    pause
    exit /b 0
)

echo Found !N! VHDX file(s):
echo.
echo  #   File Name                    Size (MB)
echo === ============================= ============

for /L %%i in (1,1,!N!) do (
    set P=!F%%i!
    for %%x in ("!P!") do set FN=%%~nx
    for /f %%a in ('powershell -noprofile -command "([Math]::Round((Get-Item '!P!').Length/1MB,0))"') do set SZ=%%a
    set "PN=!FN!                              "
    set "PN=!PN:~0,28!"
    echo   %%i  !PN! !SZ! MB
)

echo.
set /p SEL=Enter numbers (or all): 
if "!SEL!"=="" (pause ^& exit /b 0)
echo.

if /i "!SEL!"=="all" (
    for /L %%i in (1,1,!N!) do call :run "!F%%i!"
) else (
    for %%s in (!SEL!) do (
        set I=%%s
        if !I! geq 1 if !I! leq !N! call :run "!F%%s!"
    )
)

:end
echo.
echo ============================================================
echo Done: !T! files, !OK! OK, !FL! failed
echo.
pause
exit /b 0

:run
set V=%~1
set R=FAIL

echo.
echo File: %~nx1
echo.

if not exist "%V%" (
    echo ERROR: Not found
    goto :eof
)

for /f %%a in ('powershell -noprofile -command "([Math]::Round((Get-Item '%V%').Length/1MB,0))"') do set S1=%%a
echo Before: !S1! MB

set TF=%SD%dp%RANDOM%.txt
echo select vdisk file="%V%">%TF%
echo attach vdisk readonly>>%TF%
echo compact vdisk>>%TF%
echo detach vdisk>>%TF%

echo Compacting...
diskpart /s %TF% >NUL 2>NUL
del %TF% >NUL 2>NUL

for /f %%a in ('powershell -noprofile -command "([Math]::Round((Get-Item '%V%').Length/1MB,0))"') do set S2=%%a
echo After: !S2! MB

set /a S=S1-S2
if !S! gtr 0 echo Saved: !S! MB

set /a OK+=1
set /a T+=1
goto :eof
