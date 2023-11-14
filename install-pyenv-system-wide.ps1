<#
    .SYNOPSIS
    Installs or uninstalls pyenv-win system-wide on Windows.

    .DESCRIPTION
    This script installs or uninstalls pyenv-win to "C\:Program Files\pyenv", a system-wide location and sets or removes environment variables for all users.
    If pyenv-win is already installed, try to update to the latest version.

    .PARAMETER Uninstall
    Uninstall pyenv-win. This uninstalls any Python versions that were installed with pyenv-win.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> .\install-pyenv-system-wide.ps1 [-Uninstall]

    .LINK
    Online version: https://github.com/CMU-Pitt-BRIDGE/psychopy-setup/blob/main/install-pyenv-system-wide.ps1
#>

param (
    [Switch] $Uninstall = $False
)

$pyenvSystemPath = "C:\Program Files\pyenv"
$pyenvWinDir = "${pyenvSystemPath}\pyenv-win"
$binPath = "${pyenvWinDir}\bin"
$shimsPath = "${pyenvWinDir}\shims"

Function Remove-PyEnvVars {
    $pathParts = [System.Environment]::GetEnvironmentVariable('PATH', "Machine") -Split ";"
    $newPathParts = $pathParts.Where{ $_ -ne $binPath }.Where{ $_ -ne $shimsPath }
    # $newPathParts = $pathParts | Where-Object { $_ -inotmatch 'pyenv-win' } # Alternative way of getting parts
    $newPath = $newPathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $newPath, "Machine")

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

Function Get-CurrentVersion() {
    $VersionFilePath = "$pyenvSystemPath\.version"
    If (Test-Path $VersionFilePath) {
        $CurrentVersion = Get-Content $VersionFilePath
    }
    Else {
        $CurrentVersion = ""
    }

    Return $CurrentVersion
}

Function Get-LatestVersion() {
    $LatestVersionFilePath = "$pyenvSystemPath\latest.version"
    (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/.version", $LatestVersionFilePath)
    $LatestVersion = Get-Content $LatestVersionFilePath

    Remove-Item -Path $LatestVersionFilePath

    Return $LatestVersion
}

Function Install-PyEnv {

    $BackupDir = "${env:Temp}/pyenv-win-backup"

    $CurrentVersion = Get-CurrentVersion
    If ($CurrentVersion) {
        Write-Host "pyenv-win $CurrentVersion installed."
        $LatestVersion = Get-LatestVersion
        If ($CurrentVersion -eq $LatestVersion) {
            Write-Host "No updates available."
            exit
        }
        Else {
            Write-Host "New version available: $LatestVersion. Updating..."

            Write-Host "Backing up existing Python installations..."
            $FoldersToBackup = "install_cache", "versions", "shims"
            ForEach ($Dir in $FoldersToBackup) {
                If (-not (Test-Path $BackupDir)) {
                    New-Item -ItemType Directory -Path $BackupDir
                }
                Move-Item -Path "${pyenvWinDir}/${Dir}" -Destination $BackupDir
            }

            Write-Host "Removing $pyenvSystemPath..."
            Remove-Item -Path $pyenvSystemPath -Recurse
        }
    }

    Write-Host "Installing pyenv-win..."
    New-Item -Path $pyenvSystemPath -ItemType Directory -Force

    # Alternative installation method
    # git clone https://github.com/pyenv-win/pyenv-win.git $pyenvSystemPath

    $DownloadPath = "$pyenvSystemPath\pyenv-win.zip"

    (New-Object System.Net.WebClient).DownloadFile("https://github.com/pyenv-win/pyenv-win/archive/master.zip", $DownloadPath)
    Microsoft.PowerShell.Archive\Expand-Archive -Path $DownloadPath -DestinationPath $pyenvSystemPath
    Move-Item -Path "$pyenvSystemPath\pyenv-win-master\*" -Destination "$pyenvSystemPath"
    Remove-Item -Path "$pyenvSystemPath\pyenv-win-master" -Recurse
    Remove-Item -Path $DownloadPath

    # Update environment variables
    [System.Environment]::SetEnvironmentVariable('PYENV', "${pyenvWinDir}\", "Machine")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${pyenvWinDir}\", "Machine")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${pyenvWinDir}\", "Machine")

    $pathParts = [System.Environment]::GetEnvironmentVariable('PATH', "Machine") -Split ";"

    # Remove existing paths, so we don't add duplicates
    $newPathParts = $pathParts.Where{ $_ -ne $binPath }.Where{ $_ -ne $shimsPath }
    $newPathParts = @($binPath, $shimsPath) + $newPathParts
    $newPath = $newPathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "Machine")

    If (Test-Path $BackupDir) {
        Write-Host "Restoring Python installations..."
        Move-Item -Path "$BackupDir/*" -Destination $pyenvWinDir
    }

    If ($? -eq $True) {
        Write-Host "pyenv-win is successfully installed. You may need to close and reopen your terminal before using it."
    }
    Else {
        Write-Host "pyenv-win was not installed successfully. If this issue persists, please open a ticket: https://github.com/pyenv-win/pyenv-win/issues."
    }
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