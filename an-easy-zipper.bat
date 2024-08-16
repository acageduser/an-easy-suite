@echo off
setlocal

REM Define paths
set MINECRAFT_FOLDER=%APPDATA%\.minecraft
set OUTPUT_ZIP=%MINECRAFT_FOLDER%\.minecraft.zip
set RCLONE_EXEC=rclone
set REMOTE_NAME=google_drive
set REMOTE_PATH=Backup/minecraft/.minecraft.zip

REM Clear any existing .minecraft.zip in the .minecraft folder
if exist "%OUTPUT_ZIP%" del "%OUTPUT_ZIP%"

REM Paths of folders to include in the zip
set FOLDERS_TO_ZIP=config mods shaderpacks resourcepacks journeymap

REM Paths of files to include in the zip
set FILES_TO_ZIP=options.txt optionsof.txt optionsshaders.txt servers.dat servers.dat_old

REM Change to the .minecraft directory
cd /d "%MINECRAFT_FOLDER%"

REM Zip the folders
echo Adding folders to the zip file...
for %%F in (%FOLDERS_TO_ZIP%) do (
    if exist "%%F" (
        echo     - %%F
        "%ProgramFiles%\7-Zip\7z.exe" a -r "%OUTPUT_ZIP%" "%%F"
    )
)

REM Zip the files
echo Adding files to the zip file...
for %%F in (%FILES_TO_ZIP%) do (
    if exist "%%F" (
        echo     - %%F
        "%ProgramFiles%\7-Zip\7z.exe" a "%OUTPUT_ZIP%" "%%F"
    )
)

REM Upload the zip to Google Drive using Rclone
echo Uploading .minecraft.zip to Google Drive...
%RCLONE_EXEC% copy "%OUTPUT_ZIP%" %REMOTE_NAME%:%REMOTE_PATH% --drive-chunk-size 64M --progress
if errorlevel 1 (
    echo Upload failed. Please check the remote configuration and try again.
) else (
    echo Upload successful. The old .minecraft.zip file has been replaced.
)

REM Display a message of completion
echo.
echo .minecraft.zip has been created in the .minecraft folder and uploaded to Google Drive.
echo You can find it at: %OUTPUT_ZIP%
echo.

pause
endlocal
