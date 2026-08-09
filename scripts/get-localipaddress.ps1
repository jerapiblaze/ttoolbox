# This script retrieves and displays the local IP address of all interfaces on the machine in a pretty format.
param (
    [Parameter(Mandatory = $false)]
    [switch]$Help = $false,
    [Parameter(Mandatory = $false)]
    [switch]$IPv4,
    [Parameter(Mandatory = $false)]
    [switch]$IPv6
)
if ($Help) {
    Get-Help get-localipaddress.ps1 -Detailed
    return;
}
Get-NetIPAddress | Where-Object {
    ($IPv4 -and $_.AddressFamily -eq "IPv4") -or
    ($IPv6 -and $_.AddressFamily -eq "IPv6") -or
    (-not $IPv4 -and -not $IPv6)
} | Format-Table -Property InterfaceAlias, AddressFamily, IPAddress, PrefixLength, PreferredLifetime -AutoSize