# zz-an-easy-update.ps1

# Log file
$logFile = "an-easy-update.log"

function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logMessage
}

# Ensure Minecraft is closed before running this script
Write-Host "Please make sure Minecraft is closed before running this script."
Write-Host "If Python is not installed, download it from: https://www.python.org/downloads/release/python-3120/"
Write-Host "After installing Python, install gdown using: pip install gdown"
Pause

# Execution policy change
$originalExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
Write-Log "Execution policy set to RemoteSigned."

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
$EXTRACT_PATH = "$env:APPDATA\.minecraft"
$DOWNLOAD_MODS_FILE = "$env:TEMP\mods.zip"
$DOWNLOAD_CONFIG_FILE = "$env:TEMP\forge-client.toml"
$DOWNLOAD_SHADERPACKS_FILE = "$env:TEMP\shaderpacks.zip"
$DOWNLOAD_RESOURCEPACKS_FILE = "$env:TEMP\resourcepacks.zip"
$DOWNLOAD_OPTIONS_SHADERS_FILE = "$env:TEMP\optionsshaders.txt"
$DOWNLOAD_OPTIONS_FILE = "$env:TEMP\options.txt"

# Ensure 7-Zip is installed
$7zipPath = "C:\Program Files\7-Zip\7z.exe"
if (-Not (Test-Path $7zipPath)) {
    Write-Host "7-Zip is not installed. Please install 7-Zip from: https://www.7-zip.org/"
    Write-Log "7-Zip is not installed."
    exit 1
}

# Ensure gdown is installed
Write-Host "Checking if gdown is installed..."
Write-Log "Checking if gdown is installed..."

try {
    $pythonVersion = & "python" --version 2>&1
    Write-Log "Python is installed: $pythonVersion"
} catch {
    Write-Host "Python is not installed. Please install Python from: https://www.python.org/downloads/release/python-3120/"
    Write-Log "Python is not installed."
    exit 1
}

try {
    $pipVersion = & "pip" --version 2>&1
    Write-Log "pip is installed: $pipVersion"
} catch {
    Write-Host "pip is not installed. Please install pip."
    Write-Log "pip is not installed."
    exit 1
}

try {
    $gdownVersion = & "gdown" --version 2>&1
    Write-Log "gdown is already installed: $gdownVersion"
} catch {
    Write-Host "gdown is not installed. Installing gdown..."
    Write-Log "gdown is not installed. Installing gdown..."
    & "pip" install gdown
    Write-Log "gdown installed successfully."
}

# Delete the local mods folder before downloading
if (Test-Path $MODS_FOLDER) {
    Write-Host "Deleting existing mods folder..."
    Write-Log "Deleting existing mods folder..."
    Remove-Item -Recurse -Force $MODS_FOLDER
    Write-Log "Existing mods folder deleted."
}

# Download the mods zip from Google Drive using gdown if it hasn't been downloaded already
if (-Not (Test-Path $DOWNLOAD_MODS_FILE)) {
    Write-Host "Downloading mods archive using gdown..."
    Write-Log "Downloading mods archive using gdown..."

    try {
        $gdownCommand = "gdown $GDRIVE_MODS_URL -O $DOWNLOAD_MODS_FILE"
        Write-Log "Running command: $gdownCommand"
        & "python" -c "import gdown; gdown.download('$GDRIVE_MODS_URL', r'$DOWNLOAD_MODS_FILE', quiet=False)"
        Write-Log "Download completed."
    } catch {
        Write-Host "Download failed. Please check the download link and try again."
        Write-Log "Download failed: $_"
        exit 1
    }
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_MODS_FILE) {
    Write-Log "Download file exists."
    # Verify the downloaded file is a valid ZIP file
    Write-Host "Verifying the downloaded archive..."
    Write-Log "Verifying the downloaded archive..."
    
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($DOWNLOAD_MODS_FILE)
        $zip.Dispose()
        Write-Log "The downloaded file is a valid ZIP archive."

        # Step 3: Extract the downloaded archive using 7-Zip
        Write-Host "Extracting new mods with 7-Zip..."
        Write-Log "Extracting new mods with 7-Zip..."
        $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_MODS_FILE`" -o`"$EXTRACT_PATH`" -y"
        Invoke-Expression $extractCommand
        Write-Log "Extraction completed."

        # Step 4: Clean up the downloaded archive file
        Write-Host "Cleaning up..."
        Write-Log "Cleaning up..."
        Remove-Item $DOWNLOAD_MODS_FILE
        Write-Log "Download file deleted."

        Write-Host "Mods update complete!"
        Write-Log "Mods update complete!"
    } catch {
        Write-Host "The downloaded file is not a valid ZIP archive. Please check the download link and try again."
        Write-Log "The downloaded file is not a valid ZIP archive. Exception: $_"
        Remove-Item $DOWNLOAD_MODS_FILE
    }
} else {
    Write-Host "Download failed. Please check the download link and try again."
    Write-Log "Download failed. The file does not exist at $DOWNLOAD_MODS_FILE."
}

