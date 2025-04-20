#Tworzenie pliku roli JEA
New-PSRoleCapabilityFile -Path 'C:\Program Files\WindowsPowerShell\Modules\vmrole\RoleCapabilities\VMrole.psrc'

#Tworzenie domyślnego plik konfiguracyjny sesji JEA
New-PSSessionConfigurationFile -path 'c:\JEAEndpoint\VM_JEAEndpoint.pssc'

#Testowanie pliku konfiguracji sesji
Test-PSSessionConfigurationFile -Path 'c:\JEAEndpoint\VM_JEAEndpoint.pssc'

#Rejestracja pliku konfiguracji sesji:
Register-PSSessionConfiguration -Name VMadmin -Path 'C:\JEAEndpoint\VM_JEAEndpoint.pssc'

#Restart usługi WinRM
Restart-Service winrm

#Sprawdzenie czy punkt końcowy został utworzony:
Get-PSSessionConfiguration | Select-Object Name

#Łączenie się z utworzonym punktem końcowym:
Enter-PSSession -ComputerName sea-svr1 -ConfigurationName VMadmin -Credential (Get-Credential)
