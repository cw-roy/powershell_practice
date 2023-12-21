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
$machineName = $env:COMPUTERNAME

Write-Host "`nKickstart Deployment for $machineName" -ForegroundColor Yellow


# Restart Service
try {
    Write-Host "`nRestarting SMS Agent Host (CcmExec) service... "
    Restart-Service -Name "CcmExec" -Force -ErrorAction Stop
    Write-Host "Service 'CcmExec' restarted successfully."
}
catch {
    Write-Host "Failed to restart service 'CcmExec'. $_" -ForegroundColor Red
}

Start-Sleep -Seconds 2

# Delete Files
Write-Host "`nDeleting 'TSasUser' files..."
# During testing, use test file names:
$filesToDelete = @("C:\temp\Testfile1.txt", "C:\temp\Testfile2.txt", "C:\temp\Testfile3.log")
# In production, use the actual file names:
# $filesToDelete = @("C:\temp\TSasUserSuccess.txt"; "C:\temp\TSasUserFail.txt"; "C:\temp\Execute-TSasUser.log")

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "    Deleted file: $file"
    }
    else {
        Write-Host "    File not found: $file"
    }
}

Start-Sleep -Seconds 2

# Run Configuration Manager Actions

$TriggerIDs = {
    $SCCMActions = @("{00000000-0000-0000-0000-000000000026}", #User Policy Retrieval
        "{00000000-0000-0000-0000-000000000027}", #User Policy Evaluation
        "{00000000-0000-0000-0000-000000000121}") #Application Deployment

    foreach ($action in $SCCMActions) {
        $result = Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $action

        # Check the result object for success or failure
        if ($result.ReturnValue -eq 0) {
            Write-Host "Action triggered successfully. Execution may take several minutes."
        }
        else {
            Write-Host "Failed to trigger action. ReturnValue: $($result.ReturnValue)"
        }
    }
}

Invoke-Command -ScriptBlock $TriggerIDs

Start-Sleep -Seconds 10

Write-Host "`nActions Completed." -ForegroundColor Green

Pause

