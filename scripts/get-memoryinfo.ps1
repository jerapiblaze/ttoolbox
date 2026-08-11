<#
.SYNOPSIS
    Get memory information.

.DESCRIPTION
    This script retrieves information about the system memory, including total, used, free, shared, buffer/cache, and available memory, as well as swap usage.
#>
param(
    [ValidateSet("k", "m", "g", "human")]
    [string]$unit = "m",

    [switch]$json,
    [switch]$wide,
    [switch]$raw
)

# Determine divisor for unit conversion
switch ($unit) {
    "k" { $div = 1 }        # KB
    "m" { $div = 1024 }     # MB
    "g" { $div = 1024 * 1024 }# GB
    "human" {
        $totalKB = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize
        if ($totalKB -gt 100 * 1024 * 1024) { $div = 1024 * 1024; $unit = "g" }   # >100GB
        elseif ($totalKB -gt 1024 * 1024) { $div = 1024; $unit = "m" }        # >1GB
        else { $div = 1; $unit = "k" }
    }
}

# RAM info (values are in KB)
$os = Get-CimInstance Win32_OperatingSystem
$memTotal = [int]($os.TotalVisibleMemorySize / $div)
$memFree = [int]($os.FreePhysicalMemory / $div)
$memUsed = $memTotal - $memFree

# Available memory (bytes → KB → unit)
$availableBytes = (Get-Counter '\Memory\Available Bytes').CounterSamples[0].CookedValue
$available = [int](($availableBytes / 1024) / $div)

# Cache (bytes → KB → unit)
$cacheBytes = (Get-Counter '\Memory\Cache Bytes').CounterSamples[0].CookedValue
$cache = [int](($cacheBytes / 1024) / $div)

# Shared (bytes → KB → unit)
$sharedBytes = (Get-Counter '\Memory\Modified Page List Bytes').CounterSamples[0].CookedValue
$shared = [int](($sharedBytes / 1024) / $div)

# Swap info (values are in MB)
$pf = Get-CimInstance Win32_PageFileUsage
$swapTotal = [int](($pf.AllocatedBaseSize * 1024) / $div)
$swapUsed = [int](($pf.CurrentUsage * 1024) / $div)
$swapFree = $swapTotal - $swapUsed

# RAW output
if ($raw) {
    Write-Output "$unit"
    Write-Output "$memTotal $memUsed $memFree $shared $cache $available"
    Write-Output "$swapTotal $swapUsed $swapFree"
    exit
}

# JSON output
if ($json) {
    $obj = [ordered]@{
        unit   = $unit
        memory = @{
            total     = $memTotal
            used      = $memUsed
            free      = $memFree
            shared    = $shared
            buffcache = $cache
            available = $available
        }
        swap   = @{
            total = $swapTotal
            used  = $swapUsed
            free  = $swapFree
        }
    }
    $obj | ConvertTo-Json -Depth 4
    exit
}

# Wide output
if ($wide) {
    "{0,-12} {1,15} {2,15} {3,15} {4,15} {5,18} {6,18}" -f "", "total", "used", "free", "shared", "buff/cache", "available"
    "{0,-12} {1,15} {2,15} {3,15} {4,15} {5,18} {6,18}" -f "Mem:", $memTotal, $memUsed, $memFree, $shared, $cache, $available
    "{0,-12} {1,15} {2,15} {3,15}" -f "Swap:", $swapTotal, $swapUsed, $swapFree
    exit
}

# Normal table
"{0,-12} {1,12} {2,12} {3,12} {4,12} {5,14} {6,14}" -f "", "total", "used", "free", "shared", "buff/cache", "available"
"{0,-12} {1,12} {2,12} {3,12} {4,12} {5,14} {6,14}" -f "Mem:", $memTotal, $memUsed, $memFree, $shared, $cache, $available
"{0,-12} {1,12} {2,12} {3,12}" -f "Swap:", $swapTotal, $swapUsed, $swapFree
