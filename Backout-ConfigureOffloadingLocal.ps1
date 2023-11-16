# Script name: Backout-ConfigureOffloadingLocal2.ps1
# Backs out installs and registry edits performed by Configure-OffloadingLocal.ps1

# Check if the script is run as Administrator, relaunch if not
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    Exit
}

# Remove registry edits (admin)
$insiderRegistryPath = "HKLM:\SOFTWARE\Microsoft\MSRDC"

Write-Host "Removing insider releases..."
Remove-Item -Path $insiderRegistryPath -Recurse -Force
Write-Host "Insider releases removed."

# Uninstall Remote Desktop client (requires admin rights)
$rdpInstallerPath = "C:\Temp\InstallFiles\RemoteDesktop_1.2.4763.0_x64.msi"
$uninstallArguments = "/x $rdpInstallerPath /quiet"

# Uninstall Remote Desktop client
Write-Host "Uninstalling Remote Desktop client..."
Start-Process -FilePath "msiexec.exe" -ArgumentList $uninstallArguments -Wait
Write-Host "Remote Desktop client uninstallation completed."

# Remove installation files
$destinationFolder = "C:\Temp\InstallFiles"

Write-Host "Removing installation files..."
Remove-Item -Path "$destinationFolder\*" -Recurse -Force
Write-Host "Installation files removed."
