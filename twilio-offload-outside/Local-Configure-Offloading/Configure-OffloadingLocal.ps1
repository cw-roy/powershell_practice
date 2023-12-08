# Script name: Configure-OffloadingLocal.ps1

# Installs Remote Desktop Client.
# Installs Microsoft Visual C++ Redistributable 2015-2022 (x64 and x86).
# Adds registry entries.

# Check if the script is run as Administrator, relaunch if not
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    Exit
}

# Announcement
Write-Host "`n-----This is to be run on the local machine-----" -ForegroundColor Red
Write-Host "`n-----Local Multimedia redirect for Twilio-----" -ForegroundColor Yellow

# Prompt user to start or cancel
Write-Host "`nPress any key to start or X to cancel"

$keypress = $Host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho").Character

if ($keypress -eq 'x' -or $keypress -eq 'X') {
    Write-Host "`nOperation canceled."
    Exit
} 
else {
    Write-Host "`nStarting process..."
}

# Location of installation files
$sourceFolder = "\\VMKIP-DANPMMSC\Support$\Techs\Curtis Roy\offload_script_files\InstallerSource"
$x64vcRedistInstallerFilename = "VC_redist.x64.exe"
$x86vcRedistInstallerFilename = "VC_redist.x86.exe"
$rdpInstallerFilename = "RemoteDesktop_1.2.4763.0_x64.msi"
$rdpInstallerPath = Join-Path -Path $sourceFolder -ChildPath $rdpInstallerFilename


# Install Remote Desktop client
$rdpInstallArguments = "/i `"$rdpInstallerPath`" /qn ALLUSERS=1"

Write-Host "`nInstalling Insider version of Remote Desktop client..."

$rdpInstallProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList $rdpInstallArguments -PassThru -Wait
if ($rdpInstallProcess.ExitCode -eq 0) {
    Write-Host "Installation of Microsoft Remote Desktop Client completed successfully."
}
else {
    Write-Host "Installation failed with exit code $($rdpInstallProcess.ExitCode)."
}

# Registry edits after software installation (Local Machine)
$insiderRegistryPath = "HKLM:\SOFTWARE\Microsoft\MSRDC\Policies"
$insiderPropertyName = "ReleaseRing"
$insiderPropertyValue = "insider"

Write-Host "`nEditing registry to enable insider releases..."
New-Item -Path $insiderRegistryPath -Force | Out-Null
New-ItemProperty -Path $insiderRegistryPath -Name $insiderPropertyName -PropertyType String -Value $insiderPropertyValue -Force | Out-Null
Write-Host "Insider releases enabled."

# Install Microsoft Visual C++ Redistributable 2015-2022 x64
$x64vcRedistInstallerFilePath = Join-Path -Path $sourceFolder -ChildPath $x64vcRedistInstallerFilename
$x64vcRedistInstallerArguments = "/install /quiet /norestart"

Write-Host "`nInstalling Microsoft Visual C++ Redistributable x64..."
$x64InstallProcess = Start-Process -FilePath $x64vcRedistInstallerFilePath -ArgumentList $x64vcRedistInstallerArguments -PassThru -Wait

if ($x64InstallProcess.ExitCode -eq 0 -or 3010) {
    Write-Host "Installation of Microsoft Visual C++ Redistributable x64 completed."
}
else {
    Write-Host "Installation ended with non-zero exit code $($x64InstallProcess.ExitCode)."
}

# Install Microsoft Visual C++ Redistributable 2015-2022 x86
$x86vcRedistInstallerFilePath = Join-Path -Path $sourceFolder -ChildPath $x86vcRedistInstallerFilename
$x86vcRedistInstallerArguments = "/install /quiet /norestart"

Write-Host "`nInstalling Microsoft Visual C++ Redistributable x86..."
$x86InstallProcess = Start-Process -FilePath $x86vcRedistInstallerFilePath -ArgumentList $x86vcRedistInstallerArguments -PassThru -Wait

if ($x86InstallProcess.ExitCode -eq 0 -or 3010) {
    Write-Host "Installation of Microsoft Visual C++ Redistributable x86 completed."
}
else {
    Write-Host "Installation ended with non-zero exit code $($x86InstallProcess.ExitCode)."
}

# Registry edits after software installation (logged-in user)
$callRedirectionRegistryPath = "HKCU:\SOFTWARE\Microsoft\MMR"
$callRedirectionPropertyName = "AllowCallRedirectionAllSites"
$callRedirectionPropertyValue = 1

Write-Host "`nEditing registry to enable call redirection for all sites..."
New-Item -Path $callRedirectionRegistryPath -Force | Out-Null
New-ItemProperty -Path $callRedirectionRegistryPath -Name $callRedirectionPropertyName -PropertyType DWORD -Value $callRedirectionPropertyValue -Force | Out-Null
Write-Host "Registry entries completed."

Write-Host "`nConfiguration Complete." -ForegroundColor Green

# Prompt user to reboot or postpone
Write-Host "`n`nPress 'R' to reboot. Press any other key to quit and reboot manually."
$key = $Host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho").Character

if ($key -eq 'R' -or $key -eq 'r') {
    Write-Host "`nRebooting the PC..."
    Restart-Computer -Force
}
else {
    Write-Host "`nReboot cancelled. IMPORTANT: reboot at your earliest opportunity." -ForegroundColor Red
}

Start-Sleep -Seconds 2