@echo off

:: Set download URL and destination path with a unique query string to bypass cache
set "downloadUrl=https://raw.githubusercontent.com/acageduser/an-easy-suite/main/zz-an-easy-update.ps1?%RANDOM%"
set "destinationPath=%~dp0zz-an-easy-update.ps1"

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Admin privileges confirmed

    :: Debugging: Print current directory and paths
    echo Current Directory: %~dp0
    echo Download URL: %downloadUrl%
    echo Destination Path: %destinationPath%

    :: Ensure the directory is writable
    echo Checking if the directory is writable...
    echo test > "%~dp0testfile.txt"
    if exist "%~dp0testfile.txt" (
        del "%~dp0testfile.txt"
        echo Directory is writable.
    ) else (
        echo Directory is not writable. Exiting.
        pause
        exit /B
    )

    :: Clean up any existing partial downloads
    if exist "%destinationPath%" (
        echo Deleting the existing zz-an-easy-update.ps1...
        del "%destinationPath%"
    )

    :: Download the latest zz-an-easy-update.ps1 from GitHub
    echo Downloading the latest zz-an-easy-update.ps1...
    curl -H "Cache-Control: no-cache" -L -o "%destinationPath%" "%downloadUrl%"
    if %errorlevel% neq 0 (
        echo Curl command failed with error level %errorlevel%
        pause
        exit /B
    )
    
    :: Check if download was successful
    if exist "%destinationPath%" (
        echo Download successful.
    ) else (
        echo Download failed.
        pause
        exit /B
    )

    :: Run the PowerShell script
    echo Running PowerShell script
    powershell -NoProfile -ExecutionPolicy Bypass -File "%destinationPath%"
    if %errorlevel% neq 0 (
        echo PowerShell script failed with error level %errorlevel%
        pause
        exit /B
    )
    echo PowerShell script executed
) else (
    echo Admin privileges not found, requesting admin
    :: We don't have admin privileges, so request them
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    echo Admin privileges requested
    exit /B
)

echo Script ended
pause
