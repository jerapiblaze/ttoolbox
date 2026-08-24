<#
.SYNOPSIS
    Continuously executes a command and displays its output.

.PARAMETER Command
    The command to execute.

.PARAMETER Interval
    The interval in seconds between command executions. Default is 2.

.PARAMETER MaxLines
    The maximum number of lines to display. Default is -1 (no limit).

.PARAMETER Tail
    If specified, shows the last $MaxLines lines of output. Default is $false.
#>
param (
    [Parameter(Mandatory=$false)]
    [string]$Command = "",
    [Parameter(Mandatory=$false)]
    [int]$Interval = 2,
    [Parameter(Mandatory=$false)]
    [int]$MaxLines = -1,
    [Parameter(Mandatory=$false)]
    [switch]$Tail = $false
)

if ($Command -eq "") {
    Get-Help watch-command.ps1 -Detailed
    exit
}

while ($true) {
    Clear-Host;
    # Banner: Every $Interval seconds: $Command <flexible white space> <current time>
    $left_txt     = "Every $Interval seconds: $Command"
    $right_txt    = (Get-Date).ToString("HH:mm:ss")
    $width_txt = $Host.UI.RawUI.WindowSize.Width
    $padding_txt = $width_txt - $left_txt.Length - $right_txt.Length
    if ($padding_txt -lt 1) { $padding_txt = 1 }
    if ($MaxLines -gt 0) {
        $maxLines_txt = $MaxLines - 5   # leave room for header/footer if needed
    } else {
        $height_txt = $Host.UI.RawUI.WindowSize.Height
        $maxLines_txt = $height_txt - 5
    }
    Write-Host "$left_txt$([string]::new(' ', $padding_txt))$right_txt" -BackgroundColor DarkBlue -ForegroundColor White
    $seperator_txt = "-" * $width_txt
    Write-Host $seperator_txt
    $time_start = Get-Date
    $output_txt = (Invoke-Expression $Command 2>&1 3>&1 4>&1 5>&1 6>&1 | Out-String)
    $time_end = Get-Date
    $execution_time = $time_end - $time_start
    $output_txt = $output_txt -split [Environment]::NewLine
    if ($output_txt.Length -gt $maxLines_txt) {
        if ($Tail) {
            $output_txt = $output_txt[($output_txt.Length - $maxLines_txt)..($output_txt.Length - 1)]
        } else {
            $output_txt = $output_txt[0..($maxLines_txt-1)]
        }
        $output_txt = $output_txt -join [Environment]::NewLine
        Write-Host $output_txt
        Write-Host $seperator_txt
        Write-Host "Output truncated to $maxLines_txt lines..." -ForegroundColor Yellow
        Write-Host "Execution time: $($execution_time.TotalSeconds) seconds" -ForegroundColor Green
    } else {
        $output_txt = $output_txt -join [Environment]::NewLine
        Write-Host $output_txt
        Write-Host $seperator_txt
        Write-Host "Execution time: $($execution_time.TotalSeconds) seconds" -ForegroundColor Green
    }
    Start-Sleep -Seconds $Interval
}