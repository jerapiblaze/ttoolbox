# Change the priority of a scheduled task
# Reference: https://stackoverflow.com/questions/47197821/how-to-change-default-scheduled-task-process-priority-in-windows
<#
.SYNOPSIS
    Change the priority of a scheduled task.

.DESCRIPTION
    This script allows you to change the priority of a specified scheduled task.

.PARAMETER TaskName
    The name of the scheduled task.

.PARAMETER Priority
    The new priority for the task. Valid values are 0 (Deadline), 1 (Real Time), 2 (High), 3 (Above Normal), 4 (Normal), 5 (Below Normal), 6 (Low), 7 (Background).
#>
param (
    [Parameter(Mandatory = $false)]
    [string]$TaskName = "",
    [Parameter(Mandatory = $false)][ValidateSet(0, 1, 2, 3, 4, 5, 6, 7)]
    [int]$Priority = 4
)

if ($TaskName -eq "") {
    Get-Help Set-TaskPriority.ps1 -Detailed
    exit
}

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    throw "This script must be run as Administrator."
}

# 0: Deadline, 1: Real Time, 2: High, 3: Above Normal, 4: Normal, 5: Below Normal, 6: Low, 7: Background
try {
    $Task = Get-ScheduledTask -TaskName $TaskName
}
catch [System.Exception] {
    throw "Could not find task with name $TaskName!"
}
$TaskSettings = $Task.Settings
$OldPriority = $TaskSettings.Priority

Write-Output "TaskName=$TaskName : OldPriority=$OldPriority, NewPriority=$Priority..."
$TaskSettings.Priority = $Priority

try {
    Set-ScheduledTask -TaskName $TaskName -TaskPath $Task.TaskPath -Settings $TaskSettings | 
         Format-Table -AutoSize TaskPath, TaskName, @{Name='OldPriority'; Expression = {$OldPriority}}, `
         @{Name='NewPriority'; Expression = {((Get-ScheduledTask -TaskName $TaskName).Settings).Priority}}
}
catch [System.Exception] {
    throw "Failed to set task priority for $TaskName!"
}