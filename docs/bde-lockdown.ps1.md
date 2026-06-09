# BitlockerDriveEncryption-Lockdown

This script ***immediate*** clear the TPM (which auto unlocks the OS drive on boot), clear all cached login  credentials, trigger force recovery and reboot.

Inspired from a [Reddit post](https://www.reddit.com/r/sysadmin/comments/p15ugb/remotely_triggering_bitlocker_recovery_screen_to/).

> [!IMPORTANT]
> You should have ***recovery keys backed up*** before using this script. You can check with [`bde-safetycheck.ps1`](bde-safetycheck.ps1.md) script.

You MUST run this script as an administrator, or run this script as admin.

> [!Note]
> It is recommended to re-enable auto-unlock with TPM after running this script.
> 
> ```powershell
> manage-bde -protectors -add C: -tpm
> ```
