# Installing PsychoPy on BRIDGE-PC

This allows the installation of multiple independent versions of `PsychoPy` for each User on a PC; that is, a user can have many different and isolated versions of `PsychoPy` running on their local user account. `Pyenv` is used to manage Python versions and `Poetry` to manage virtual environments and Python packages. Both `Pyenv` and `Poetry` are shared among users to save disk space.

## Prerequisites

Before you can run PowerShell scripts on your machine, you must set your local ExecutionPolicy to RemoteSigned (anything except `Undefined` and `Restricted`). If you choose `AllSigned` instead of `RemoteSigned`, local scripts (your own) must be digitally signed to execute. With `RemoteSigned`, only scripts with the `ZoneIdentifier` set to Internet (downloaded from the web) need to be signed; others do not. If you’re an administrator and want to set it for all users on that machine, use `-Scope LocalMachine`. If you’re a normal user without administrative rights, you can use `-Scope CurrentUser` to set it only for you.

[about Scopes - PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes)

More about PowerShell Scopes

[Set-ExecutionPolicy (Microsoft.PowerShell.Security) - PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy)

More about PowerShell ExecutionPolicy

To set the value of `ExecutionPolicy` to `RemoteSigned` for all users, use the following command:

```powershell
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
```

## Pyenv-win

