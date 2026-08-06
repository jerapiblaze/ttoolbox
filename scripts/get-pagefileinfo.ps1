# Get pagefile information

$pf = Get-CimInstance Win32_PageFileUsage

"{0,-40} {1,-10} {2,-10} {3,-10}" -f "Filename", "Size", "Used", "Peak"
"{0,-40} {1,-10} {2,-10} {3,-10}" -f $pf.Name, $pf.AllocatedBaseSize, $pf.CurrentUsage, $pf.PeakUsage
