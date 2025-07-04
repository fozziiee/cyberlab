# ad_setup.ps1

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName 'cyberlab.local' -SafeModeAdministratorPassword (Convert-To-SecureString 'P@ssw0rd123' -AsPlainText) -Force:$true;
