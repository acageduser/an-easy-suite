# zz-an-easy-update.ps1
# Clear-Host

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
$scriptDirectory = (Get-Location).Path
$MINECRAFT_FOLDER = "$scriptDirectory\.minecraft"
$TEMP_EXTRACT_PATH = "$scriptDirectory\minecraft_temp_extract"
$DOWNLOAD_FILE = "$scriptDirectory\.minecraft.zip"
$COOKIES_PATH = "$env:USERPROFILE\.cache\gdown\cookies.txt"

# Ensure the temporary extract path exists
if (-Not (Test-Path $TEMP_EXTRACT_PATH)) {
    New-Item -ItemType Directory -Force -Path $TEMP_EXTRACT_PATH | Out-Null
}

# Clear-Host
# Display menu and get user input
Write-Host "Select an option:"
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
# Clear-Host

# Download the .minecraft zip from Google Drive if it doesn't already exist
if (-Not (Test-Path $DOWNLOAD_FILE)) {
    Write-Host "Downloading .minecraft.zip from Google Drive..."
    Download-File -url $GDRIVE_URL -output $DOWNLOAD_FILE
}
# Clear-Host

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
# Clear-Host

# Mods only: delete and move the mods folder only
if ($option -eq "Mods only") {
    Write-Host "Running Mods only option..."

    # Delete the local mods folder
    $modsPath = "$MINECRAFT_FOLDER\mods"
    if (Test-Path $modsPath) {
        Remove-Item -Recurse -Force $modsPath
    }
}
# Clear-Host

# Extract the downloaded archive using 7-Zip to a temporary location
Write-Host "Extracting .minecraft.zip..."
$7zipPath = "C:\Program Files\7-Zip\7z.exe"
$extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
Invoke-Expression $extractCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "Extraction failed. Exiting script."
    exit 1
}
# Clear-Host

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
        Move-Item -Path $sourceFolder -Destination $dest -Force
    } else {
        Write-Host "Warning: Source folder '$sourceFolder' not found. Skipping."
    }
}

# Move specific files to the .minecraft folder (Full option only)
if ($option -eq "Full") {
    $filesToMove = @("options.txt", "optionsof.txt", "optionsshaders.txt", "servers.dat", "servers.dat_old")
    foreach ($file in $filesToMove) {
        $sourceFile = Join-Path -Path $TEMP_EXTRACT_PATH -ChildPath $file
        if (Test-Path $sourceFile) {
            Move-Item -Path $sourceFile -Destination $MINECRAFT_FOLDER -Force
        } else {
            Write-Host "Warning: Source file '$sourceFile' not found. Skipping."
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
# Clear-Host

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

Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalExecutionPolicy -Force
