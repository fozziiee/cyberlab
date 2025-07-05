# ad_setup.ps1

New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.1.100 -PrefixLength 24 -DefaultGateway 10.0.1.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName 'cyberlab.local' -SafeModeAdministratorPassword (Convert-To-SecureString 'P@ssw0rd123' -AsPlainText -Force) -Force:$true;
