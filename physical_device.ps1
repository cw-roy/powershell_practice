# Install files are currently located at \\vmkip-danpmmsc\support$\Techs\Curtis Roy\offload_script_files

# Install Remote Desktop Client
$remoteDesktopInstallerPath = "\\vmkip-danpmmsc\support$\Techs\Curtis Roy\offload_script_files\RemoteDesktop_1.2.4763.0_x64.msi"
Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$RemoteDesktopInstallerPath`" /quiet" -Wait

# Registry edits to allow Insider releases
$regedit1 = 'New-Item -Path "HKLM:\SOFTWARE\Microsoft\MSRDC\Policies" -Force'
$regedit2 = 'New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSRDC\Policies" -Name ReleaseRing -PropertyType String -Value insider -Force'
Start-Process powershell.exe -Verb RunAs -ArgumentList "-Command $regedit1; $regedit2"

# Install Microsoft Visual C++ Redistributable 2015-2022, version 14.32.31332.0 or later
$redistributabeInstallerPath = "\\vmkip-danpmmsc\support$\Techs\Curtis Roy\offload_script_files\VC_redist.x86.exe"
Start-Process -FilePath $redistributabeInstallerPath -ArgumentList "/quiet" -Wait