# Download the forge-client.toml from Google Drive using gdown if it hasn't been downloaded already
if (-Not (Test-Path $DOWNLOAD_CONFIG_FILE)) {
    Write-Host "Downloading forge-client.toml using gdown..."
    Write-Log "Downloading forge-client.toml using gdown..."

    try {
        $gdownCommand = "gdown $GDRIVE_CONFIG_URL -O $DOWNLOAD_CONFIG_FILE"
        Write-Log "Running command: $gdownCommand"
        & "python" -c "import gdown; gdown.download('$GDRIVE_CONFIG_URL', r'$DOWNLOAD_CONFIG_FILE', quiet=False)"
        Write-Log "Download completed."
    } catch {
        Write-Host "Download failed. Please check the download link and try again."
        Write-Log "Download failed: $_"
        exit 1
    }
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_CONFIG_FILE) {
    Write-Log "Download file exists."
    # Verify and move the downloaded file
    Write-Host "Deleting existing forge-client.toml..."
    Write-Log "Deleting existing forge-client.toml..."
    Remove-Item -Force "$CONFIG_FOLDER\forge-client.toml"
    Write-Log "Existing forge-client.toml deleted."

    # Step 7: Move the downloaded forge-client.toml to the config folder
    Write-Host "Moving new forge-client.toml to the config folder..."
    Write-Log "Moving new forge-client.toml to the config folder..."
    Move-Item -Force -Path $DOWNLOAD_CONFIG_FILE -Destination "$CONFIG_FOLDER\forge-client.toml"
    Write-Log "forge-client.toml moved to the config folder."

    Write-Host "Config update complete!"
    Write-Log "Config update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
    Write-Log "Download failed. The file does not exist at $DOWNLOAD_CONFIG_FILE."
}

# Ensure shaderpacks folder exists
if (-Not (Test-Path $SHADERPACKS_FOLDER)) {
    Write-Host "Creating shaderpacks folder..."
    Write-Log "Creating shaderpacks folder..."
    New-Item -ItemType Directory -Force -Path $SHADERPACKS_FOLDER
    Write-Log "Shaderpacks folder created."
}

