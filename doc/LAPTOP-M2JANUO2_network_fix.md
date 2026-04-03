# Network Connection Fix: LAPTOP-M2JANUO2

**Date:** 2026-04-03
**Issue:** "Windows cannot access \\LAPTOP-M2JANUO2" from this PC (jsong12)

---

## Network Info

| Item | Value |
|------|-------|
| This PC IP | 192.168.1.200 |
| Remote PC IP | 192.168.1.58 |
| Remote PC Name | LAPTOP-M2JANUO2 |
| Remote PC MAC | 8C-1D-96-0F-3A-34 |
| Remote Workgroup | WORKGROUP |
| Wi-Fi Network | Freebox-2B6952_EXT |
| Wi-Fi Adapter | Intel(R) Wi-Fi 6E AX211 160MHz |

---

## Issues Found & Fixed on This PC

| # | Issue | Before | After | How Fixed |
|---|-------|--------|-------|-----------|
| 1 | Network profile was Public | Public | **Private** | `Set-NetConnectionProfile -InterfaceAlias 'Wi-Fi' -NetworkCategory Private` |
| 2 | Network Discovery blocked by firewall | Disabled | **Enabled** | `Set-NetFirewallRule -DisplayGroup 'Network Discovery' -Profile Private -Enabled True` |
| 3 | File & Printer Sharing blocked by firewall | Disabled | **Enabled** | `Set-NetFirewallRule -DisplayGroup 'File and Printer Sharing' -Profile Private -Enabled True` |
| 4 | FDResPub service stopped | Stopped / Manual | **Running / Automatic** | `Start-Service FDResPub; Set-Service FDResPub -StartupType Automatic` |
| 5 | Insecure guest logons disabled | False | **True** | Registry: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation\AllowInsecureGuestAuth = 1` |
| 6 | Mailslots disabled | False | **True** | `Set-SmbClientConfiguration -EnableMailslots $True` |
| 7 | SMB security signature required | True | **False** | Registry: `HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters\RequireSecuritySignature = 0` |
| 8 | Name resolution failed (ping by name) | Could not resolve | **Resolves OK** | Added `192.168.1.58 LAPTOP-M2JANUO2` to `C:\Windows\System32\drivers\etc\hosts` |

---

## Current Status

- Ping by name: **Working**
- Ping by IP: **Working** (avg 14ms)
- SMB port 445: **Open** on remote PC
- NetBIOS port 139: **Open** on remote PC
- `net view \\LAPTOP-M2JANUO2`: **Error 1702** (binding handle invalid) - this is an RPC/browse service issue on the **remote PC**
- Direct share access: **Fails** - likely no folders shared on remote PC, or remote PC requires authentication

---

## Remaining Steps (must be done on LAPTOP-M2JANUO2)

### 1. Set Network to Private
Settings > Network & Internet > Wi-Fi > Connection properties > **Private**

### 2. Enable File Sharing
Settings > Advanced sharing settings > Turn on:
- Network discovery
- File and printer sharing

### 3. Share a Folder
Right-click folder > Properties > Sharing tab > Share > Add "Everyone" with Read permission

### 4. Create a User Account (if needed for authentication)

**Option A - CMD (as Admin):**
```cmd
net user NewUsername Password123 /add
net localgroup Administrators NewUsername /add
```

**Option B - PowerShell (as Admin):**
```powershell
New-LocalUser -Name "NewUsername" -Password (ConvertTo-SecureString "Password123" -AsPlainText -Force) -FullName "Display Name"
Add-LocalGroupMember -Group "Administrators" -Member "NewUsername"
```

**Option C - GUI:**
Settings > Accounts > Other users > Add account > "I don't have this person's sign-in information" > "Add a user without a Microsoft account"

### 5. Connect from This PC
```cmd
net use \\LAPTOP-M2JANUO2\ShareName /user:LAPTOP-M2JANUO2\NewUsername Password123
```
Or in File Explorer: `\\LAPTOP-M2JANUO2` and enter credentials when prompted:
- Username: `LAPTOP-M2JANUO2\NewUsername`
- Password: the password you set

---

## SMB Configuration Reference (This PC)

```
SMB1: Disabled (Windows Feature level)
SMB2: Enabled
EnableInsecureGuestLogons: True
EnableMailslots: True
RequireSecuritySignature: False
RequireEncryption: False
```

## Services Status (This PC)

| Service | Status | Startup |
|---------|--------|---------|
| LanmanServer | Running | Automatic |
| LanmanWorkstation | Running | Automatic |
| FDResPub | Running | Automatic |
| fdPHost | Running | Manual |
| SSDPSRV | Running | Manual |
| upnphost | Running | Manual |
| Browser (bowser) | Running | Manual |
| lmhosts | Running | Manual |
| mrxsmb | Running | Manual |
| mrxsmb20 | Running | Manual |

## user/pss
jz/zl
