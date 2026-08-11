<#
.SYNOPSIS
    Analyzes disk usage for specified directories and generates a folder size report.

.DESCRIPTION
    This script scans specified directories, calculates the sizes of each folder, 
    and generates a detailed report sorted by size. The report can be displayed in 
    the console or exported to a CSV file. To use with other scripts, import the csv
    file and use the data as needed, since the script does not support piping the output to other scripts.

.NOTES
    Author: Emanuele Bartolesi
    Version: 1.0
    Created: 2024-11-17

.PARAMETER Directory
    The directory to analyze. Defaults to the current directory.

.PARAMETER ExportPath
    The path to save the report as a CSV file. Optional.

.EXAMPLE
    ./DiskUsageAnalyzer.ps1 -Directory "C:\Users\YourName\Documents"

.EXAMPLE
    ./DiskUsageAnalyzer.ps1 -Directory "C:\Users" -ExportPath "C:\Reports\DiskUsageReport.csv"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$Directory = "",

    [Parameter(Mandatory = $false)]
    [string]$ExportPath,

    [Parameter(Mandatory = $false)]
    [switch]$SummaryOnly,

    [Parameter(Mandatory = $false)]
    [switch]$HumanReadable,

    [Parameter(Mandatory = $false)]
    [switch]$Help = $false
)

if ($Help) {
    Get-Help get-diskusage.ps1 -Detailed
    return;
}

if ($Directory -eq "") {
    $Directory = Get-Location
}

function Get-ItemSize {
    param (
        [string]$ItemPath,
        [switch]$HumanReadable
    )

    # Resolve the item
    $item = Get-Item -LiteralPath $ItemPath -Force -ErrorAction Stop

    # Compute size
    if ($item.PSIsContainer) {
        # Folder → sum all child file sizes
        $Size = (Get-ChildItem -LiteralPath $ItemPath -Recurse -Force -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
    }
    else {
        # File → direct length
        $Size = $item.Length
    }

    if ($HumanReadable) {
        switch ($Size) {
            { $_ -ge 1GB } { return "{0:N2} GB" -f ($Size / 1GB) }
            { $_ -ge 1MB } { return "{0:N2} MB" -f ($Size / 1MB) }
            { $_ -ge 1KB } { return "{0:N2} KB" -f ($Size / 1KB) }
            default { return "$Size B " }
        }
    }

    return $Size
}

# Main script execution
try {
    Write-Host "Analyzing disk usage for: $Directory" -ForegroundColor Cyan
    if (-not (Test-Path $Directory)) {
        throw "The specified directory does not exist: $Directory"
    }

    $ItemSizes = @()
    $ItemSizes += [PSCustomObject]@{
        Name = "Total"
        Path = $Directory
        Size = "{0,12}" -f (Get-ItemSize -ItemPath $Directory -HumanReadable:$HumanReadable)
    }
    $Items = Get-ChildItem -Path $Directory -Force -ErrorAction SilentlyContinue
    # if ($Recurse) {
    #     $Items = Get-ChildItem -Path $Directory -Force -Recurse -ErrorAction SilentlyContinue
    # }
    foreach ($Item in $Items) {
        $Size = Get-ItemSize -ItemPath $Item.FullName -HumanReadable:$HumanReadable
        $ItemSizes += [PSCustomObject]@{
            Name = $Item.Name
            Path = $Item.FullName
            Size = "{0,12}" -f $Size
        }
    }

    # Display results
    Write-Host "Disk Usage Report:" -ForegroundColor Green
    if ($SummaryOnly) {
        $Results = $ItemSizes[0]
        $Results | Format-Table Path, Size -AutoSize
    } else {
        $Results = $ItemSizes
        # align size column  at space (xx GB) or (xx MB) or (xx KB) or (xx Bytes)
        $Results | Format-Table Path, Size -AutoSize
    }

    # Export results if needed
    if ($ExportPath) {
        Write-Host "Exporting report to: $ExportPath" -ForegroundColor Yellow
        $Results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        Write-Host "Report exported successfully!" -ForegroundColor Green
    }
}
catch {
    Write-Warning "An error occurred: $_"
}
finally {
    Write-Host "Disk usage analysis completed." -ForegroundColor Cyan
}