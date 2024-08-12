# zz-an-easy-update.ps1

# Ensure Minecraft is closed before running this script
Write-Host ""
Write-Host "Before running this script:"
Write-Host "    - Close Minecraft."
Write-Host ""
Write-Host "    - Verify that the following are installed on your PC:"
Write-Host "        - Python"
Write-Host "        - PIP"
Write-Host "        - 7-zip"
Write-Host ""

# Execution policy change
$originalExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# Google Drive URL
$GDRIVE_URL = "https://drive.google.com/uc?export=download&id=1vWCWGPyUZrioDOvJK_sNL32O1q6nwqYN"

# Paths
$MINECRAFT_FOLDER = "$env:APPDATA\.minecraft"
$TEMP_EXTRACT_PATH = "$env:TEMP\minecraft_temp_extract"
$DOWNLOAD_FILE = "$env:TEMP\.minecraft.zip"
$COOKIES_PATH = "$env:USERPROFILE\.cache\gdown\cookies.txt"

# Ensure the temporary extract path exists
if (-Not (Test-Path $TEMP_EXTRACT_PATH)) {
    New-Item -ItemType Directory -Force -Path $TEMP_EXTRACT_PATH | Out-Null
}

# Function to download files using gdown with cookies.txt
function Download-File {
    param (
        [string]$url,
        [string]$output
    )
    Write-Host "Downloading $output..."
    try {
        $cookiesOption = ""
        if (Test-Path $COOKIES_PATH) {
            $cookiesOption = "--cookies $COOKIES_PATH"
        }
        & "python" -c "import gdown; gdown.download('$url', r'$output', quiet=False, fuzzy=True, use_cookies=True)"
        # Check the file size to ensure it is not an HTML error page
        $fileSize = (Get-Item $output).Length
        if ($fileSize -lt 1024) {
            throw "Downloaded file is too small to be valid. Please check the permissions and the link."
        }
        Write-Host "Downloaded $output successfully."
    } catch {
        Write-Host "Download failed for $output. Error: $_"
        exit 1
    }
}

# Delete the local mods, shaderpacks, and resourcepacks folders before extracting the new ones
if (Test-Path "$MINECRAFT_FOLDER\mods") {
    Write-Host "Deleting existing mods folder..."
    Remove-Item -Recurse -Force "$MINECRAFT_FOLDER\mods"
}

if (Test-Path "$MINECRAFT_FOLDER\shaderpacks") {
    Write-Host "Deleting existing shaderpacks folder..."
    Remove-Item -Recurse -Force "$MINECRAFT_FOLDER\shaderpacks"
}

if (Test-Path "$MINECRAFT_FOLDER\resourcepacks") {
    Write-Host "Deleting existing resourcepacks folder..."
    Remove-Item -Recurse -Force "$MINECRAFT_FOLDER\resourcepacks"
}

# Download the .minecraft zip from Google Drive
if (-Not (Test-Path $DOWNLOAD_FILE)) {
    Download-File -url $GDRIVE_URL -output $DOWNLOAD_FILE
}

# Check if the download was successful and is a valid zip file
if ((Test-Path $DOWNLOAD_FILE) -and (Get-Item $DOWNLOAD_FILE).Length -gt 1024) {
    # Extract the downloaded archive using 7-Zip to a temporary location
    Write-Host "Extracting .minecraft with 7-Zip..."
    $7zipPath = "C:\Program Files\7-Zip\7z.exe" # Adjust this path if 7-Zip is installed elsewhere
    $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
    Invoke-Expression $extractCommand

    # Move folders to the .minecraft folder
    Get-ChildItem "$TEMP_EXTRACT_PATH\.minecraft\*" | ForEach-Object {
        $dest = "$MINECRAFT_FOLDER\$($_.Name)"
        if ($_.PSIsContainer) {
            if (Test-Path $dest) {
                Remove-Item -Recurse -Force $dest
            }
            Move-Item -Force -Path $_.FullName -Destination $dest
        } else {
            Move-Item -Force -Path $_.FullName -Destination $dest
        }
    }

    # Clean up the downloaded archive file and temporary extract folder
    Write-Host "Cleaning up..."
    Remove-Item $DOWNLOAD_FILE
    Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH
    Write-Host "Update complete!"
} else {
    Write-Host "Download failed or the file is not a valid archive. Please check the download link and try again."
}

Write-Host "Update process complete!"
Write-Host "IP Address: 51.79.77.46:25600"
Write-Host "Press Enter to continue..."
[System.Console]::ReadKey() | Out-Null
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalExecutionPolicy -Force
