<#
    .SYNOPSIS
    Installs or uninstalls Poetry system-wide on Windows.

    .DESCRIPTION
    This script installs or uninstalls Poetry to a system-wide location, ensuring it's installed in a dedicated virtual environment.

    .PARAMETER Uninstall
    Uninstall Poetry. This removes Poetry from the system.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> .\install-poetry-system-wide.ps1 [-Uninstall]

    .LINK
    Online version: https://python-poetry.org/docs/
#>

param (
    [Switch] $Uninstall = $False
)

$poetryHome = "C:\Program Files\pypoetry"
$poetryPath = "${poetryHome}\venv\Scripts"

Function Remove-PoetryVars {
    $pathParts = [System.Environment]::GetEnvironmentVariable('Path', "Machine") -split ";"
    $newPathParts = $pathParts | Where-Object { $_ -inotmatch 'Python\\Scripts' } # Alternative way of getting parts

    $newPath = $newPathParts -join ";"
    [System.Environment]::SetEnvironmentVariable('POETRY_HOME', $null, "Machine")
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, "Machine")
}

Function Remove-Poetry {
    Write-Host "Removing Poetry..."
    If (Test-Path $poetryHome) {
        Remove-Item -Path $poetryHome -Recurse
        # Have to remove Poetry Wrapper as well
    }
    Write-Host "Removing Poetry from PATH..."
    Remove-PoetryVars
}

Function Install-Poetry {
    Write-Host "Installing Poetry..."
    New-Item -Path $poetryHome -ItemType Directory -Force

    [System.Environment]::SetEnvironmentVariable('POETRY_HOME', "${poetryHome}\", "Machine")

    (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -

    # Update PATH
    $pathParts = [System.Environment]::GetEnvironmentVariable('PATH', "Machine") -split ";"
    # Remove existing paths, so we don't add duplicates
    $newPathParts = $pathParts.Where{ $_ -ne $poetryPath }
    $newPathParts = @($poetryPath) + $newPathParts
    $newPath = $newPathParts -join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $newPath, "Machine")

    Write-Host "Poetry is successfully installed."
}

Function Main {
    If ($Uninstall) {
        Remove-Poetry
        If ($? -eq $True) {
            Write-Host "Poetry successfully uninstalled."
        } Else {
            Write-Host "Uninstallation failed."
        }
    } Else {
        Install-Poetry
    }
}

Main