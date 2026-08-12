<#
.SYNOPSIS
    Lists the contents of the ttoolbox directory with color-coded output.

.PARAMETER Docs
    Include markdown documentation files (*.md).

.PARAMETER Scripts
    Include PowerShell scripts (*.ps1).

.PARAMETER AllScripts
    Include all script files (*.ps1, *.sh).

.PARAMETER Manifests
    Include YAML manifest files (*.yaml).

.PARAMETER Shrink
    Hide the ASCII art and version information, showing only the list of files.

.PARAMETER All
    Include all files (*.ps1, *.sh, *.yaml, *.md).
#>
param(
    [Parameter(Mandatory = $false)]
    [switch]$Docs,
    [Parameter(Mandatory = $false)]
    [switch]$Scripts,
    [Parameter(Mandatory = $false)]
    [switch]$AllScripts,
    [Parameter(Mandatory = $false)]
    [switch]$Manifests,
    [Parameter(Mandatory = $false)]
    [switch]$All,
    [Parameter(Mandatory = $false)]
    [switch]$Shrink,
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

$Version = $(git log -1 --pretty=format:"%h [%cr]")
if (-not $Shrink) {
    Write-Host "  _    _                 _  _                  " -ForegroundColor Magenta
    Write-Host " | |_ | |_  ___    ___  | || |__    ___ __  __ " -ForegroundColor Yellow
    Write-Host " | __|| __|/ _ \  / _ \ | || '_ \  / _ \\ \/ / " -ForegroundColor Red
    Write-Host " | |_ | |_| (_) || (_) || || |_) || (_) |>  <  " -ForegroundColor Green
    Write-Host "  \__| \__|\___/  \___/ |_||_.__/  \___//_/\_\ " -ForegroundColor Blue
    Write-Host "                                               " -ForegroundColor Cyan
}
if (-not $Shrink) {
    Write-Host "ttoolbox-ls.ps1 - Version: $Version" -ForegroundColor Cyan
    Write-Host "Made with ❤️ by @jerapiblaze" -ForegroundColor Cyan
    # # write color bars to test terminal color support
    Write-Host "|" -NoNewline
    Write-Host "   " -BackgroundColor Red -NoNewline
    Write-Host "   " -BackgroundColor Green -NoNewline
    Write-Host "   " -BackgroundColor Blue -NoNewline
    Write-Host "   " -BackgroundColor Yellow -NoNewline
    Write-Host "   " -BackgroundColor Magenta -NoNewline
    Write-Host "   " -BackgroundColor Cyan -NoNewline
    Write-Host "   " -BackgroundColor White -NoNewline
    Write-Host "   " -BackgroundColor DarkGray -NoNewline
    Write-Host "   " -BackgroundColor Black -NoNewline
    Write-Host "|"
    Write-Host ""
}
Write-Host "----"

if ($Help) {
    Get-Help ttoolbox-ls.ps1 -Detailed
    return;
}

if ($All){
    $Items = Get-ChildItem -Path "C:\ttoolbox" -Recurse -Include "*.ps1", "*.sh", "*.yaml", "*.md"
} else {
    $Items = @()
    if ($Docs) {
        $Items += Get-ChildItem -Path "C:\ttoolbox" -Recurse -Filter "*.md"
    }
    if ($Scripts) {
        $Items += Get-ChildItem -Path "C:\ttoolbox" -Recurse -Filter "*.ps1"
    } elseif ($AllScripts) {
        $Items += Get-ChildItem -Path "C:\ttoolbox" -Recurse -Filter "*.ps1"
        $Items += Get-ChildItem -Path "C:\ttoolbox" -Recurse -Filter "*.sh"
    }
    if ($Manifests) {
        $Items += Get-ChildItem -Path "C:\ttoolbox" -Recurse -Filter "*.yaml"
    }
}

$curDirName = ""
$pathDirs = $env:PATH -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

$Items | ForEach-Object {
    # $file = $_.FullName
    $pathname = $_.DirectoryName
    $Executable = ($pathDirs -contains $pathname) -and ($_.Extension -eq ".ps1")
    if ($pathname -ne $curDirName){
        # check if pathname is in any PATH
        if ($pathDirs -contains $pathname) {
            Write-Host "Directory: $pathname (in PATH)" -BackgroundColor Green
        }
        else {
            Write-Host "Directory: $pathname" -BackgroundColor Blue
        }
        $curDirName = $pathname
    }
    if ($_.Extension -eq ".ps1") {
        if ($Executable) {
            Write-Host "  $($_.Name)" -ForegroundColor Green
        } else {
            Write-Host "  $($_.Name)"
        }
    } elseif ($_.Extension -eq ".sh") {
        Write-Host "  $($_.Name) (bash)"
    } elseif ($_.Extension -eq ".yaml") {
        Write-Host "  $($_.Name)" -ForegroundColor Magenta
    } elseif ($_.Extension -eq ".md") {
        Write-Host "  $($_.Name)" -ForegroundColor DarkGray
    }
}