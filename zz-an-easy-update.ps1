Clear-Host
# Set the console output and input to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

Write-Host "Current Output Encoding: " + [Console]::OutputEncoding.EncodingName
Write-Host "Current Input Encoding: " + [Console]::InputEncoding.EncodingName

Write-Host "!! Ensure Minecraft is closed before running this script !!"
Write-Host ""
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
    # Write-Host "Downloading $output..."
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
        # Write-Host "Downloaded $output successfully."
    } catch {
        # Write-Host "Download failed for $output. Error: $_"
        exit 1
    }
}

# Delete the local mods, shaderpacks, and resourcepacks folders before extracting the new ones
if (Test-Path "$MINECRAFT_FOLDER\mods") {
    # Write-Host "Deleting existing mods folder..."
    Remove-Item -Recurse -Force "$MINECRAFT_FOLDER\mods"
}

if (Test-Path "$MINECRAFT_FOLDER\shaderpacks") {
    # Write-Host "Deleting existing shaderpacks folder..."
    Remove-Item -Recurse -Force "$MINECRAFT_FOLDER\shaderpacks"
}

if (Test-Path "$MINECRAFT_FOLDER\resourcepacks") {
    # Write-Host "Deleting existing resourcepacks folder..."
    Remove-Item -Recurse -Force "$MINECRAFT_FOLDER\resourcepacks"
}

# Download the .minecraft zip from Google Drive
if (-Not (Test-Path $DOWNLOAD_FILE)) {
    Download-File -url $GDRIVE_URL -output $DOWNLOAD_FILE
}

Clear-Host
Write-Host "!! Ensure Minecraft is closed before running this script !!"
Write-Host ""
Write-Host "Before running this script:"
Write-Host "    1.  Close Minecraft."
Write-Host "    2.  Verify that the following are installed on your PC:"
Write-Host "         - Python"
Write-Host "         - PIP"
Write-Host "         - 7-zip"
Write-Host ""


# Extract the downloaded archive using 7-Zip to a temporary location
# Write-Host "Extracting .minecraft with 7-Zip..."
$7zipPath = "C:\Program Files\7-Zip\7z.exe"
$extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
Invoke-Expression $extractCommand

# Debug: List files in temporary extract path
# Write-Host ("Listing contents of " + $TEMP_EXTRACT_PATH + ":")
Get-ChildItem -Path $TEMP_EXTRACT_PATH -Force | ForEach-Object { Write-Host $_.FullName }

# Move folders to the .minecraft folder directly since they are at the root of the extract
Get-ChildItem "$TEMP_EXTRACT_PATH\*" -Directory | ForEach-Object {
    $dest = Join-Path -Path $MINECRAFT_FOLDER -ChildPath $_.Name
    # Write-Host "Moving $_.Name to $dest"
    if (Test-Path $dest) {
        Remove-Item -Recurse -Force $dest
    }
    Move-Item -Path $_.FullName -Destination $dest
}

# Clean up the downloaded archive file and temporary extract folder
Write-Host "Cleaning up..."
Remove-Item $DOWNLOAD_FILE
Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH
Clear-Host

Write-Host "           __..--''``---....___   _..._    __"
Write-Host " /// //_.-'    .-/`;  `        ``<._  ``.''_ `. / // / "
Write-Host "///_.-' _..--.'_    \                    `( ) ) // // "
Write-Host "/ (_..-' // (< _     ;_..__               ; `' / /// "
Write-Host " / // // //  `-._,_)' // / ``--...____..-' /// / // "


Write-Host "Update complete!!"

Write-Host ""
Write-Host "World IP Address: 51.79.77.46:25600"
Write-Host "Use Minecraft 1.20.1 v47.3.0 | https://files.minecraftforge.net/net/minecraftforge/forge/index_1.20.1.html"
Write-Host ""

Write-Host "Press Enter to continue..."
[System.Console]::ReadKey() | Out-Null
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalExecutionPolicy -Force