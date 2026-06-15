Write-Output "C-Media Restart"
$process = Get-Process "cmediaaudiocontrolpanel"
$process_id = $process.Id
Write-Output "🛑 Stopping old process..."
Stop-Process -Id $process_id -Force
while (Get-CimInstance Win32_Process -Filter "ProcessId=$process_id") {
    Write-Output "🕒 Waitng for C-Media Control Panel to exit...";
    Start-Sleep -Milliseconds 1000;
}
Write-Output "🟢 Starting C-Media Control Panel...";
Launch-Application "C-Media Audio Control Panel"
Write-Output "✅ Done."