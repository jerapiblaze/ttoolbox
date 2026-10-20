<#
.SYNOPSIS
Compact the current Git repository by expiring reflog and running garbage collection.

.DESCRIPTION
This script is useful for reducing the size of the Git repository and cleaning up unnecessary objects.
It is safe to run in every Git repository, as it only performs maintenance tasks.
#>

Write-Host "==== Compact Git repository ====="
Write-Host ">>> Current Git repository size:" -BackgroundColor Gray
git count-objects -vH
Write-Host ">>> Expiring reflog and running garbage collection..." -BackgroundColor Gray
git reflog expire --expire=now --all
git gc --prune=now
Write-Host ">>> Current Git repository size after compaction:" -BackgroundColor Gray
git count-objects -vH
Write-Host ">>> Git repository compacted." -BackgroundColor Gray
Write-Host ">>> Hint: You can further compact by running 'git gc --aggressive' (very slow but thorough, may take a very long time)" -BackgroundColor Green