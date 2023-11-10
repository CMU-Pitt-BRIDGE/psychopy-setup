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
    [string] $ScriptPath,
    [string] $ProjectDir
)

Function Create-Shortcut {
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Run PsychoPy.lnk"

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `"$ScriptPath`" -ProjectDir `"$ProjectDir`""
    $Shortcut.WorkingDirectory = Split-Path $ScriptPath
    $Shortcut.IconLocation = "powershell.exe"
    $Shortcut.Save()

    Write-Host "Shortcut created at $shortcutPath"
}

# Check if parameters are provided
If (-not $ScriptPath -or -not $ProjectDir) {
    Write-Error "Both ScriptPath and ProjectDir parameters are required."
    Exit
}

Create-Shortcut

# Run it with the full path to your run-psychopy.ps1 script and the project directory like this:

#.\create-psychopy-shortcut.ps1 -ScriptPath "C:\Path\To\run-psychopy.ps1" -ProjectDir "C:\Path\To\Your\PsychoPyProject"

# This will create a shortcut on your desktop that, when clicked, will open a minimized PowerShell window and execute the run-psychopy.ps1 script for your specified project directory.