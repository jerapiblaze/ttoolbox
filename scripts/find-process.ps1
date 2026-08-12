# Find process by any critieria (name, PID, etc.) and display its details.
# Usage: find-process <search_criteria>

param (
    [Parameter(Mandatory = $true)]
    [string]$search_criteria,
    [Parameter(Mandatory = $false)]
    [switch]$ShowUsername,
    [Parameter(Mandatory = $false)]
    [switch]$IncludeCmdLine,
    [Parameter(Mandatory = $false)]
    [switch]$Pipeline
)

# If show username is requested, check if the script is running with elevated privileges
if ($ShowUsername -and -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "To show the username of processes, please run this script with elevated privileges (as Administrator)."
    $ShowUsername = $false
}

# If include command line is requested, show warning that it is very slow and may take a long time to complete
if ($IncludeCmdLine) {
    Write-Warning "Including command line in find may take a long time to complete, especially if there are many processes running."
}

# Get all processes that match the search criteria
$matching_processes = Get-Process -IncludeUserName:$ShowUsername | Where-Object { 
    $_.Name -like "*$search_criteria*" -or 
    $_.Id -eq $search_criteria -or $_.Path -like "*$search_criteria*" -or 
    ($IncludeCmdLine -and [string]((Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine) -like "*$search_criteria*") -or 
    $_.StartTime -like "*$search_criteria*" -or
    $_.UserName -like "*$search_criteria*"
}

$results = $matching_processes | ForEach-Object {
    $process = $_
    $process_info = @{
        User      = $process.UserName
        Name = $process.Name
        Id = $process.Id
        CPU = $process.CPU
        StartTime = $process.StartTime
        CmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($process.Id)").CommandLine
    }
    New-Object PSObject -Property $process_info
}

if ($Pipeline) {
    $results
} else {
    $results | Format-Table -AutoSize
}