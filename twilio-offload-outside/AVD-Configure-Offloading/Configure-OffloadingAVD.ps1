# Script name: Configure-OffloadingAVD.ps1

# Installs x86 and x64 Microsoft Visual C++ Redistributable 2015-2022.
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

# Prompt user to start or cancel
$keypress = $Host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho").Character

if ($keypress -eq 'x' -or $keypress -eq 'X') {
    Write-Host "`nOperation canceled."
    Exit
} 
else {
    Write-Host "`nStarting process..."
}

# Install files
$sourceFolder = "\\VMKIP-DANPMMSC\Support$\Techs\Curtis Roy\offload_script_files\InstallerSource"
$x64vcRedistInstallerFilename = "VC_redist.x64.exe"
$x86vcRedistInstallerFilename = "VC_redist.x86.exe"
$mmrInstallerFilename = "MsMMRHostInstaller_1.0.2309.7002_x64.msi"

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

# Install MMR Host
$mmrInstallerPath = Join-Path -Path $sourceFolder -ChildPath $mmrInstallerFilename
$mmrInstallArguments = "/i `"$mmrInstallerPath`" /qn"

Write-Host "`nInstalling Multimedia Redirection Host..."
$mmrInstallProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList $mmrInstallArguments -PassThru -Wait

if ($mmrInstallProcess.ExitCode -eq 0) {
    Write-Host "Installation of Multimedia Redirection Host completed."
}
else {
    Write-Host "Installation ended with non-zero exit code $($mmrInstallProcess.ExitCode)."
}

# Registry edits after software installation (logged-in user)
$callRedirectionRegistryPath = "HKCU:\SOFTWARE\Microsoft\MMR"
$callRedirectionPropertyName = "AllowCallRedirectionAllSites"
$callRedirectionPropertyValue = 1

Write-Host "`nAdding registry entries to enable call redirection for all sites..."
New-Item -Path $callRedirectionRegistryPath -Force  | Out-Null
New-ItemProperty -Path $callRedirectionRegistryPath -Name $callRedirectionPropertyName -PropertyType DWORD -Value $callRedirectionPropertyValue -Force | Out-Null
Write-Host "Registry entries completed."
Start-Sleep -Seconds 2

Write-Host "`nLaunching browser(s) to extension page..."
# Launch Edge
Write-Host "`nLaunching Edge..."
$edgeUrl = "https://microsoftedge.microsoft.com/addons/detail/wvd-multimedia-redirectio/joeclbldhdmoijbaagobkhlpfjglcihd"
Start-Process -FilePath "msedge.exe" -ArgumentList "--start-minimized", $edgeUrl 
Start-Sleep -Seconds 2

# Launch Chrome if installed
$chromeExecutable = Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe"
$chromeInstalled = Test-Path "$chromeExecutable"

if ($chromeInstalled) {
    Write-Host "`nLaunching Chrome..."
    $chromeUrl = "https://chrome.google.com/webstore/detail/wvd-multimedia-redirectio/lfmemoeeciijgkjkgbgikoonlkabmlno"
    Start-Process -FilePath "chrome.exe" -WindowStyle Minimized -ArgumentList $chromeUrl
    Start-Sleep -Seconds 2
}
else {
    Write-Host "`nChrome is not installed. Skipping Chrome configuration step."
}

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

Start-Sleep -Seconds 2

# Script complete.