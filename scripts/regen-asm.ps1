<#
.SYNOPSIS
    Regenerate native images for loaded assemblies using NGEN (Native Image Generator).

.DESCRIPTION
    This script enumerates all currently loaded assemblies and uses NGEN to generate native images for them.

.PARAMETER AsmSet
    Specifies which assemblies to process. Valid values are "System", "User", "All".

.PARAMETER DryRun
    If specified, the script will only display the assemblies that would be processed without actually invoking NGEN.
#>
param(
    [Parameter(Mandatory = $false)][ValidateSet("System", "User", "All", "")]
    [string]$AsmSet = "",
    [Parameter(Mandatory = $false)]
    [switch]$DryRun = $false
)

if ($AsmSet -eq "") {
    Get-Help regen-asm.ps1 -Detailed
    exit
}

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    throw "This script must be run as Administrator."
}

switch ($AsmSet) {
    "System" { $mode = "system"; break }
    "User" { $mode = "user"; break }
    "All" { $mode = "all"; break }
    default { throw "Invalid AsmSet value: $AsmSet. Valid values are System, User, All." }
}

# Locate ngen.exe
$runtimeDir = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
$ngen = Join-Path $runtimeDir "ngen.exe"

if (-not (Test-Path $ngen)) {
    Write-Host "ngen.exe not found in: $runtimeDir" -ForegroundColor Red
    exit 1
}

if ($DryRun) {
    Write-Host "Dry run mode enabled. No native images will be generated." -ForegroundColor Yellow
    Write-Host "Assemblies that would be processed:" -ForegroundColor Yellow
}
Write-Host "Using ngen.exe at: $ngen" -ForegroundColor Cyan
Write-Host "Mode: $AsmSet" -ForegroundColor Cyan

# Helper: classify assemblies
function Get-AssemblyType($path) {
    $windowsDir = $env:WINDIR
    if ($path.StartsWith($windowsDir, 'InvariantCultureIgnoreCase')) {
        return "system"
    }
    return "user"
}

# Enumerate assemblies
$assemblies =
[AppDomain]::CurrentDomain.GetAssemblies() |
Where-Object { $_.Location -and (Test-Path $_.Location) }

foreach ($asm in $assemblies) {
    $path = $asm.Location
    $name = Split-Path $path -Leaf
    $type = Get-AssemblyType $path

    if ($mode -ne "all" -and $type -ne $mode) {
        continue
    }

    Write-Host "`nRunning NGEN on: $name ($type)" -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "  (Dry run) Would execute: $ngen install $path /nologo" -ForegroundColor Gray
        continue
    }

    & $ngen install $path /nologo

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✔ Native image generated" -ForegroundColor Green
    }
    else {
        Write-Host "  ✘ Failed (exit code $LASTEXITCODE)" -ForegroundColor Red
    }
}
