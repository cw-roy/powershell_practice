# Your script starts here...

# Location to copy installation files
$localInstallFolder = "C:\Temp\LocalInstallFiles"

# Create the local install folder if it doesn't exist
if (-not (Test-Path $localInstallFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $localInstallFolder | Out-Null
}

# Copy installation files to the local directory
Write-Host "`nCopying installation files to local directory..."
Copy-Item -Path $sourceFolder\* -Destination $localInstallFolder -Recurse
Write-Host "File copy completed."

# Install Microsoft Visual C++ Redistributable 2015-2022 x64
$x64vcRedistInstallerFilename = "VC_redist.x64.exe"
$x64vcRedistInstallerFilePath = Join-Path -Path $localInstallFolder -ChildPath $x64vcRedistInstallerFilename
$x64vcRedistInstallerArguments = "/install /quiet /norestart"

# Start the spinner for visual feedback
$spinner = Start-Spinner -Message "Installing Microsoft Visual C++ Redistributable x64"

# Run the installation process
$x64InstallProcess = Start-Process -FilePath $x64vcRedistInstallerFilePath -ArgumentList $x64vcRedistInstallerArguments -PassThru -Wait

# Stop the spinner after the installation
Stop-Spinner -SpinnerTimer $spinner

# Check the exit code and display the result
if ($x64InstallProcess.ExitCode -eq 0) {
    Write-Host "Installation of Microsoft Visual C++ Redistributable x64 completed."
} else {
    Write-Host "Installation ended with non-zero exit code $($x64InstallProcess.ExitCode)."
}

# Repeat the same process for other installations...

# Your script continues...
