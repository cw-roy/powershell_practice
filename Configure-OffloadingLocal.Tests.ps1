# Execute test: "Invoke-Pester -Script .\Configure-OffloadingLocal.ps1 -PassThru | Out-File -FilePath "PesterLog.txt""

Describe "Configure-OffloadingLocal.ps1" {
    $ScriptPath = (Resolve-Path .\Configure-OffloadingLocal.ps1).Path

    # Test the Install-Software function
    Context "Install-Software function" {
        It "Should install software without errors" {
            $installerPath = "C:\Example\Installer.exe"
            $arguments = "/exampleArgument"
            $result = Install-Software -installerPath $installerPath -arguments $arguments
            $result | Should -Contain "Installation completed."
        }
    }

    # Test the Copy-Item operation
    Context "Copy installation files" {
        It "Should copy files without errors" {
            $result = & $ScriptPath
            $result | Should -Contain "File copy completed."
        }
    }

    # Test the registry update for insider releases
    Context "Update registry for insider releases" {
        It "Should enable insider releases without errors" {
            $result = & $ScriptPath
            $result | Should -Contain "Insider releases enabled."
        }
    }

    # Test the registry update for call redirection
    Context "Update registry for call redirection" {
        It "Should enable call redirection without errors" {
            $result = & $ScriptPath
            $result | Should -Contain "Call redirection for all sites enabled."
        }
    }

    # Test the installation of Visual C++ Redistributable
    Context "Install Visual C++ Redistributable" {
        It "Should install without errors" {
            $result = & $ScriptPath
            $result | Should -Contain "Installation of Microsoft Visual C++ Redistributable completed."
        }
    }
}
