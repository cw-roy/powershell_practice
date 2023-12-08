function Start-Spinner {
    param (
        [string]$Message = "Processing"
    )
    $spinner = 0
    $spinnerChars = @('-', '\', '|', '/')
    $spinnerInterval = 100  # milliseconds

    $spinnerTimer = New-Object System.Timers.Timer
    $spinnerTimer.Interval = $spinnerInterval
    $spinnerTimer.AutoReset = $true

    $spinnerTimer.add_Elapsed({
        Write-Host -NoNewline "$Message $($spinnerChars[$spinner % 4])`r"
        $spinner++
    })

    $spinnerTimer.Start()

    return $spinnerTimer
}

function Stop-Spinner {
    param (
        [System.Timers.Timer]$SpinnerTimer
    )
    $SpinnerTimer.Stop()
    Write-Host -NoNewline "`r"  # Clear the spinner line
}

# Your script starts here

# ...

# Example usage of the spinner
$spinner = Start-Spinner -Message "Installing Microsoft Visual C++ Redistributable x64"

# Install Microsoft Visual C++ Redistributable 2015-2022 x64
$x64vcRedistInstallerFilename = "VC_redist.x64.exe"
$x64vcRedistInstallerFilePath = Join-Path -Path $sourceFolder -ChildPath $x64vcRedistInstallerFilename
$x64vcRedistInstallerArguments = "/install /quiet /norestart"

# Your installation process here...

# Stop the spinner after the installation step
Stop-Spinner -SpinnerTimer $spinner

# ...

# Repeat the spinner for other steps if needed

# Your script continues...
