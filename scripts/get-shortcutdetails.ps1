<#
.SYNOPSIS
    Retrieve details of a Windows shortcut (.lnk) file.

.DESCRIPTION
    This script allows you to retrieve details of a Windows shortcut file, including its target path, arguments, and other properties.

.PARAMETER ShortcutPath
    The path to the shortcut (.lnk) file.

.PARAMETER Help
    Display detailed help information.

.EXAMPLE
    .\get-shortcutdetails.ps1 -ShortcutPath "C:\path\to\shortcut.lnk"

#>
param (
    [Parameter(Mandatory = $true)]
    [string]$ShortcutPath,
    [switch]$Help = $false
)

if ($Help) {
    Get-Help get-shortcutdetails.ps1 -Detailed
    exit
}

if (-Not (Test-Path -Path $ShortcutPath)) {
    Write-Error "The specified shortcut file does not exist: $ShortcutPath"
    return
}

try {
    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)
    Write-Output $Shortcut
}
catch {
    Write-Error "Failed to retrieve shortcut details: $_"
}