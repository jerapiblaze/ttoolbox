<#
.SYNOPSIS
    Optimize the WSL disk(s) for a specified distro or all distros.

.DESCRIPTION
    This script optimizes the WSL disk(s) for a specified distro or all distros by compacting the ext4.vhdx file.

.PARAMETER Distro
    The name of the WSL distro to optimize. Use -All to optimize all distros.

.PARAMETER DryRun
    If specified, the script will only display the actions that would be performed without actually optimizing the disks.

.PARAMETER Help
    Displays this help message.

.PARAMETER All
    If specified, optimizes all WSL distros.

.PARAMETER Force
    If specified, skips confirmation prompts.
#>
param(
    [Parameter(Mandatory = $false)]
    [switch]$DryRun = $false,
    [Parameter(Mandatory = $false)]
    [string]$Distro = "",
    [Parameter(Mandatory = $false)]
    [switch]$Help = $false,
    [Parameter(Mandatory = $false)]
    [switch]$All = $false,
    [Parameter(Mandatory = $false)]
    [switch]$Force = $false
)
if ($Help) {
    Get-Help optimize-wsldisk.ps1 -Detailed
    exit
}
# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    throw "This script must be run as Administrator."
}
if ($Distro -eq "" -and -not $All) {
    throw "Please specify a WSL distro using the -Distro parameter or use -All to optimize all distros."
}
if (-not $Force) {
    Write-Host "This script will optimize the WSL disk(s) for the specified distro(s)." -ForegroundColor Yellow
    Write-Host "This may take some time and will require full shutdown of the WSL instance(s)." -ForegroundColor Yellow
    Write-Host "Please ensure you have closed all applications running in WSL before proceeding." -ForegroundColor Yellow
    if ($All) {
        $Confirm = Read-Host "Are you sure you want to optimize WSL disks of all distros? (y/n)"
    } else {
        $Confirm = Read-Host "Are you sure you want to optimize WSL disks of distro $Distro? (y/n)"
    }
    if ($Confirm -ne "y") {
        exit
    }
}

# Shutdown all running WSL instances
wsl --shutdown

function Optimize-WSLDisk {
    param (
        [string]$DistroName
    )
    Write-Host "Optimizing WSL disk for distro: $DistroName" -ForegroundColor Cyan
    # Get the WSL disk path
    $lxss = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"

    $wslDiskPath = Get-ChildItem $lxss | ForEach-Object {
        $p = Get-ItemProperty $_.PsPath
        if (-not $p.BasePath) {
            return
        }
        if ($p.DistributionName -eq $DistroName) {
            $base = $p.BasePath -replace '^\\\\\?\\', ''
            Join-Path $base "ext4.vhdx"
        }
    }
    if (-not $wslDiskPath) {
        Write-Host "Could not find WSL disk path for distro: $DistroName" -ForegroundColor Red
        return
    }
    Write-Host "WSL disk path for $DistroName : $wslDiskPath"
    if ($DryRun) {
        Write-Host "Dry run mode enabled. No actual optimization will be performed." -ForegroundColor Yellow
        return
    }
    # Optimize using DiskPart
    $diskpartScript = @"
select vdisk file="$wslDiskPath"
attach vdisk readonly
compact vdisk
detach vdisk
"@
    $diskpartScript | diskpart > null
    # Size of the WSL disk before optimization
    $sizeBefore = (Get-Item $wslDiskPath).Length
    $sizeAfter = (Get-Item $wslDiskPath).Length
    Write-Host "Saved $([math]::Round(($sizeBefore - $sizeAfter) / 1MB, 2)) MB for distro $DistroName (before: $([math]::Round($sizeBefore / 1MB, 2)) MB, after: $([math]::Round($sizeAfter / 1MB, 2)) MB)"
}

# Optimize WSL disk(s)
if ($All) {
    $distros = wsl --list --quiet
    foreach ($distro in $distros) {
        if ($distro -ne "") {
            Optimize-WSLDisk -DistroName $distro
        }
    }
} else {
    Optimize-WSLDisk -DistroName $Distro
}

Write-Host "WSL disk optimization completed." -ForegroundColor Cyan