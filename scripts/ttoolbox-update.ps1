# update ttoolbox

param(
    [Parameter(Mandatory = $false)]
    [switch]$CheckOnly
)

# Get the script location
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ttoolboxDir = Split-Path -Parent $scriptDir
Set-Location -Path $ttoolboxDir

git fetch --depth=1 origin;
if ($CheckOnly) {
    $localCommit = git rev-parse HEAD;
    $remoteCommit = git rev-parse origin/main;
    if ($localCommit -ne $remoteCommit) {
        Write-Host "Update available. Run this script without -CheckOnly to update." -ForegroundColor Green
    } else {
        Write-Host "No updates available." -ForegroundColor Yellow
    }
    exit 0;
}
if ($?) { git reset --hard origin/main; }