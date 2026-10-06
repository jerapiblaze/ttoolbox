<# 
Reset Windows Update components script
This script stops Windows Update services, deletes temporary update files,
and restarts the services to reset the Windows Update components.
#>

param(
    [switch]$Force
)

# Requires administrative privileges to stop and start Windows Update services.
# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as an administrator."
    exit 1
}

if (-not $Force) {
    # Confirm with the user before proceeding
    $confirmation = Read-Host "Are you sure you want to reset Windows Update components? (Y/N)"
    if ($confirmation -ne "Y") {
        Write-Output "Operation cancelled by the user."
        exit 0
    }
}

# Stop Windows Update services
Write-Host "Stopping Windows Update service and its related components..."
Stop-Service -Name wuauserv -Force
Stop-Service -Name bits -Force
Stop-Service -Name cryptsvc -Force
Stop-Service -Name msiserver -Force

# Delete temporary update files
Write-Host "Removing cached Windows Update files..."
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
Remove-Item -Path "C:\Windows\System32\catroot2\*" -Recurse -Force

# Restart Windows Update services
Write-Host "Restarting Windows Update service and its related components..."
Start-Service -Name wuauserv
Start-Service -Name bits
Start-Service -Name cryptsvc
Start-Service -Name msiserver

Write-Host "Windows Update components have been reset successfully." -ForegroundColor Green