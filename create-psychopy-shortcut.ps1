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