# Script name: Backout-ConfigureOffloadingLocal.ps1
# Backs out installs and registry edits performed by Configure-OffloadingLocal.ps1

# Check if the script is run as Administrator, relaunch if not
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    Exit
}

# Announcement
Write-Host "Back out changes performed by Configure-OffloadingLocal.ps1." -ForegroundColor Yellow

# Prompt user to press any key to start or X to cancel
Write-Host "`nPress any key to start or X to cancel"

# Check for keypress without waiting for Enter
while (-not [Console]::KeyAvailable) {
    Start-Sleep -Milliseconds 50  # Adjust the sleep duration as needed
}

# Read the pressed key
$key = [Console]::ReadKey()

if ($key.Key -eq 'X' -or $key.Key -eq 'x') {
    Write-Host "`nOperation canceled. No action taken."
    Exit
} else {
    Write-Host "`nStarting the operation..."
}

# Remove registry edits (user)
$callRedirectionRegistryPath = "HKCU:\SOFTWARE\Microsoft\MMR"

Write-Host "`nRemoving call redirection registry edits..."
Remove-Item -Path $callRedirectionRegistryPath -Recurse -Force
Write-Host "Call redirection registry edits removed."

# Uninstall Microsoft Visual C++ Redistributable 2015-2022
$vcRedistInstallerPath = "C:\Temp\InstallFiles\VC_redist.x86.exe"
$vcRedistUninstallArguments = "/uninstall /quiet /norestart"

Write-Host "`nUninstalling Microsoft Visual C++ Redistributable..."
Start-Process -FilePath $vcRedistInstallerPath -ArgumentList $vcRedistUninstallArguments -Wait
Write-Host "Uninstallation of Microsoft Visual C++ Redistributable completed."

# Remove registry edits (admin)
$insiderRegistryPath = "HKLM:\SOFTWARE\Microsoft\MSRDC"

Write-Host "`nRemoving insider releases registry entries..."
Remove-Item -Path $insiderRegistryPath -Recurse -Force
Write-Host "Insider releases registry entries removed."

# Uninstall Remote Desktop client (requires admin rights)
$rdpInstallerPath = "C:\Temp\InstallFiles\RemoteDesktop_1.2.4763.0_x64.msi"
$uninstallArguments = "/x $rdpInstallerPath /quiet"

# Uninstall Remote Desktop client
Write-Host "`nUninstalling Remote Desktop client..."
Start-Process -FilePath "msiexec.exe" -ArgumentList $uninstallArguments -Wait
Write-Host "Remote Desktop client uninstallation completed."

# Remove installation files
$destinationFolder = "C:\Temp\InstallFiles"

Write-Host "`nRemoving installation files..."
Remove-Item -Path "$destinationFolder\*" -Recurse -Force
Write-Host "Installation files removed."
Write-Host "`nBackout completed." -ForegroundColor Green

Start-Sleep -Seconds 3