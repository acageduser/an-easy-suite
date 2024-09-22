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

# Google Drive URL for the .minecraft.zip file
$GDRIVE_URL = "https://drive.google.com/uc?export=download&id=19Y9HV7bJdSt2VyyVUUXkujZTfbDbtrbD"

# Paths
$scriptDirectory = $PSScriptRoot  # Directory where the script is run
$DOWNLOAD_FILE = "$scriptDirectory\.minecraft.zip"  # File to be downloaded and extracted in place
$COOKIES_PATH = "$env:USERPROFILE\.cache\gdown\cookies.txt"
$modsFolderPath = "$scriptDirectory\mods"  # Mods folder location
$tempExtractPath = "$scriptDirectory\minecraft_temp_extract"  # Temporary folder for Mods Only option

# Display menu and get user input
Write-Host "Select an option:"
Write-Host ""
Write-Host "1. (*Recommended) Full Update (Delete and replace the mods folder, extract all files)"
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

# Full Update: Delete mods folder and extract all files
if ($option -eq "Full") {
    if (Test-Path $modsFolderPath) {
        Write-Host "Deleting the mods folder..."
        Remove-Item -Recurse -Force $modsFolderPath
    } else {
        Write-Host "Mods folder not found, skipping deletion."
    }

    # Extract the downloaded archive using 7-Zip, overwrite files
    Write-Host "Extracting .minecraft.zip (overwrite mode)..."
    $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_FILE`" -aoa -o`"$scriptDirectory`""  # '-aoa' forces overwrite
    Invoke-Expression $extractCommand

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Extraction failed. Exiting script."
        exit 1
    }

    Write-Host "Folders and files successfully overwritten."

# Mods Only: Delete mods folder, extract to temp, copy mods back
} elseif ($option -eq "Mods only") {
    if (Test-Path $modsFolderPath) {
        Write-Host "Deleting the mods folder..."
        Remove-Item -Recurse -Force $modsFolderPath
    } else {
        Write-Host "Mods folder not found, skipping deletion."
    }

    # Ensure the temporary extract path exists
    if (-Not (Test-Path $tempExtractPath)) {
        New-Item -ItemType Directory -Force -Path $tempExtractPath | Out-Null
    }

    # Extract to temporary folder
    Write-Host "Extracting .minecraft.zip to 'minecraft_temp_extract' folder..."
    $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_FILE`" -o`"$tempExtractPath`""  # No overwrite needed for temp folder
    Invoke-Expression $extractCommand

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Extraction to temp folder failed. Exiting script."
        exit 1
    }

    # Copy only the mods folder contents to the main directory
    $sourceModsFolder = "$tempExtractPath\mods"
    if (Test-Path $sourceModsFolder) {
        Write-Host "Copying mods folder to the main directory..."
        Copy-Item -Recurse -Force -Path $sourceModsFolder -Destination $scriptDirectory
    } else {
        Write-Host "Mods folder not found in extracted files."
    }
}

Write-Host "Update complete!!"
Write-Host ""
Write-Host "**IMPORTANT**"
Write-Host " 1.  Use Minecraft Forge 1.20.1"
Write-Host " 2.  Remember to allocate 8GB of RAM to the game before starting it!"
Write-Host ""
Write-Host "        _____"
Write-Host "    ,-:' \;',''-,"
Write-Host "  .'-;_,;  ':-;_,'"
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
        
        # Clean up the temporary extraction folder
        if (Test-Path $tempExtractPath) {
            Write-Host "Cleaning up temporary extraction folder..."
            Remove-Item -Recurse -Force $tempExtractPath
        }

        # Clean up the downloaded .minecraft.zip file if desired
        if (Test-Path $DOWNLOAD_FILE) {
            Write-Host "Cleaning up downloaded .minecraft.zip file..."
            Remove-Item -Force $DOWNLOAD_FILE
        }
    }
}

# Restore the original execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalExecutionPolicy -Force
