# Generowanie klucza głównego usługi KDS na kontrolerze domeny z pominięciem czasu propagacji - 10h
Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10)) 

# Wynik utworzenia klucza można zweryfikować w dzienniku operacyjnym KdsSvc numer zdarzenia 4004
Get-WinEvent -LogName Microsoft-Windows-KdsSvc/Operational | Where-Object -Property id -EQ 4004

# Tworzenie grupy dla serwwerów które będą mogły używać konta gSMA
New-ADGroup -Name "SQLFarm" -SamAccountName "SQLFarm" -GroupCategory Security -GroupScope Global -Path "CN=Computers,DC=azseblab,DC=com"

# Sprawdzenie
Get-ADGroup -Identity "SQLFarm"

# Dodanie serwerów do grupy
Get-ADComputer -Filter 'Name -like "svr-sql*"' | Add-ADPrincipalGroupMembership -MemberOf SQLFarm

#Sprawdzenie
Get-ADGroupMember -Identity SQLFarm | Select-Object -Property Name

# Tworzenie konta gSMA
New-ADServiceAccount -Name SQLFarm_gMSA -DNSHostName SQLFarm_gSMA.azseblab.com -PrincipalsAllowedToRetrieveManagedPassword SQLFarm

#Sprawdzenie
Get-ADServiceAccount -Identity SQLFarm_gMSA

# Na serwerze docelowym
# Instalowanie komend Powershell z modułu ActiveDirectory
Add-WindowsFeature rsat-ad-powershell
Import-Module activedirectory

#Instalacja konta gMSA
Install-ADServiceAccount -Identity SQLFarm_gMSA
