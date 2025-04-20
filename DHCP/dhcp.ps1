#
# Wdrożenie serwera DHCP
#
Start-Transcript -Path c:\dhcp.txt

#
# Krok 0. Instalowanie usługi.
#
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Get-WindowsFeature -Name DHCP

#
# Krok 1. Utworzenie lokalnych grup zabezpieczeń
#
Add-DhcpServerSecurityGroup -Computer SEA-SVR3.AZSEBLAB.COM
Get-LocalGroup -Name *dhcp*
Restart-Service -Name DHCPServer

#
# Krok 2. Autoryzacja serwera DHCP w AD DS (wymagane poświadczenia Enterprise Administratora)
#
Add-DhcpServerInDC SEA-SVR3.AZSEBLAB.COM 
Get-DhcpServerInDC

#
# Krok 3. Konfiguracja zakresu DHCP
#
# Zakresy
Add-DhcpServerv4Scope -Name Scope01 -StartRange 192.168.101.1 -EndRange 192.168.101.50 -SubnetMask 255.255.254.0 -State Active
Get-DhcpServerv4Scope 

# Ustawienie dzierżawy adresu na 2 dni 
Set-DhcpServerv4Scope -ComputerName SEA-SVR3.azseblab.com -ScopeId 192.168.100.0 -LeaseDuration 2.00:00:00

# Ustawienie adresu serwera DNS i nazwy domeny na poziomie serwera
Set-DhcpServerv4OptionValue -ComputerName SEA-SVR3.azseblab.com -DnsDomain azseblab.com -DnsServer 192.168.100.11
Get-DhcpServerv4OptionValue

# Ustawienie bramy na poziomie zakresu
Set-DhcpServerv4OptionValue -ComputerName SEA-SVR3.azseblab.com -ScopeId 192.168.100.0 -Router 192.168.100.1
Get-DhcpServerv4OptionValue -ScopeId 192.168.100.0

# ustawienie na poziomie serwera aktualizacji systemu DNS: zawsze aktualizuj wpisy i usuwaj wpisy po wygaśnięciu dzierżawy
Set-DhcpServerv4DnsSetting -ComputerName SEA-SVR3.azseblab.com -DynamicUpdates Always -DeleteDnsRROnLeaseExpiry $true
Get-DhcpServerv4DnsSetting

# 
# Krok 4. Wykluczenia
#
Add-DhcpServerv4ExclusionRange -ScopeId 192.168.100.0 -StartRange 192.168.101.10 -EndRange 192.168.101.19
Get-DhcpServerv4ExclusionRange

# 
#Krok 5. Rezerwacje
#
Add-DhcpServerv4Reservation -ScopeId 192.168.100.0 -IPAddress 192.168.101.100 -ClientId "F0-DE-F1-7A-00-5E" -Description "Reservation for Printer1" -Name Print1
Add-DhcpServerv4Reservation -ScopeId 192.168.100.0 -IPAddress 192.168.101.101 -ClientId "F0-DE-F1-7A-00-5F" -Description "Reservation for Printer2" -Name Print2
Add-DhcpServerv4Reservation -ScopeId 192.168.100.0 -IPAddress 192.168.101.102 -ClientId "F0-DE-F1-7A-00-6A" -Description "Reservation for Printer3" -Name Print3

Get-DhcpServerv4Reservation -ScopeId 192.168.100.0

# Rezerwacje wczytane z pliku .csv
#
#Format pliku:
#ScopeId,IPAddress,Nazwa,ClientId,Opis
#192.168.101.0,192.168.101.103,Komputer1,1a-1b-1c-1d-1e-1f,Rezerwacja dla komputera1
#
Import-Csv -Path "Reservations.csv" | Add-DhcpServerv4Reservation -ComputerName "SEA-SVR3.azseblab.com"
Get-DhcpServerv4Reservation -ScopeId 192.168.100.0
#
#
Stop-Transcript