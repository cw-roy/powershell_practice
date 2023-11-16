# Script name: Configure-OffloadingLocal2.ps1
# Installs Remote Desktop Client and adds registry entries.
# TODO - Install C++ Redistributable 2015-2022 and perform associated registry entries.

# Check if the script is run as Administrator, relaunch if not
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    Exit
}

# Copy installation files to a local directory
$sourceFolder = "C:\Temp\InstallerSource"
$destinationFolder = "C:\Temp\InstallFiles"

Write-Host "Copying installation files to local directory..."
Copy-Item -Path $sourceFolder\* -Destination $destinationFolder -Recurse
Write-Host "File copy completed."

# Install Remote Desktop client (requires admin rights)
$rdpInstallerPath = "C:\Temp\InstallFiles\RemoteDesktop_1.2.4763.0_x64.msi"
$rdpInstallArguments = "/i $rdpInstallerPath /qn"

Write-Host "Installing Remote Desktop client..."
Start-Process -FilePath "msiexec.exe" -ArgumentList $rdpInstallArguments -Wait
Write-Host "Remote Desktop client installation completed."

# Registry edits after software installation (admin)
$insiderRegistryPath = "HKLM:\SOFTWARE\Microsoft\MSRDC\Policies"
$insiderPropertyName = "ReleaseRing"
$insiderPropertyValue = "insider"

Write-Host "Enabling insider releases..."
New-Item -Path $insiderRegistryPath -Force
New-ItemProperty -Path $insiderRegistryPath -Name $insiderPropertyName -PropertyType String -Value $insiderPropertyValue -Force
Write-Host "Insider releases enabled."

# Install C++ Redistributable
