<#
.SYNOPSIS
Clears the Windows icon and thumbnail cache.

.DESCRIPTION
This script deletes the icon cache file and restarts Explorer to rebuild it.

.PARAMETER DeepClean
If specified, also deletes additional icon cache files in the Explorer directory.

.PARAMETER Force
Skips the confirmation prompt.

.PARAMETER Help
Displays this help message.
#>

param (
    [switch]$DeepClean,
    [switch]$Force,
    [switch]$Help
)

if ($Help) {
    Get-Help clear-iconcache.ps1 -Detailed
    exit
}

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    throw "This script must be run as Administrator."
}

$iconCachePath = "$env:LOCALAPPDATA\iconcache.db"
$iconCachePath2 = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"

# Confirmation prompt
if (-not $Force) {
    $Confirm = Read-Host "Are you sure you want to clear the icon cache? This will restart Explorer and may cause temporary visual glitches. Also make sure there is no running file operations. (y/n)"
    if ($Confirm -ne "y") {
        Write-Host "Operation cancelled."
        exit
    }
}
if (Test-Path $iconCachePath) {
    Write-Host "Clearing icon cache: $iconCachePath"
    Remove-Item $iconCachePath -Force
}
if ($DeepClean -and (Test-Path $iconCachePath2)) {
    Write-Host "Clearing icon cache files in: $iconCachePath2"
    Get-ChildItem -Path $iconCachePath2 -Filter "iconcache*" | Remove-Item -Force
    Get-ChildItem -Path $iconCachePath2 -Filter "thumbcache*" | Remove-Item -Force
}
# Rebuild the icon cache by restarting Explorer
# Stop all instances of Explorer
Write-Host "Restarting Explorer to rebuild icon cache..."
Get-Process explorer | Foreach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 5
Start-Process explorer
Write-Host "Done." -ForegroundColor Green