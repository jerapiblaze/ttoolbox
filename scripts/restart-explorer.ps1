<#
.SYNOPSIS
Restarts Windows Explorer.

.DESCRIPTION
This script stops all instances of Windows Explorer and then restarts it.

.PARAMETER Help
Displays this help message.
#>
param (
    [switch]$Help
)

if ($Help) {
    Get-Help restart-explorer.ps1 -Detailed
    exit
}

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    throw "This script must be run as Administrator."
}

Write-Host "Restarting Explorer"
Get-Process explorer | Foreach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 5
Start-Process explorer
Write-Host "Done." -ForegroundColor Green