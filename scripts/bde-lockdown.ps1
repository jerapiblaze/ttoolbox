# Bitlocker manual-trigger
Write-Output "==== [Emergengy Lockdown] (Powered by Bitlocker) ===="

if ($Args[0] -eq '-?'){
	Write-Output "This script is intended to quicky lock down your data using Bitlocker."
	Write-Output "You MUST have administrator right to execute this script !!!"
	Write-Output "It is recommended to re-enable TPM after recovering from lockdown using: 'manage-bde -protectors -add C: -tpm'"
	exit;
}

Write-Output "You MUST allow UAC to continue..."

# Self-elevate
if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) 
{
 Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
 Exit
}

# Clear TPM and force using recovery keys
Write-Output "Locking down..."
Initialize-Tpm -AllowClear
manage-bde -fr C:

# Reboot to lock
Write-Output "Locked. Goodluck with recovery keys ;)"
Write-Output "It is recommended to re-enable TPM after recovering from lockdown using: 'manage-bde -protectors -add C: -tpm'"
shutdown -r -t 0 -f