# Script name: Configure-OffloadingLocal.ps1
# Function to install software and edit registry
function Install-Software {
    param (
        [string]$installerPath,
        [string]$arguments
    )

    Write-Host "Installing: $($installerPath.Split('\')[-1])"
    Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait
    Write-Host "Installation completed."
}

# Copy installation files to a local directory
$sourceFolder = "\\vmkip-danpmmsc\support$\Techs\Tech_name\offload_script_files"
$destinationFolder = "C:\Temp\Installers"

Write-Host "Copying installation files to local directory..."
Copy-Item -Path $sourceFolder -Destination $destinationFolder -Recurse
Write-Host "File copy completed."

# Install Remote Desktop client
$rdpInstaller = Join-Path $destinationFolder "RemoteDesktopInstaller.msi"
Install-Software -installerPath "msiexec.exe" -arguments "/i $rdpInstaller /qn"

# Update registry for insider releases (run as Administrator)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguments = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Write-Host "Script is not running as Administrator. Relaunching with elevated privileges..."
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    return
}

$insiderRegistryPath = "HKLM:\SOFTWARE\Microsoft\MSRDC\Policies"
$insiderPropertyName = "ReleaseRing"
$insiderPropertyValue = "insider"

# Create registry key and set value
Write-Host "Enabling insider releases..."
New-Item -Path $insiderRegistryPath -Force
New-ItemProperty -Path $insiderRegistryPath -Name $insiderPropertyName -PropertyType String -Value $insiderPropertyValue -Force
Write-Host "Insider releases enabled."

# Update registry for call redirection (run as logged-in user)
# No need to check for elevation as this part should be run as the user

$callRedirectionRegistryPath = "HKCU:\SOFTWARE\Microsoft\MMR"
$callRedirectionPropertyName = "AllowCallRedirectionAllSites"
$callRedirectionPropertyValue = 1

# Create registry key and set value
Write-Host "Enabling call redirection for all sites..."
New-Item -Path $callRedirectionRegistryPath -Force
New-ItemProperty -Path $callRedirectionRegistryPath -Name $callRedirectionPropertyName -PropertyType DWORD -Value $callRedirectionPropertyValue -Force
Write-Host "Call redirection for all sites enabled."

# Install Microsoft Visual C++ Redistributable 2015-2022
$vcRedistInstaller = Join-Path $destinationFolder "vc_redist.x64.exe"
Write-Host "Beginning installation of Microsoft Visual C++ Redistributable..."
Install-Software -installerPath $vcRedistInstaller -arguments "/install /quiet /norestart"
Write-Host "Installation of Microsoft Visual C++ Redistributable completed."

Write-Host "Overall script completed."

# Pause for user input
Read-Host "Press Enter to continue..."
