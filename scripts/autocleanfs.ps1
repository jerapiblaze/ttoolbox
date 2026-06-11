<#
.SYNOPSIS
Cleanup file system.
.DESCRIPTION
This script remove files (and optional folders) from a path if they are older than specified.
.PARAMETER Path
The path to the folder to clean.
.PARAMETER CreationTime
Use CreationTime instead of LastAccessDate (dangerous).
.PARAMETER Days
Number of days. Default: 90.
.PARAMETER Dry
Perform a dry run.
.PARAMETER Force
Force run, skip confirmation.
.PARAMETER RemoveFolders
Also remove folders.
.EXAMPLE
PS> ./autoclean.ps1 -Path D:\tmp
Remove files and folders in D:\tmp older than 60 days.
.NOTES
Author: J12Tee | License: CC0
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$Path,

    [ValidateRange(1, 3650)]
    [int]$Days = 90,

    [switch]$RemoveFolders,
    [switch]$CreationTime,
    [switch]$Dry,
    [switch]$Force,
    [switch]$Help
)

if ($Help -or $Path -eq "") {
    Get-Help $PSCommandPath -Detailed
    return
}

if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Path '$Path' does not exist or is not a valid directory."
    return
}

$thresholdDate = (Get-Date).AddDays(-$Days)
$compareProperty = if ($CreationTime) { 'CreationTime' } else { 'LastAccessTime' }

$files = Get-ChildItem -Path $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.$compareProperty -lt $thresholdDate }

$folders = if ($RemoveFolders) {
    Get-ChildItem -Path $Path -Recurse -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.$compareProperty -lt $thresholdDate }
} else {
    @()
}

$filesCount = $files.Count
$foldersCount = $folders.Count
$total = $filesCount + $foldersCount

Write-Output "AutoCleanFs"
Write-Output "Path                : $Path"
Write-Output "Days                : $Days"
Write-Output "CompareProperty     : $compareProperty"
Write-Output "RemoveFolders       : $RemoveFolders"
Write-Output "ItemsCount          : $filesCount files and $foldersCount folders"

if ($total -eq 0) {
    Write-Output "No items older than $Days days were found."
    return
}

function Show-ItemList {
    param (
        [string]$Title,
        [System.Collections.IEnumerable]$Items
    )

    if ($Items.Count -gt 0) {
        Write-Output $Title
        $Items | ForEach-Object { Write-Output $_.FullName }
    }
}

if (-not $Force) {
    do {
        $response = Read-Host "Do you want to proceed with the operation? (Yes/N/List)"
        $response = $response.Trim().ToLowerInvariant()

        switch ($response) {
            'l' { Show-ItemList 'Files to remove:' $files; Show-ItemList 'Folders to remove:' $folders }
            'list' { Show-ItemList 'Files to remove:' $files; Show-ItemList 'Folders to remove:' $folders }
            'y' { Write-Host "Please specify 'yes' to continue." }
        }
    } while ($response -notin @('yes', 'n'))

    if ($response -eq 'n') {
        Write-Output 'Canceled.'
        return
    }
}

if ($Dry) {
    Write-Output 'Dry run enabled. No items will be deleted.'
}

$processed = 0
foreach ($item in $files + $folders) {
    $processed++
    $percent = [math]::Round(($processed / $total) * 100, 2)
    Write-Progress -Activity 'Removing files and folders' -Status "$processed of $total" -PercentComplete $percent

    $removeParams = @{
        Path = $item.FullName
        Force = $true
    }

    if ($item.PSIsContainer) {
        $removeParams['Recurse'] = $true
    }

    if ($Dry) {
        $removeParams['WhatIf'] = $true
    }

    Remove-Item @removeParams
}

Write-Progress -Activity 'Removing files and folders' -Completed
Write-Output "Completed. Processed $total item(s)."
