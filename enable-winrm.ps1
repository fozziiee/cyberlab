# enable-winrm.ps1

Set-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value true
Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value true
Enable-PSRemoting -Force