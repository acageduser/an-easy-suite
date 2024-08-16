# zz-an-easy-update.ps1
Clear-Host

Write-Host "Before running this script:"
Write-Host "    1.  Close Minecraft."
Write-Host "    2.  Verify that the following are installed on your PC:"
Write-Host "         - Python"
Write-Host "         - PIP"
Write-Host "         - 7-zip"
Write-Host ""

# Execution policy change
$originalExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# Google Drive URL
$GDRIVE_URL = "https://drive.google.com/uc?export=download&id=19Y9HV7bJdSt2VyyVUUXkujZTfbDbtrbD"

# Paths
$MINECRAFT_FOLDER = "$env:APPDATA\.minecraft"
$TEMP_EXTRACT_PATH = "$env:TEMP\minecraft_temp_extract"
$DOWNLOAD_FILE = "$env:TEMP\.minecraft.zip"
$COOKIES_PATH = "$env:USERPROFILE\.cache\gdown\cookies.txt"

# Ensure the temporary extract path exists
if (-Not (Test-Path $TEMP_EXTRACT_PATH)) {
    New-Item -ItemType Directory -Force -Path $TEMP_EXTRACT_PATH | Out-Null
}

# Display menu and get user input
Write-Host "Select an option-:"
Write-Host ""
Write-Host "1. Full Update (Delete and replace all folders and files)"
Write-Host "2. Mods only (Delete and replace only the mods folder)"
Write-Host ""
$choice = Read-Host "Enter your choice (1 or 2)"

# Process user input
switch ($choice) {
    "1" {
        $option = "Full"
    }
    "2" {
        $option = "Mods only"
    }
    default {
        Write-Host "Invalid choice, exiting script."
        exit
    }
}

# Function to download files using gdown with cookies.txt
function Download-File {
    param (
        [string]$url,
        [string]$output
    )
    try {
        $cookiesOption = ""
        if (Test-Path $COOKIES_PATH) {
            $cookiesOption = "--cookies $COOKIES_PATH"
        }
        & "python" -c "import gdown; gdown.download('$url', r'$output', quiet=False, fuzzy=True, use_cookies=True)"
        $fileSize = (Get-Item $output).Length
        if ($fileSize -lt 1024) {
            throw "Downloaded file is too small to be valid. Please check the permissions and the link."
        }
    } catch {
        Write-Host "Download failed. Exiting script."
        exit 1
    }
}

# Download the .minecraft zip from Google Drive if it doesn't already exist
if (-Not (Test-Path $DOWNLOAD_FILE)) {
    Write-Host "Downloading .minecraft.zip from Google Drive..."
    Download-File -url $GDRIVE_URL -output $DOWNLOAD_FILE
}

# Full process: delete all folders and files
if ($option -eq "Full") {
    Write-Host "Running Full option..."

    # Delete the local mods, shaderpacks, resourcepacks, journeymap, and config folders
    $foldersToDelete = @("mods", "shaderpacks", "resourcepacks", "journeymap", "config")
    foreach ($folder in $foldersToDelete) {
        $folderPath = "$MINECRAFT_FOLDER\$folder"
        if (Test-Path $folderPath) {
            Remove-Item -Recurse -Force $folderPath
        }
    }

    # Delete the specific files before extracting the new ones
    $filesToDelete = @("options.txt", "optionsof.txt", "optionsshaders.txt", "servers.dat", "servers.dat_old")
    foreach ($file in $filesToDelete) {
        $filePath = "$MINECRAFT_FOLDER\$file"
        if (Test-Path $filePath) {
            Remove-Item -Force $filePath
        }
    }
}

# Mods only: delete and move the mods folder only
if ($option -eq "Mods only") {
    Write-Host "Running Mods only option..."

    # Delete the local mods folder
    $modsPath = "$MINECRAFT_FOLDER\mods"
    if (Test-Path $modsPath) {
        Remove-Item -Recurse -Force $modsPath
    }
}

# Extract the downloaded archive using 7-Zip to a temporary location
Write-Host "Extracting .minecraft.zip..."
$7zipPath = "C:\Program Files\7-Zip\7z.exe"
$extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
Invoke-Expression $extractCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "Extraction failed. Exiting script."
    exit 1
}

# Move folders based on the chosen option
if ($option -eq "Full") {
    $foldersToMove = @("mods", "shaderpacks", "resourcepacks", "journeymap", "config")
} elseif ($option -eq "Mods only") {
    $foldersToMove = @("mods")
}

foreach ($folder in $foldersToMove) {
    $dest = Join-Path -Path $MINECRAFT_FOLDER -ChildPath $folder
    $sourceFolder = Join-Path -Path $TEMP_EXTRACT_PATH -ChildPath $folder
    if (Test-Path $sourceFolder) {
        if (Test-Path $dest) {
            Remove-Item -Recurse -Force $dest
        }
        Move-Item -Path $sourceFolder -Destination $dest
    }
}

# Move specific files to the .minecraft folder (Full option only)
if ($option -eq "Full") {
    $filesToMove = @("options.txt", "optionsof.txt", "optionsshaders.txt", "servers.dat", "servers.dat_old")
    foreach ($file in $filesToMove) {
        $sourceFile = Join-Path -Path $TEMP_EXTRACT_PATH -ChildPath $file
        if (Test-Path $sourceFile) {
            Move-Item -Path $sourceFile -Destination $MINECRAFT_FOLDER
        }
    }
}

# Clean up the downloaded archive file and temporary extract folder
Write-Host "Cleaning up..."
if (Test-Path $DOWNLOAD_FILE) {
    Remove-Item $DOWNLOAD_FILE
}
if (Test-Path $TEMP_EXTRACT_PATH) {
    Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH
}

Write-Host "Process completed successfully."
# Clear-Host

Write-Host "        _____"
Write-Host "    ,-:' \;',''-, "
Write-Host "  .'-;_,;  ':-;_,'."
Write-Host " /;   '/    ,  _'.-\"
Write-Host "| ''. ('     /' ' \'|"
Write-Host "|:.  '\'-.   \_   / |"
Write-Host "|     (   ',  .'\ ;'|"
Write-Host " \     | .'     '-'/"
Write-Host "  '.   ;/        .'"
Write-Host "    ''-._____."
Write-Host ""


Write-Host "Update complete!!"
Write-Host ""
Write-Host "Folders Updated:"
Write-Host "	- config"
Write-Host "	- mods"
Write-Host "	- shaderpacks"
Write-Host "	- resourcepacks"
Write-Host "	- journeymap"
Write-Host ""
Write-Host "Files Updated:"
Write-Host "	- options.txt"
Write-Host "	- optionsof.txt"
Write-Host "	- optionsshaders.txt"
Write-Host "	- servers.dat"
Write-Host "	- servers.dat_old"
Write-Host ""
Write-Host "World IP Address: 51.79.77.46:25600"
Write-Host "Use Minecraft 1.20.1 v47.3.0 | https://files.minecraftforge.net/net/minecraftforge/forge/index_1.20.1.html"
Write-Host ""
Write-Host "Remember to allocate 8GB of ram to the game before starting it!"
Write-Host "Press Enter to continue..."
[System.Console]::ReadKey() | Out-Null
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalExecutionPolicy -Force