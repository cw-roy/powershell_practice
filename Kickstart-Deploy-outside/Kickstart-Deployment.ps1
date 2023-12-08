# Script name: Kickstart-Deployment.ps1

# Performs the following:
# Restart the "SMS Agent Host" service
# Delete files from C:\Temp if they exist
#   C:\temp\TSasUserSuccess.txt
#   C:\temp\TSasUserFail.txt
#   C:\temp\Execute-TSasUser.log
# Run the following in Configuration Manager
#   1. User Policy Retrieval & Evaluation Cycle
#   2. Application Deployment Evaluation Cycle

# Check if the script is run as Administrator, relaunch if not
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    Exit
}

# Get the current machine name
$machineName = $ENV:COMPUTERNAME

Write-Host "`nKickstart Deployment for $machineName" -ForegroundColor Yellow


# Restart Service
try {
    Write-Host "`nRestarting SMS Agent Host (CcmExec) service... "
    Restart-Service -Name "CcmExec" -Force -ErrorAction Stop
    Write-Host "Service 'CcmExec' restarted successfully."
} catch {
    Write-Host "Failed to restart service 'CcmExec'. $_" -ForegroundColor Red
}

Start-Sleep -Seconds 2

# Delete Files
Write-Host "`nDeleting 'TSasUser' files..."
# During testing, use test files:
$filesToDelete = @("C:\temp\Testfile1.txt", "C:\temp\Testfile2.txt", "C:\temp\Testfile3.log")
# In production, uncomment next line:
# $filesToDelete = @("C:\temp\TSasUserSuccess.txt"; "C:\temp\TSasUserFail.txt"; "C:\temp\Execute-TSasUser.log")

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "    Deleted file: $file"
    } else {
        Write-Host "    File not found: $file"
    }
}

Start-Sleep -Seconds 2

# Run Configuration Manager Actions

# Application Deployment Evaluation Cycle
Write-Host = "`nRunning Application Deployment Evaluation Cycle..."
$appDeployTrigger = "{00000000-0000-0000-0000-000000000121}"
Invoke-WmiMethod -ComputerName $machineName -Namespace root\ccm -Class SMS_CLIENT TriggerSchedule $appDeployTrigger

Start-Sleep -Seconds 10

# User Policy Evaluation Cycle
Write-Host "`nRunning User Policy Evaluation Cycle..."
$userPolicyEvalTrigger = "{00000000-0000-0000-0000-000000000027}"
Invoke-WmiMethod -ComputerName $machineName -Namespace root\ccm -Class SMS_CLIENT TriggerSchedule $userPolicyEvalTrigger

Start-Sleep -Seconds 10

Write-Host "`nActions Completed." -ForegroundColor Green

Pause

