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

# Google Drive URLs
$GDRIVE_MODS_URL = "https://drive.google.com/uc?export=download&id=1LrSgBpQFoLjg_jqv0Tf3dM8isbY--iGJ"
$GDRIVE_CONFIG_URL = "https://drive.google.com/uc?export=download&id=1Q3EnPVK74Ki2UUg3ymr0WVujH5MdzEsN"
$GDRIVE_SHADERPACKS_URL = "https://drive.google.com/uc?export=download&id=1l56fFwPqBC7JDhvq-BUJ4kns0o9u0x57"
$GDRIVE_RESOURCEPACKS_URL = "https://drive.google.com/uc?export=download&id=105BFnFbjfXI0zWCTfTODtRPsn89bbiqm"
$GDRIVE_OPTIONS_SHADERS_URL = "https://drive.google.com/uc?export=download&id=1yDiiBGlhjc_vdKOgZsQBTsyfMVCRzCCB"
$GDRIVE_OPTIONS_URL = "https://drive.google.com/uc?export=download&id=1O_tv4xaZqRe3aWoGe5e9u3umqc43w9kq"

# Paths
$MODS_FOLDER = "$env:APPDATA\.minecraft\mods"
$CONFIG_FOLDER = "$env:APPDATA\.minecraft\config"
$SHADERPACKS_FOLDER = "$env:APPDATA\.minecraft\shaderpacks"
$RESOURCEPACKS_FOLDER = "$env:APPDATA\.minecraft\resourcepacks"
$TEMP_EXTRACT_PATH = "$env:TEMP\minecraft_temp_extract"
$DOWNLOAD_MODS_FILE = "$env:TEMP\mods.zip"
$DOWNLOAD_CONFIG_FILE = "$env:TEMP\forge-client.toml"
$DOWNLOAD_SHADERPACKS_FILE = "$env:TEMP\shaderpacks.zip"
$DOWNLOAD_RESOURCEPACKS_FILE = "$env:TEMP\resourcepacks.zip"
$DOWNLOAD_OPTIONS_SHADERS_FILE = "$env:TEMP\optionsshaders.txt"
$DOWNLOAD_OPTIONS_FILE = "$env:TEMP\options.txt"

# Ensure the temporary extract path exists
if (-Not (Test-Path $TEMP_EXTRACT_PATH)) {
    New-Item -ItemType Directory -Force -Path $TEMP_EXTRACT_PATH | Out-Null
}

# Function to download files using gdown
function Download-File {
    param (
        [string]$url,
        [string]$output
    )
    Write-Host "Downloading $output..."
    try {
        & "python" -c "import gdown; gdown.download('$url', r'$output', quiet=False)"
        Write-Host "Downloaded $output successfully."
    } catch {
        Write-Host "Download failed for $output. Please check the download link and try again."
        exit 1
    }
}

# Delete the local mods folder before downloading
if (Test-Path $MODS_FOLDER) {
    Write-Host "Deleting existing mods folder..."
    Remove-Item -Recurse -Force $MODS_FOLDER
    New-Item -ItemType Directory -Force -Path $MODS_FOLDER | Out-Null
}

# Download the mods zip from Google Drive using gdown
if (-Not (Test-Path $DOWNLOAD_MODS_FILE)) {
    Download-File -url $GDRIVE_MODS_URL -output $DOWNLOAD_MODS_FILE
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_MODS_FILE) {
    # Extract the downloaded archive using 7-Zip to a temporary location
    Write-Host "Extracting new mods with 7-Zip..."
    $7zipPath = "C:\Program Files\7-Zip\7z.exe" # Adjust this path if 7-Zip is installed elsewhere
    $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_MODS_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
    Invoke-Expression $extractCommand

    # Move files from the temporary location to the mods folder
    Get-ChildItem "$TEMP_EXTRACT_PATH\*" -Recurse | Move-Item -Destination $MODS_FOLDER -Force

    # Clean up the downloaded archive file and temporary extract folder
    Write-Host "Cleaning up..."
    Remove-Item $DOWNLOAD_MODS_FILE
    Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH
    Write-Host "Mods update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
}

# Download the forge-client.toml from Google Drive using gdown
if (-Not (Test-Path $DOWNLOAD_CONFIG_FILE)) {
    Download-File -url $GDRIVE_CONFIG_URL -output $DOWNLOAD_CONFIG_FILE
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_CONFIG_FILE) {
    # Verify and move the downloaded file
    Write-Host "Deleting existing forge-client.toml..."
    Remove-Item -Force "$CONFIG_FOLDER\forge-client.toml"

    # Move the downloaded forge-client.toml to the config folder
    Write-Host "Moving new forge-client.toml to the config folder..."
    Move-Item -Force -Path $DOWNLOAD_CONFIG_FILE -Destination "$CONFIG_FOLDER\forge-client.toml"
    Write-Host "Config update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
}

