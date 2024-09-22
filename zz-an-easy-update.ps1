# zz-an-easy-update.ps1
Clear-Host

Write-Host "Before running this script :"
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
Write-Host "1. (*Recommended) Full Update (Copy and replace needed folders and files)"
Write-Host "2. Mods only (Copy and replace only the mods folder)"
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

# Extract the downloaded archive using 7-Zip to the script's directory
Write-Host "Extracting .minecraft.zip..."
$extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
Invoke-Expression $extractCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "Extraction failed. Exiting script."
    exit 1
}

# Verifying extracted directories for nested paths and adjusting if needed
Write-Host "Verifying extracted directories..."
$nestedFolder = Get-ChildItem -Path $TEMP_EXTRACT_PATH | Where-Object { $_.PSIsContainer } | Select-Object -First 1

# Adjust the $TEMP_EXTRACT_PATH if there's a nested directory
if ($nestedFolder -and (Test-Path "$TEMP_EXTRACT_PATH\$($nestedFolder.Name)\mods")) {
    Write-Host "Nested directory found: $($nestedFolder.Name)"
    $TEMP_EXTRACT_PATH = "$TEMP_EXTRACT_PATH\$($nestedFolder.Name)"
} else {
    Write-Host "No nested directory found."
}

# Copy folders based on the chosen option instead of moving them
if ($option -eq "Full") {
    $foldersToCopy = @("mods", "shaderpacks", "resourcepacks", "journeymap", "config")
} elseif ($option -eq "Mods only") {
    $foldersToCopy = @("mods")
}

foreach ($folder in $foldersToCopy) {
    # Correct destination path without extra ".minecraft"
    $dest = Join-Path -Path $MINECRAFT_FOLDER -ChildPath $folder
    $sourceFolder = Join-Path -Path $TEMP_EXTRACT_PATH -ChildPath $folder

    if (Test-Path $sourceFolder) {
        # Create the destination folder if it doesn't exist
        if (-not (Test-Path $dest)) {
            Write-Host "Creating folder structure for $folder..."
            New-Item -Path $dest -ItemType Directory -Force
        }

        # Copy all files and subdirectories from source to destination
        try {
            Write-Host "Copying contents of $folder..."
            Get-ChildItem -Path $sourceFolder -Recurse | ForEach-Object {
                # Build destination path
                $destPath = $_.FullName -replace [regex]::Escape($TEMP_EXTRACT_PATH), $MINECRAFT_FOLDER

                # If it's a directory, ensure it exists in the destination
                if ($_.PSIsContainer) {
                    if (-not (Test-Path $destPath)) {
                        New-Item -Path $destPath -ItemType Directory -Force
                    }
                } else {
                    # If it's a file, copy it to the destination
                    Copy-Item -Path $_.FullName -Destination $destPath -Force
                }
            }
        } catch {
            Write-Host "Error copying contents of ${folder}: $_"
        }
    } else {
        Write-Host "Warning: Source folder '$sourceFolder' not found. Skipping."
    }
}

# Skip cleanup of the downloaded archive file and temporary extract folder
Write-Host "Skipping cleanup of the downloaded zip and extraction folder..."
try {
    # No cleanup here since we want to keep both .minecraft.zip and minecraft_temp_extract
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
