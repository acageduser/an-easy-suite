# zz-an-easy-update.ps1
Clear-Host

Write-Host "Before running this script:"
Write-Host "    a.  Close Minecraft."
Write-Host "    b.  Verify that the following are installed on your PC:"
Write-Host "         - Python (python.org/downloads)"
Write-Host "         - PIP (curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py)"
Write-Host "         - 7-zip (7-zip.org)"
Write-Host "         - gdown (pip install gdown)"
Write-Host ""

# Execution policy change
$originalExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# Google Drive URL
$GDRIVE_URL = "https://drive.google.com/uc?export=download&id=19Y9HV7bJdSt2VyyVUUXkujZTfbDbtrbD"

# Paths
$scriptDirectory = $PSScriptRoot  # Directory where the script is run
$MINECRAFT_FOLDER = "$scriptDirectory\.minecraft"
$TEMP_EXTRACT_PATH = "$scriptDirectory\minecraft_temp_extract"
$DOWNLOAD_FILE = "$scriptDirectory\.minecraft.zip"
$COOKIES_PATH = "$env:USERPROFILE\.cache\gdown\cookies.txt"

# Ensure the temporary extract path exists
if (-Not (Test-Path $TEMP_EXTRACT_PATH)) {
    New-Item -ItemType Directory -Force -Path $TEMP_EXTRACT_PATH | Out-Null
}

# Display menu and get user input
Write-Host "Select an option :"
Write-Host ""
Write-Host "1. (*Recommended) Full Update (Delete and replace all needed folders and files)"
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
        if (Get-Command python -ErrorAction SilentlyContinue) {
            & "python" -c "import gdown; gdown.download('$url', r'$output', quiet=False, fuzzy=True, use_cookies=True)"
        } else {
            Write-Host "Python not found! Please install Python and gdown."
            exit 1
        }
        $fileSize = (Get-Item $output).Length
        if ($fileSize -lt 1024) {
            throw "Downloaded file is too small to be valid. Please check the permissions and the link."
        }
    } catch {
        Write-Host "Download failed: $_. Exiting script."
        exit 1
    }
}

# Download the .minecraft zip from Google Drive if it doesn't already exist
if (-Not (Test-Path $DOWNLOAD_FILE)) {
    Write-Host "Downloading .minecraft.zip from Google Drive..."
    Download-File -url $GDRIVE_URL -output $DOWNLOAD_FILE
}

# 7-Zip path checking for flexibility
$7zipPaths = @("C:\Program Files\7-Zip\7z.exe", "C:\Program Files (x86)\7-Zip\7z.exe")
$7zipPath = $null
foreach ($path in $7zipPaths) {
    if (Test-Path $path) {
        $7zipPath = $path
        break
    }
}

if (-Not $7zipPath) {
    Write-Host "7-Zip not found. Please install it from https://7-zip.org or provide the correct path."
    exit 1
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

# Extract the downloaded archive using 7-Zip to the script's directory
Write-Host "Extracting .minecraft.zip..."
$extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
Invoke-Expression $extractCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "Extraction failed. Exiting script."
    exit 1
}

# Checking for nested directories after extraction
Write-Host "Checking for nested directories..."
$nestedFolder = Get-ChildItem -Path $TEMP_EXTRACT_PATH | Where-Object { $_.PSIsContainer } | Select-Object -First 1

# If a nested folder exists, adjust the $TEMP_EXTRACT_PATH to point inside it
if ($nestedFolder -and (Test-Path "$TEMP_EXTRACT_PATH\$($nestedFolder.Name)\mods")) {
    Write-Host "Nested directory found: $($nestedFolder.Name)"
    $TEMP_EXTRACT_PATH = "$TEMP_EXTRACT_PATH\$($nestedFolder.Name)"
} else {
    Write-Host "No nested directory found."
}

# Debugging: Check extracted directories
Write-Host "Verifying extracted directories..."
Get-ChildItem -Path $TEMP_EXTRACT_PATH -Force

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
        try {
            Move-Item -Path $sourceFolder -Destination $dest -Force
        } catch {
            Write-Host "Error moving ${folder}: $_"
        }
    } else {
        Write-Host "Warning: Source folder '$sourceFolder' not found. Skipping."
    }
}

# Move specific files to the .minecraft folder (Full option only)
# Keeping the .minecraft.zip file and the minecraft_temp_extract folder
Write-Host "Skipping cleanup of the downloaded zip and extraction folder..."
try {
    # No cleanup here since we want to keep both .minecraft.zip and minecraft_temp_extract
    # If any logging or post-processing needs to happen, you can add it here
} catch {
    Write-Host "Error during cleanup: $_"
}

# Clean up the downloaded archive file and temporary extract folder
# Clean up the temporary extract folder only, keeping the .minecraft.zip file
Write-Host "Cleaning up..."
try {
    # Keeping the .minecraft.zip file, so no deletion here
    if (Test-Path $TEMP_EXTRACT_PATH) {
        Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH  # Clean up temp extract folder
    }
} catch {
    Write-Host "Error during cleanup: $_"
}

Write-Host "Update complete!!"
Write-Host ""
Write-Host "**IMPORTANT**"
Write-Host " 1.  Use Minecraft Forge 1.20.1"
Write-Host " 2.  Remember to allocate 8GB of RAM to the game before starting it!"
Write-Host ""
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
Write-Host "Menu:"
Write-Host " 1. Download Minecraft Forge 1.20.1 installer"
Write-Host "OR"
Write-Host "Press Enter to exit the script."

$input = Read-Host "Enter your choice"

switch ($input) {
    "1" {
        Write-Host "Opening the link in Google Chrome..."
        Start-Process "chrome.exe" "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.0/forge-1.20.1-47.3.0-installer.jar"
    }
    default {
        Write-Host "Exiting script..."
    }
}

# Restore the original execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalExecutionPolicy -Force
