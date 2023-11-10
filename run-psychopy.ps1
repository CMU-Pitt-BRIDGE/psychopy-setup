<#
    .SYNOPSIS
    Launches PsychoPy for a specified project using Poetry.

    .DESCRIPTION
    Changes to the specified project directory and runs PsychoPy using the Poetry-managed virtual environment.

    .PARAMETER ProjectDir
    The directory of the project where the Poetry environment will be used.

    .EXAMPLE
    PS> .\run-psychopy.ps1 -ProjectDir "C:\Users\BRIDGE-CENTER\PsychoPyProject"

    .LINK
    Poetry: https://python-poetry.org/docs/
    PsychoPy: https://www.psychopy.org/
#>

param (
    [string] $ProjectDir
)

Function Start-PsychoPy {
    Write-Host "Starting PsychoPy within the Poetry environment at $ProjectDir..."
    Set-Location -Path $ProjectDir
    poetry run psychopy
}

# Check if ProjectDir parameter is provided
If (-not $ProjectDir) {
    Write-Error "ProjectDir parameter is required."
    Exit
}

Start-PsychoPy

# It can be run with a specified project directory like this:

# .\run-psychopy.ps1 -ProjectDir "C:\Path\To\Your\PsychoPyProject"