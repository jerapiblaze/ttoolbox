<#
.SYNOPSIS
    Get pagefile information.

.DESCRIPTION
    This script retrieves information about the system pagefile(s) including filename, size, current usage, and peak usage.
#>

$pf = Get-CimInstance Win32_PageFileUsage

"{0,-40} {1,-10} {2,-10} {3,-10}" -f "Filename", "Size", "Used", "Peak"
"{0,-40} {1,-10} {2,-10} {3,-10}" -f $pf.Name, $pf.AllocatedBaseSize, $pf.CurrentUsage, $pf.PeakUsage
