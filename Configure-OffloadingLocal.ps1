# Script name: Configure-OffloadingLocal.ps1

# Installs Remote Desktop Client.
# Installs Microsoft Visual C++ Redistributable 2015-2022.
# Adds registry entries.

# Check if the script is run as Administrator, relaunch if not
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    Exit
}

# Announcement
Write-Host "-----Multimedia redirect for Twilio-----" -ForegroundColor Yellow

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
}
else {
    Write-Host "`nStarting the operation..."
}

# Copy installation files to a local directory.
# In development phase, $sourceFolder is a local file path.
# Change $sourceFolder to network path in production.
$sourceFolder = "C:\Temp\InstallerSource"
$destinationFolder = "C:\Temp\InstallFiles"

Write-Host "`nCopying installation files to local directory..."
Copy-Item -Path $sourceFolder\* -Destination $destinationFolder -Recurse
Write-Host "File copy completed."

# Install Remote Desktop client (requires admin rights)
$rdpInstallerPath = "C:\Temp\InstallFiles\RemoteDesktop_1.2.4763.0_x64.msi"
$rdpInstallArguments = "/i $rdpInstallerPath /qn"

Write-Host "`nInstalling Remote Desktop client..."
Start-Process -FilePath "msiexec.exe" -ArgumentList $rdpInstallArguments -Wait
Write-Host "Remote Desktop client installation completed."

# Registry edits after software installation (Local Machine)
$insiderRegistryPath = "HKLM:\SOFTWARE\Microsoft\MSRDC\Policies"
$insiderPropertyName = "ReleaseRing"
$insiderPropertyValue = "insider"

Write-Host "`nEnabling insider releases..."
New-Item -Path $insiderRegistryPath -Force | Out-Null
New-ItemProperty -Path $insiderRegistryPath -Name $insiderPropertyName -PropertyType String -Value $insiderPropertyValue -Force | Out-Null
Write-Host "Insider releases enabled."

# Install Microsoft Visual C++ Redistributable 2015-2022
$vcRedistInstallerPath = "C:\Temp\InstallFiles\VC_redist.x86.exe"
$vcRedistInstallArguments = "/install /quiet /norestart"

Write-Host "`nInstalling Microsoft Visual C++ Redistributable..."
Start-Process -FilePath $vcRedistInstallerPath -ArgumentList $vcRedistInstallArguments -Wait
Write-Host "Installation of Microsoft Visual C++ Redistributable completed."

# Registry edits after software installation (logged-in user)
$callRedirectionRegistryPath = "HKCU:\SOFTWARE\Microsoft\MMR"
$callRedirectionPropertyName = "AllowCallRedirectionAllSites"
$callRedirectionPropertyValue = 1

Write-Host "`nEnabling call redirection for all sites..."
New-Item -Path $callRedirectionRegistryPath -Force  | Out-Null
New-ItemProperty -Path $callRedirectionRegistryPath -Name $callRedirectionPropertyName -PropertyType DWORD -Value $callRedirectionPropertyValue -Force | Out-Null
Write-Host "Call redirection for all sites enabled."

Write-Host "`nConfiguration Complete." -ForegroundColor Green

# Prompt user to press a specific key to reboot
Write-Host "`n`nPress 'R' to reboot. Press any other key to quit and reboot manually."
$key = $Host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho").Character

if ($key -eq 'R' -or $key -eq 'r') {
    Write-Host "`nRebooting the PC..."
    Restart-Computer -Force
}
else {
    Write-Host "`nReboot cancelled. IMPORTANT: reboot at your earliest opportunity." -ForegroundColor Red
}

Start-Sleep -Seconds 3

# Script complete.