[pyenv for Windows](https://pyenv-win.github.io/pyenv-win/)

To install Pyenv-win for all users, follow these steps:

```powershell
$pyenvSystemPath = "C:\Program Files\pyenv"
$pyenvWinDir = "${pyenvSystemPath}\pyenv-win"
$binPath = "${pyenvWinDir}\bin"
$shimsPath = "${pyenvWinDir}\shims"

New-Item -Path $pyenvSystemPath -ItemType Directory -Force
$DownloadPath = "$pyenvSystemPath\pyenv-win.zip"

(New-Object System.Net.WebClient).DownloadFile("https://github.com/pyenv-win/pyenv-win/archive/master.zip", $DownloadPath)
Microsoft.PowerShell.Archive\Expand-Archive -Path $DownloadPath -DestinationPath $pyenvSystemPath
Move-Item -Path "$pyenvSystemPath\pyenv-win-master\*" -Destination "$pyenvSystemPath"
Remove-Item -Path "$pyenvSystemPath\pyenv-win-master" -Recurse
Remove-Item -Path $DownloadPath

# Alternative installation method if you have git installed:
# git clone https://github.com/pyenv-win/pyenv-win.git $pyenvSystemPath

# Update environment variables
[System.Environment]::SetEnvironmentVariable('PYENV', "${pyenvWinDir}\", "Machine")
[System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${pyenvWinDir}\", "Machine")
[System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${pyenvWinDir}\", "Machine")

$pathParts = [System.Environment]::GetEnvironmentVariable('PATH', "Machine") -Split ";"

# Remove existing paths so we don't add duplicates
$newPathParts = $pathParts.Where{ $_ -ne $binPath }.Where{ $_ -ne $shimsPath }
$newPathParts = @($binPath, $shimsPath) + $newPathParts
$newPath = $newPathParts -Join ";"
[System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "Machine")
```

- Run `pyenv --version` to check if the installation was successful.
- Run `pyenv install -l` to check a list of Python versions supported by pyenv-win
- Run `pyenv install 3.8.10` to install the recommended version by PsychoPy
- Run `pyenv global 3.8.10`  to set Python 3.8.10 as the global version

> Use `pyenv local` command to set the Python version for a specific project

## Poetry

[Poetry - Python dependency management and packaging made easy](https://python-poetry.org)

1. Follow the instructions on the Poetry website to install Poetry on your BRIDGE-PC. This may involve running a command in your terminal or command prompt.

To install Poetry for all users, follow these steps:

```powershell
$poetryHome = "C:\Program Files\pypoetry"
$poetryPath = "${poetryHome}\venv\Scripts"

New-Item -Path $poetryHome -ItemType Directory -Force

[System.Environment]::SetEnvironmentVariable('POETRY_HOME', "${poetryHome}\", "Machine")

(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -

# Update PATH
$pathParts = [System.Environment]::GetEnvironmentVariable('PATH', "Machine") -split ";"

# Remove existing paths so we don't add duplicates
$newPathParts = $pathParts.Where{ $_ -ne $poetryPath }
$newPathParts = @($poetryPath) + $newPathParts
$newPath = $newPathParts -join ";"
[System.Environment]::SetEnvironmentVariable('PATH', $newPath, "Machine")
```

## PsychoPy

To install PsychoPy “2023.2.3” for a User, follow these steps:

```powershell
$ProjectDir = Join-Path -Path $env:USERPROFILE -ChildPath "psychopy_project"
$PythonVersion = "3.8.10",
$PsychoPyVersion = "2023.2.3",

$projectName = Split-Path $ProjectDir -Leaf
$projectName = $projectName -replace '\W', '' # Remove non-word characters

$null = New-Item -Path $ProjectDir -ItemType Directory -Force -ErrorAction Stop

# Change to the project directory
cd $ProjectDir

# Setting local Python version using pyenv
Write-Host "Setting Python version to $PythonVersion..."
# Try setting the local Python version with pyenv
pyenv local $PythonVersion

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

# Setup local virtual environment
poetry config virtualenvs.create true --local

# Installing dependencies
poetry install --no-root
```

This will create a Python virtual environment in:

```powershell
%AppData%/Local/pypoetry/Cache/virtualenvs
```

## PsychoPy Launch Script

Create a folder for the launch script:

```powershell
$ScriptsDir = "$([Environment]::GetFolderPath('MyDocuments'))\Scripts"
$null = New-Item -Path $ScriptsDir -ItemType Directory -Force -ErrorAction Stop
```

Place the following `run-psychopy.ps1` script in `%UserProfile%\Documents\Scripts`:

```powershell
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
    [string] $ProjectDir = "$([Environment]::GetFolderPath('UserProfile'))\psychopy_project"
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
```

## PsychoPy Desktop Shortcut

Run the following script to create the shortcut:

```powershell
<#
    .SYNOPSIS
    Creates a shortcut to run the PsychoPy launch script.

    .DESCRIPTION
    Creates a shortcut on the desktop that launches the PsychoPy project in a minimized PowerShell window.

    .PARAMETER ScriptPath
    The full path to the 'run-psychopy.ps1' script.

    .PARAMETER ProjectDir
    The directory of the PsychoPy project.

    .EXAMPLE
    PS> .\create-psychopy-shortcut.ps1 -ScriptPath "C:\Scripts\run-psychopy.ps1" -ProjectDir "C:\Users\BRIDGE-CENTER\PsychoPyProject"
#>

param (
    [string] $ScriptPath = "$([Environment]::GetFolderPath('MyDocuments'))\Scripts\run-psychopy.ps1",
    [string] $ProjectDir = "$([Environment]::GetFolderPath('UserProfile'))\psychopy_project"
)

Function Create-Shortcut {
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Run PsychoPy.lnk"
    $vbscriptPath = Join-Path $desktopPath "create_shortcut.vbs"

    $vbScriptContent = @"
Set oWS = WScript.CreateObject("WScript.Shell")
sLinkFile = "$shortcutPath"
Set oLink = oWS.CreateShortcut(sLinkFile)
oLink.TargetPath = "powershell.exe"
oLink.Arguments = "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File ""$ScriptPath"" -ProjectDir ""$ProjectDir"""
oLink.WorkingDirectory = "$(Split-Path $ScriptPath)"
oLink.WindowStyle = 7
oLink.IconLocation = "powershell.exe"
oLink.Save()
"@

    Set-Content -Path $vbscriptPath -Value $vbScriptContent
    cscript //nologo $vbscriptPath
    Remove-Item -Path $vbscriptPath

    Write-Host "Shortcut created at $shortcutPath"
}

# Check if parameters are provided
If (-not $ScriptPath -or -not $ProjectDir) {
    Write-Error "Both ScriptPath and ProjectDir parameters are required."
    Exit
}

Create-Shortcut
```