# Ensure shaderpacks folder exists
if (-Not (Test-Path $SHADERPACKS_FOLDER)) {
    Write-Host "Creating shaderpacks folder..."
    New-Item -ItemType Directory -Force -Path $SHADERPACKS_FOLDER | Out-Null
}

# Download the shaderpacks zip from Google Drive using gdown
if (-Not (Test-Path $DOWNLOAD_SHADERPACKS_FILE)) {
    Download-File -url $GDRIVE_SHADERPACKS_URL -output $DOWNLOAD_SHADERPACKS_FILE
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_SHADERPACKS_FILE) {
    # Extract the downloaded archive using 7-Zip to a temporary location
    Write-Host "Extracting new shaderpacks with 7-Zip..."
    $7zipPath = "C:\Program Files\7-Zip\7z.exe" # Adjust this path if 7-Zip is installed elsewhere
    $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_SHADERPACKS_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
    Invoke-Expression $extractCommand

    # Move files from the temporary location to the shaderpacks folder
    Get-ChildItem "$TEMP_EXTRACT_PATH\*" -Recurse | Move-Item -Destination $SHADERPACKS_FOLDER -Force

    # Clean up the downloaded archive file and temporary extract folder
    Write-Host "Cleaning up..."
    Remove-Item $DOWNLOAD_SHADERPACKS_FILE
    Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH
    Write-Host "Shaderpacks update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
}

# Ensure resourcepacks folder exists
if (-Not (Test-Path $RESOURCEPACKS_FOLDER)) {
    Write-Host "Creating resourcepacks folder..."
    New-Item -ItemType Directory -Force -Path $RESOURCEPACKS_FOLDER | Out-Null
}

# Download the resourcepacks zip from Google Drive using gdown
if (-Not (Test-Path $DOWNLOAD_RESOURCEPACKS_FILE)) {
    Download-File -url $GDRIVE_RESOURCEPACKS_URL -output $DOWNLOAD_RESOURCEPACKS_FILE
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_RESOURCEPACKS_FILE) {
    # Extract the downloaded archive using 7-Zip to a temporary location
    Write-Host "Extracting new resourcepacks with 7-Zip..."
    $7zipPath = "C:\Program Files\7-Zip\7z.exe" # Adjust this path if 7-Zip is installed elsewhere
    $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_RESOURCEPACKS_FILE`" -o`"$TEMP_EXTRACT_PATH`" -y"
    Invoke-Expression $extractCommand

    # Move files from the temporary location to the resourcepacks folder
    Get-ChildItem "$TEMP_EXTRACT_PATH\*" -Recurse | Move-Item -Destination $RESOURCEPACKS_FOLDER -Force

    # Clean up the downloaded archive file and temporary extract folder
    Write-Host "Cleaning up..."
    Remove-Item $DOWNLOAD_RESOURCEPACKS_FILE
    Remove-Item -Recurse -Force $TEMP_EXTRACT_PATH
    Write-Host "Resourcepacks update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
}

# Download the optionsshaders.txt from Google Drive using gdown
if (-Not (Test-Path $DOWNLOAD_OPTIONS_SHADERS_FILE)) {
    Download-File -url $GDRIVE_OPTIONS_SHADERS_URL -output $DOWNLOAD_OPTIONS_SHADERS_FILE
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_OPTIONS_SHADERS_FILE) {
    # Move the downloaded optionsshaders.txt to the Minecraft folder
    Write-Host "Moving optionsshaders.txt to the Minecraft folder..."
    Move-Item -Force -Path $DOWNLOAD_OPTIONS_SHADERS_FILE -Destination "$env:APPDATA\.minecraft\optionsshaders.txt"
    Write-Host "Options shaders update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
}

# Download the options.txt from Google Drive using gdown
if (-Not (Test-Path $DOWNLOAD_OPTIONS_FILE)) {
    Download-File -url $GDRIVE_OPTIONS_URL -output $DOWNLOAD_OPTIONS_FILE
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_OPTIONS_FILE) {
    # Move the downloaded options.txt to the Minecraft folder
    Write-Host "Moving options.txt to the Minecraft folder..."
    Move-Item -Force -Path $DOWNLOAD_OPTIONS_FILE -Destination "$env:APPDATA\.minecraft\options.txt"
    Write-Host "Options update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
}

# Restore original execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalExecutionPolicy -Force

Write-Host "Update process complete!"
Pause