# Download the shaderpacks zip from Google Drive using gdown if it hasn't been downloaded already
if (-Not (Test-Path $DOWNLOAD_SHADERPACKS_FILE)) {
    Write-Host "Downloading shaderpacks archive using gdown..."
    Write-Log "Downloading shaderpacks archive using gdown..."

    try {
        $gdownCommand = "gdown $GDRIVE_SHADERPACKS_URL -O $DOWNLOAD_SHADERPACKS_FILE"
        Write-Log "Running command: $gdownCommand"
        & "python" -c "import gdown; gdown.download('$GDRIVE_SHADERPACKS_URL', r'$DOWNLOAD_SHADERPACKS_FILE', quiet=False)"
        Write-Log "Download completed."
    } catch {
        Write-Host "Download failed. Please check the download link and try again."
        Write-Log "Download failed: $_"
        exit 1
    }
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_SHADERPACKS_FILE) {
    Write-Log "Download file exists."
    # Verify the downloaded file is a valid ZIP file
    Write-Host "Verifying the downloaded archive..."
    Write-Log "Verifying the downloaded archive..."
    
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($DOWNLOAD_SHADERPACKS_FILE)
        $zip.Dispose()
        Write-Log "The downloaded file is a valid ZIP archive."

        # Extract the downloaded shaderpacks archive, overwriting existing files
        Write-Host "Extracting shaderpacks with 7-Zip..."
        Write-Log "Extracting shaderpacks with 7-Zip..."
        $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_SHADERPACKS_FILE`" -o`"$SHADERPACKS_FOLDER`" -y"
        Invoke-Expression $extractCommand
        Write-Log "Shaderpacks extraction completed."

        # Clean up the downloaded shaderpacks archive file
        Write-Host "Cleaning up..."
        Write-Log "Cleaning up..."
        Remove-Item $DOWNLOAD_SHADERPACKS_FILE
        Write-Log "Shaderpacks download file deleted."

        Write-Host "Shaderpacks update complete!"
        Write-Log "Shaderpacks update complete!"
    } catch {
        Write-Host "The downloaded shaderpacks file is not a valid ZIP archive. Please check the download link and try again."
        Write-Log "The downloaded shaderpacks file is not a valid ZIP archive. Exception: $_"
        Remove-Item $DOWNLOAD_SHADERPACKS_FILE
    }
} else {
    Write-Host "Download failed. Please check the download link and try again."
    Write-Log "Download failed. The file does not exist at $DOWNLOAD_SHADERPACKS_FILE."
}

# Ensure resourcepacks folder exists
if (-Not (Test-Path $RESOURCEPACKS_FOLDER)) {
    Write-Host "Creating resourcepacks folder..."
    Write-Log "Creating resourcepacks folder..."
    New-Item -ItemType Directory -Force -Path $RESOURCEPACKS_FOLDER
    Write-Log "Resourcepacks folder created."
}

# Download the resourcepacks zip from Google Drive using gdown if it hasn't been downloaded already
if (-Not (Test-Path $DOWNLOAD_RESOURCEPACKS_FILE)) {
    Write-Host "Downloading resourcepacks archive using gdown..."
    Write-Log "Downloading resourcepacks archive using gdown..."

    try {
        $gdownCommand = "gdown $GDRIVE_RESOURCEPACKS_URL -O $DOWNLOAD_RESOURCEPACKS_FILE"
        Write-Log "Running command: $gdownCommand"
        & "python" -c "import gdown; gdown.download('$GDRIVE_RESOURCEPACKS_URL', r'$DOWNLOAD_RESOURCEPACKS_FILE', quiet=False)"
        Write-Log "Download completed."
    } catch {
        Write-Host "Download failed. Please check the download link and try again."
        Write-Log "Download failed: $_"
        exit 1
    }
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_RESOURCEPACKS_FILE) {
    Write-Log "Download file exists."
    # Verify the downloaded file is a valid ZIP file
    Write-Host "Verifying the downloaded archive..."
    Write-Log "Verifying the downloaded archive..."

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($DOWNLOAD_RESOURCEPACKS_FILE)
        $zip.Dispose()
        Write-Log "The downloaded file is a valid ZIP archive."

        # Step 3: Extract the downloaded archive using 7-Zip
        Write-Host "Extracting new resourcepacks with 7-Zip..."
        Write-Log "Extracting new resourcepacks with 7-Zip..."
        $extractCommand = "& `"$7zipPath`" x `"$DOWNLOAD_RESOURCEPACKS_FILE`" -o`"$RESOURCEPACKS_FOLDER`" -y"
        Invoke-Expression $extractCommand
        Write-Log "Extraction completed."

        # Step 4: Clean up the downloaded archive file
        Write-Host "Cleaning up..."
        Write-Log "Cleaning up..."
        Remove-Item $DOWNLOAD_RESOURCEPACKS_FILE
        Write-Log "Download file deleted."

        Write-Host "Resourcepacks update complete!"
        Write-Log "Resourcepacks update complete!"
    } catch {
        Write-Host "The downloaded file is not a valid ZIP archive. Please check the download link and try again."
        Write-Log "The downloaded file is not a valid ZIP archive. Exception: $_"
        Remove-Item $DOWNLOAD_RESOURCEPACKS_FILE
    }
} else {
    Write-Host "Download failed. Please check the download link and try again."
    Write-Log "Download failed. The file does not exist at $DOWNLOAD_RESOURCEPACKS_FILE."
}

