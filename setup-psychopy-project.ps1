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
    PS> .\setup-psychopy-project.ps1 -ProjectDir "my_psychopy_project" -PythonVersion "3.8.10" -PsychoPyVersion "2023.2.3" [-Uninstall]
#>

param (
    [string] $ProjectDir = Join-Path -Path $env:USERPROFILE -ChildPath "psychopy_project"
    [string] $PythonVersion = "3.8.10",
    [string] $PsychoPyVersion = "2023.2.3",
    [Switch] $Uninstall = $False
)

Function CommandExists {
    param (
        [string]$Command
    )
    $exists = $false
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            $exists = $true
        }
    }
    catch {
        $exists = $false
    }
    return $exists
}

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
    # Try setting the local Python version with pyenv
    pyenv local $PythonVersion
    if ($LASTEXITCODE -ne 0) {
        Write-Error "pyenv specific python requisite didn't meet. Project is using a different version of python."
        # Handle the error, for example, by installing the required Python version
        pyenv install $PythonVersion
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install Python version $PythonVersion"
            Exit
        }
        pyenv local $PythonVersion
    }

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

[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"
"@

    Set-Content -Path ".\pyproject.toml" -Value $pyprojectContent
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create pyproject.toml."
        Exit
    }

    # Setup local virtual environment
    Write-Host "Creating local virtual environment..."
    poetry config virtualenvs.create true --local
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to set local virtual environment creation."
        Exit
    }

    # Installing dependencies
    Write-Host "Installing dependencies..."
    poetry install --no-root
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install dependencies."
        Exit
    }

    Write-Host "PsychoPy project setup complete."
}

Function Uninstall-PsychoPyProject {
    # Remove project directory
    Write-Host "Removing project directory '$ProjectDir'..."
    $null = Remove-Item -Path $ProjectDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "PsychoPy project removed."
}

If ($Uninstall) {
    Uninstall-PsychoPyProject
} Else {
    Install-PsychoPyProject
}