<#
.SYNOPSIS
Cleanup file system.
.DESCRIPTION
This script remove files (and optional folders) from a path if they are older than specified.
.PARAMETER Path
The path to the folder to clean.
.PARAMETER Days
Number of days.
.PARAMETER RemoveFolders
Also remove folders.
.EXAMPLE
PS> ./autoclean.ps1 -Path D:\tmp
Remove files and folders in D:\tmp older than 60 days.
.NOTES
Author: J12Tee | License: CC0
#>

param (
    [string]$Path,
    [int]$Days = 60,
    [switch]$RemoveFolders,
    [switch]$Help
)
if ($Help -or $Path -eq ""){
    Get-Help autocleanfs.ps1 -Detailed;
}
# Search for files and folders with the specified path and age
Get-ChildItem -Path $Path -Recurse | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-$Days)
} |
# Remove the found files
Remove-Item -Recurse -WhatIf
# If RemoveFolders is enabled, remove folders
if ($RemoveFolders) {
    Get-ChildItem -Path $Path -Recurse | Where-Object {
        $_.GetType().Name -eq "DirectoryInfo" -and $_.LastWriteTime -lt (Get-Date).AddDays(-$Days)
    } |
    Remove-Item -Recurse -WhatIf
}