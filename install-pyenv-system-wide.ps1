<#
    .SYNOPSIS
    Installs or uninstalls pyenv-win system-wide on Windows.

    .DESCRIPTION
    This script installs or uninstalls pyenv-win to a system-wide location and sets or removes environment variables for all users.

    .PARAMETER Uninstall
    Uninstall pyenv-win. This uninstalls any Python versions that were installed with pyenv-win.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> .\install-pyenv-system-wide.ps1

    .LINK
    Online version: https://pyenv-win.github.io/pyenv-win/
#>

param (
    [Switch] $Uninstall = $False
)

$pyenvSystemPath = "C:\ProgramData\pyenv"
$pyenvWinDir = "${pyenvSystemPath}\pyenv-win"
$binPath = "${pyenvWinDir}\bin"
$shimsPath = "${pyenvWinDir}\shims"

Function Remove-PyEnvVars {
    $pathParts = [System.Environment]::GetEnvironmentVariable('Path', "Machine") -split ";"
    $newPathParts = $pathParts.Where{ $_ -ne $binPath }.Where{ $_ -ne $shimsPath }
    # $newPathParts = $pathParts | Where-Object { $_ -inotmatch 'pyenv-win' } # Alternative way of getting parts
    $newPath = $newPathParts -join ";"
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, "Machine")

    [System.Environment]::SetEnvironmentVariable('PYENV', $null, "Machine")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', $null, "Machine")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME', $null, "Machine")
}

Function Remove-PyEnv {
    Write-Host "Removing $pyenvSystemPath..."
    If (Test-Path $pyenvSystemPath) {
        Remove-Item -Path $pyenvSystemPath -Recurse
    }
    Write-Host "Removing environment variables..."
    Remove-PyEnvVars
}

Function Install-PyEnv {
    Write-Host "Installing pyenv-win..."
    New-Item -Path $pyenvSystemPath -ItemType Directory -Force

    $downloadPath = "$pyenvSystemPath\pyenv-win.zip"
    (New-Object System.Net.WebClient).DownloadFile("https://github.com/pyenv-win/pyenv-win/archive/master.zip", $downloadPath)
    Expand-Archive -Path $downloadPath -DestinationPath $pyenvSystemPath
    Move-Item -Path "$pyenvSystemPath\pyenv-win-master\*" -Destination "$pyenvSystemPath"
    Remove-Item -Path "$pyenvSystemPath\pyenv-win-master" -Recurse
    Remove-Item -Path $downloadPath

    # Update environment variables
    [System.Environment]::SetEnvironmentVariable('PYENV', "$pyenvWinDir\", "Machine")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "$pyenvWinDir\", "Machine")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "$pyenvWinDir\", "Machine")

    $pathParts = [System.Environment]::GetEnvironmentVariable('Path', "Machine") -split ";"
    $newPathParts = ($binPath, $shimsPath) + $pathParts
    $newPath = $newPathParts -join ";"
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, "Machine")

    Write-Host "pyenv-win is successfully installed."
}

Function Main {
    If ($Uninstall) {
        Remove-PyEnv
        If ($? -eq $True) {
            Write-Host "pyenv-win successfully uninstalled."
        } Else {
            Write-Host "Uninstallation failed."
        }
    } Else {
        Install-PyEnv
    }
}

Main

# Save the Script: Copy the entire script and save it into a file with a .ps1 extension, such as uninstall-pyenv.ps1.

# Open PowerShell: Open a PowerShell window. You might need to run it as an administrator depending on your system's settings.

# Set Execution Policy (if needed): PowerShell scripts are often restricted from running by default for security reasons. To allow the execution of the script, you may need to change the execution policy. You can do this by running:

# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

#This command will allow scripts to be run on your PowerShell session.

# Navigate to the Script: Use the cd command to navigate to the directory where you saved the script. For example:

# cd path\to\directory
# Replace path\to\directory with the actual path where your script is saved.

# Run the Script with the Uninstall Parameter: Now, execute the script with the -Uninstall switch to initiate the uninstallation process. Here's how you do it:

# .\uninstall-pyenv.ps1 -Uninstall

# This command runs the script and activates the uninstallation function within it.

# Follow Any On-screen Instructions: The script may provide instructions or confirmations as it runs. Follow these as necessary.

# Check if Uninstallation was Successful: After running the script, you can verify that pyenv-win has been uninstalled by trying to run pyenv --version in a new PowerShell window. If it's uninstalled, this command should not be recognized.
