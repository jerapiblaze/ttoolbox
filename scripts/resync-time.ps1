# Force a time resynchronization in Windows using PowerShell

param (
    [Parameter(Mandatory = $false)]
    [string]$NTPServer = "time.nist.gov"
)

Write-Host "Resync-Time"
$Host.UI.RawUI.WindowTitle = "ReSync-Time - NTP: $NTPServer"

try {
    # Check if running as Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
            [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        throw "This script must be run as Administrator."
    }

    Write-Host "Starting Windows Time service..." -ForegroundColor Yellow
    Start-Service w32time

    Write-Host "Forcing time resynchronization..." -ForegroundColor Yellow
    # /force ensures sync even if Windows thinks it's already in sync
    Write-Host "Using NTP Server: $NTPServer" -ForegroundColor Blue
    w32tm /config /manualpeerlist:$NTPServer /syncfromflags:manual /reliable:YES /update
    w32tm /resync /force

    Write-Host "Stopping Windows Time service..." -ForegroundColor Yellow
    Stop-Service w32time

    Write-Host "Time resynchronization complete." -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
