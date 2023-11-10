<#
    .SYNOPSIS
    Sets up and removes a PsychoPy project using Poetry and Pyenv.

    .DESCRIPTION
    This script creates or removes a PsychoPy project in a specified directory, sets up or removes a Python environment, and manages dependencies using Poetry.

    .PARAMETER ProjectDir
    The directory where the project will be created or removed. Default is 'psychopy_project'.

    .PARAMETER PythonVersion
    The Python version to use. Default is '3.8.10'.

    .PARAMETER PsychoPyVersion
    The version of PsychoPy to install. Default is '2023.2.3'.

    .PARAMETER Uninstall
    If set, the script will remove the PsychoPy project and its environment.

    .EXAMPLE
    PS> .\setup-psychopy-project.ps1 -ProjectDir "my_psychopy_project" -PythonVersion "3.8.10" -PsychoPyVersion "2023.2.3"
#>

param (
    [string] $ProjectDir = "psychopy_project",
    [string] $PythonVersion = "3.8.10",
    [string] $PsychoPyVersion = "2023.2.3",
    [Switch] $Uninstall = $False
)

Function Install-PsychoPyProject {
    # Extract a valid project name from the directory name
    $projectName = Split-Path $ProjectDir -Leaf
    $projectName = $projectName -replace '\W', '' # Remove non-word characters

    # Verify if 'pyenv' and 'poetry' are installed
    If (-not (CommandExists "pyenv") -or -not (CommandExists "poetry")) {
        Write-Error "pyenv and/or poetry are not installed. Please install them before running this script."
        Exit
    }

    # Creating project directory
    Write-Host "Creating project directory '$ProjectDir'..."
    $null = New-Item -Path $ProjectDir -ItemType Directory -Force -ErrorAction Stop

    # Change to the project directory
    cd $ProjectDir

    # Setting local Python version using pyenv
    Write-Host "Setting Python version to $PythonVersion..."
    pyenv local $PythonVersion -ErrorAction Stop

    # Creating a new Poetry project
    Write-Host "Initializing new Poetry project..."
    poetry new $projectName -n -ErrorAction Stop

    # Generating pyproject.toml
    $pyprojectContent = @"
    [tool.poetry]
    name = "$projectName"
    version = "0.1.0"
    description = "A project for PsychoPy $PsychoPyVersion with Python $PythonVersion"
    authors = ["Eduardo Diniz <edd32@pitt.edu>"]

    [tool.poetry.dependencies]
    python = "$PythonVersion"
    pyqt5 = "5.15.2"
    psychopy = {extras = ["all"], version = "$PsychoPyVersion"}

    [tool.poetry.dev-dependencies]

    [tool.poetry]
    virtualenvs.in-project = true

    [build-system]
    requires = ["poetry-core>=1.0.0"]
    build-backend = "poetry.core.masonry.api"

"@

    Set-Content -Path ".\$projectName\pyproject.toml" -Value $pyprojectContent -ErrorAction Stop

    # Installing dependencies
    cd $projectName
    Write-Host "Installing dependencies..."
    poetry install -ErrorAction Stop

    Write-Host "PsychoPy project setup complete."
}

Function Uninstall-PsychoPyProject {
    # Remove project directory
    Write-Host "Removing project directory '$ProjectDir'..."
    $null = Remove-Item -Path $ProjectDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "PsychoPy project removed."
}

Function CommandExists($cmd) {
    $exists = $false
    If (Get-Command $cmd -ErrorAction SilentlyContinue) {
        $exists = $true
    }
    Return $exists
}

If ($Uninstall) {
    Uninstall-PsychoPyProject
} Else {
    Install-PsychoPyProject
}

# Install: To install, run the script with optional parameters for project directory, Python version, and PsychoPy version:
# .\setup-psychopy-project.ps1 -ProjectDir "my_psychopy_project" -PythonVersion "3.8.10" -PsychoPyVersion "2023.2.3"
# Uninstall: To uninstall, use the -Uninstall switch:
# .\setup-psychopy-project.ps1 -ProjectDir "my_psychopy_project" -Uninstall
