Start-Transcript -Path 'C:\cyberlab\ad_setup.log' -Append
      
Start-Sleep -Seconds 60

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest -Uri https://github.com/git-for-windows/git/release/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe -OutFile git-installer.exe;
    Start-Process .\\git-installer.exe -ArgumentList '/VERYSILENT','/NORESTART' -Wait;
    };

git clone https://github.c  om/fozziiee/AD.git C:\\cyberlab;

cd C:\\cyberlab\\code;

powershell -ExecutionPolicy Unrestricted -File bootstrap_ad.ps1 -Users 10 -Groups 3 -Admins 1

powershell Stop-Transcript