# Download the optionsshaders.txt from Google Drive using gdown if it hasn't been downloaded already
if (-Not (Test-Path $DOWNLOAD_OPTIONS_SHADERS_FILE)) {
    Write-Host "Downloading optionsshaders.txt using gdown..."
    Write-Log "Downloading optionsshaders.txt using gdown..."

    try {
        $gdownCommand = "gdown $GDRIVE_OPTIONS_SHADERS_URL -O $DOWNLOAD_OPTIONS_SHADERS_FILE"
        Write-Log "Running command: $gdownCommand"
        & "python" -c "import gdown; gdown.download('$GDRIVE_OPTIONS_SHADERS_URL', r'$DOWNLOAD_OPTIONS_SHADERS_FILE', quiet=False)"
        Write-Log "Download completed."
    } catch {
        Write-Host "Download failed. Please check the download link and try again."
        Write-Log "Download failed: $_"
        exit 1
    }
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_OPTIONS_SHADERS_FILE) {
    Write-Log "Download file exists."
    # Move the downloaded optionsshaders.txt to the Minecraft folder
    Write-Host "Moving optionsshaders.txt to the Minecraft folder..."
    Write-Log "Moving optionsshaders.txt to the Minecraft folder..."
    Move-Item -Force -Path $DOWNLOAD_OPTIONS_SHADERS_FILE -Destination "$EXTRACT_PATH\optionsshaders.txt"
    Write-Log "optionsshaders.txt moved to the Minecraft folder."

    Write-Host "Options shaders update complete!"
    Write-Log "Options shaders update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
    Write-Log "Download failed. The file does not exist at $DOWNLOAD_OPTIONS_SHADERS_FILE."
}

# Download the options.txt from Google Drive using gdown if it hasn't been downloaded already
if (-Not (Test-Path $DOWNLOAD_OPTIONS_FILE)) {
    Write-Host "Downloading options.txt using gdown..."
    Write-Log "Downloading options.txt using gdown..."

    try {
        $gdownCommand = "gdown $GDRIVE_OPTIONS_URL -O $DOWNLOAD_OPTIONS_FILE"
        Write-Log "Running command: $gdownCommand"
        & "python" -c "import gdown; gdown.download('$GDRIVE_OPTIONS_URL', r'$DOWNLOAD_OPTIONS_FILE', quiet=False)"
        Write-Log "Download completed."
    } catch {
        Write-Host "Download failed. Please check the download link and try again."
        Write-Log "Download failed: $_"
        exit 1
    }
}

# Check if the download was successful
if (Test-Path $DOWNLOAD_OPTIONS_FILE) {
    Write-Log "Download file exists."
    # Move the downloaded options.txt to the Minecraft folder
    Write-Host "Moving options.txt to the Minecraft folder..."
    Write-Log "Moving options.txt to the Minecraft folder..."
    Move-Item -Force -Path $DOWNLOAD_OPTIONS_FILE -Destination "$EXTRACT_PATH\options.txt"
    Write-Log "options.txt moved to the Minecraft folder."

    Write-Host "Options update complete!"
    Write-Log "Options update complete!"
} else {
    Write-Host "Download failed. Please check the download link and try again."
    Write-Log "Download failed. The file does not exist at $DOWNLOAD_OPTIONS_FILE."
}

# Restore original execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $originalExecutionPolicy -Force
Write-Log "Restored original execution policy to $originalExecutionPolicy."

Write-Host "Update process complete!"
Write-Log "Update process complete!"
Pause