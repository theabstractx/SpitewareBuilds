@echo off
setlocal

set "BUILD_DIR=%~dp0"
set "PARENT_DIR=%BUILD_DIR%.."

call :copy_file "%PARENT_DIR%\loader\build\debug\Clar1tyLoader.exe" "%BUILD_DIR%Clar1tyLoader_Debug.exe"
if errorlevel 1 goto :failed

call :copy_file "%PARENT_DIR%\loader\build\release\Clar1tyLoader.exe" "%BUILD_DIR%Clar1tyLoader.exe"
if errorlevel 1 goto :failed

call :copy_file "%PARENT_DIR%\kernel-esp\build\Clar1tyChairs\cs2_kernel_esp.exe" "%BUILD_DIR%cs2_kernel_esp.exe"
if errorlevel 1 goto :failed

call :copy_file "%PARENT_DIR%\kernel-pro\build\Clar1tyChairs\cs2_kernel_pro.exe" "%BUILD_DIR%cs2_kernel_pro.exe"
if errorlevel 1 goto :failed

echo Refresh complete.
exit /b 0

:copy_file
set "SOURCE=%~1"
set "TARGET=%~2"

if not exist "%SOURCE%" (
    echo Missing source file: %SOURCE%
    exit /b 1
)

if exist "%TARGET%" (
    del /f /q "%TARGET%"
    if exist "%TARGET%" (
        echo Failed to remove existing file: %TARGET%
        exit /b 1
    )
)
copy /y "%SOURCE%" "%TARGET%" >nul
if errorlevel 1 (
    echo Failed to copy: %SOURCE%
    exit /b 1
)

echo Updated %~nx2
pause
exit /b 0

:failed
echo Refresh failed.
pause
exit /b 1

