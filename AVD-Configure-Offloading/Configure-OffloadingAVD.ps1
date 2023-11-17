# Script name: Configure-OffloadingAVD.ps1

# Installs Remote Desktop Client. ?? NECESSARY FOR AVD? WON'T KNOW UNTIL TESTED"

# Installs Microsoft Visual C++ Redistributable 2015-2022.
# Installs the host component of MultiMedia Redirection.
# Adds registry entries.

# Check if the script is run as Administrator, relaunch if not
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    Exit
}

# Announcement
Write-Host "`n-----This is to be run on the AVD-----" -ForegroundColor Red
Write-Host "`n-----AVD Multimedia redirect configuration for Twilio-----" -ForegroundColor Yellow

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

# # Install MMR Host (requires admin rights)
# $mmrInstallerPath = "C:\Temp\InstallFiles\MsMMRHostInstaller_1.0.2309.7002_x64.msi"
# $mmrInstallArguments = "/i $mmrInstallerPath /qn"

# Write-Host "`nInstalling MMR Host..."
# Start-Process -FilePath "msiexec.exe" -ArgumentList $mmrInstallArguments -Wait
# Write-Host "MMR Host installation completed."

# # Registry edits after software installation (logged-in user)
# $callRedirectionRegistryPath = "HKCU:\SOFTWARE\Microsoft\MMR"
# $callRedirectionPropertyName = "AllowCallRedirectionAllSites"
# $callRedirectionPropertyValue = 1

# Write-Host "`nEnabling call redirection for all sites..."
# New-Item -Path $callRedirectionRegistryPath -Force  | Out-Null
# New-ItemProperty -Path $callRedirectionRegistryPath -Name $callRedirectionPropertyName -PropertyType DWORD -Value $callRedirectionPropertyValue -Force | Out-Null
# Write-Host "Call redirection for all sites enabled."

# Launch browser and enable extension
# Prompt user to choose a browser
# Write-Host "`nYou will be prompted to enable the 'Microsoft MultiMedia Redirection Extension' after the browser window opens."
# Write-Host "Click 'Turn on Extension' when prompted. The prompt may take a moment to appear."
# Write-Host "Choose browser:"
# Write-Host "  [E] Edge"
# Write-Host "  [C] Chrome"

# # Check for keypress without waiting for Enter
# while (-not [Console]::KeyAvailable) {
#     Start-Sleep -Milliseconds 50
# }

# # Read the pressed key
# $browserChoice = [Console]::ReadKey().Key

# Set browser executable path based on user choice
# if ($browserChoice -eq 'E' -or $browserChoice -eq 'e') {
#     $browserPath = "msedge.exe"
# } elseif ($browserChoice -eq 'C' -or $browserChoice -eq 'c') {
#     $browserPath = "chrome.exe"
# } else {
#     Write-Host "`nInvalid choice. Exiting script."
#     Exit
# }

# Launch the selected browser to a blank page
# Start-Process -FilePath $browserPath -ArgumentList "about:blank"

# # Wait for the browser to be closed
# Write-Host "`nWaiting for the browser to be closed..."
# while (Get-Process -Name $browserPath -ErrorAction SilentlyContinue) {
#     Start-Sleep -Seconds 1
# }

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