# enable-winrm.ps1

# Configure WinRM
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Enable Powershell Remoting
Enable-PSRemoting -Force

# Allow WinRM HTTPS through Firewall
New-NetFirewallRule -Name "WinRMHTTPS" -DisplayName "WinRM over HTTPS" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow 