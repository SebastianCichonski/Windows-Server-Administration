# DHCP
**DHCP** - to protokół klient/serwer, który automatycznie przypisuje hostowi protokołu internetowego (IP) adres IP i inne powiązane informacje konfiguracyjne, takie jak maska podsieci i brama domyślna, adresy serwerów DNS.

##  Wdrożenie serwera DHCP
### Krok 0. Instalowanie usługi.
```powershell
> Install-WindowsFeature -Name DHCP -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result
------- -------------- ---------      --------------
True    Yes            SuccessRest... {DHCP Server, Remote Server Administration...
WARNING: You must restart this server to finish the installation process.


> Get-WindowsFeature -Name DHCP

Display Name                                            Name                       Install State
------------                                            ----                       -------------
[X] DHCP Server                                         DHCP                      InstallPending
```
### Krok 1. Utworzenie lokalnych grup zabezpieczeń
Tworzymy lokalne grupy zabezpieczeń powiązane z usługą DHCP:
```powershell
> Add-DhcpServerSecurityGroup -Computer SEA-SVR3.AZSEBLAB.COM  

> Get-LocalGroup -Name *dhcp*

Name                Description
----                -----------
DHCP Administrators Members who have administrative access to the DHCP Service
DHCP Users          Members who have view-only access to the DHCP service
```
### Krok 2. Autoryzacja serwera DHCP w AD DS 
Do wykonania tego kroku wymagane są poświadczenia Enterprise Administratora
```powershell
> Add-DhcpServerInDC SEA-SVR3.AZSEBLAB.COM 

> Get-DhcpServerInDC

IPAddress            DnsName                                                                         
---------            -------                                                                         
192.168.100.23       sea-svr3.azseblab.com  
```
### Krok 3. Konfiguracja zakresu DHCP
#### Ustawienie zakresu
```powershell
> Add-DhcpServerv4Scope -Name Scope01 -StartRange 192.168.101.1 -EndRange 192.168.101.50 -SubnetMask 255.255.254.0 -State Active

> Get-DhcpServerv4Scope 

ScopeId         SubnetMask      Name           State    StartRange      EndRange        LeaseDuration                                                                    
-------         ----------      ----           -----    ----------      --------        -------------                                                                    
192.168.100.0   255.255.254.0   Scope01        Active   192.168.101.1   192.168.101.50  14.00:00:00                                                                    
```
#### Ustawienie dzierżawy adresu na 2 dni 
```powershell
> Set-DhcpServerv4Scope -ComputerName SEA-SVR3.azseblab.com -ScopeId 192.168.100.0 -LeaseDuration 2.00:00:00

> Get-DhcpServerv4Scope 

ScopeId         SubnetMask      Name           State    StartRange      EndRange        LeaseDuration                                                                    
-------         ----------      ----           -----    ----------      --------        -------------                                                                    
192.168.100.0   255.255.254.0   Scope01        Active   192.168.101.1   192.168.101.50  2.00:00:00   
```
#### Ustawienie adresu serwera DNS i nazwy domeny na poziomie serwera
```powershell
> Set-DhcpServerv4OptionValue -ComputerName SEA-SVR3.azseblab.com -DnsDomain azseblab.com -DnsServer 192.168.100.11

> Get-DhcpServerv4OptionValue

OptionId   Name            Type       Value                VendorClass     UserClass       PolicyName
--------   ----            ----       -----                -----------     ---------       ----------
15         DNS Domain Name String     {azseblab.com}
6          DNS Servers     IPv4Add... {192.168.100.11}
```
#### Ustawienie bramy na poziomie zakresu
```powershell   
> Set-DhcpServerv4OptionValue -ComputerName SEA-SVR3.azseblab.com -ScopeId 192.168.100.0 -Router 192.168.100.1

> Get-DhcpServerv4OptionValue -ScopeId 192.168.100.0

OptionId   Name            Type       Value                VendorClass     UserClass       PolicyName
--------   ----            ----       -----                -----------     ---------       ----------
51         Lease           DWord      {172800}
3          Router          IPv4Add... {192.168.100.1}
```
#### Ustawienie na poziomie serwera aktualizacji systemu DNS: zawsze aktualizuj wpisy i usuwaj wpisy po wygaśnięciu dzierżawy
```powershell
> Set-DhcpServerv4DnsSetting -ComputerName SEA-SVR3.azseblab.com -DynamicUpdates Always -DeleteDnsRROnLeaseExpiry $true

> Get-DhcpServerv4DnsSetting

DynamicUpdates             : Always
DeleteDnsRROnLeaseExpiry   : True
UpdateDnsRRForOlderClients : False
DnsSuffix                  :
DisableDnsPtrRRUpdate      : False
NameProtection             : False
```
### Krok 4. Wykluczenia
```powershell
> Add-DhcpServerv4ExclusionRange -ScopeId 192.168.100.0 -StartRange 192.168.101.10 -EndRange 192.168.101.19

> Get-DhcpServerv4ExclusionRange


ScopeId              StartRange           EndRange
-------              ----------           --------
192.168.100.0        192.168.101.10       192.168.101.19
```
### Krok 5. Rezerwacje
```powershell
> Add-DhcpServerv4Reservation -ScopeId 192.168.101.0 -IPAddress 192.168.101.100 -ClientId "F0-DE-F1-7A-00-5E" -Description "Reservation for Printer1" -Name Print1
> Add-DhcpServerv4Reservation -ScopeId 192.168.101.0 -IPAddress 192.168.101.101 -ClientId "F0-DE-F1-7A-00-5F" -Description "Reservation for Printer2" -Name Print2
> Add-DhcpServerv4Reservation -ScopeId 192.168.101.0 -IPAddress 192.168.101.102 -ClientId "F0-DE-F1-7A-00-6A" -Description "Reservation for Printer3" -Name Print3

> Get-DhcpServerv4Reservation -ScopeId 192.168.100.0

IPAddress            ScopeId              ClientId             Name                 Type                 Description
---------            -------              --------             ----                 ----                 -----------
192.168.101.100      192.168.100.0        f0-de-f1-7a-00-5e    Print1               Both                 Reservation for P...
192.168.101.101      192.168.100.0        f0-de-f1-7a-00-5f    Print2               Both                 Reservation for P...
192.168.101.102      192.168.100.0        f0-de-f1-7a-00-6a    Print3               Both                 Reservation for P...
```
#### Rezerwacje wczytane z pliku .csv

Format pliku:
```
ScopeId,IPAddress,Name,ClientId,Description
192.168.101.0,192.168.101.103,Komputer1,1a-1b-1c-1d-1e-1f,Rezerwacja dla komputera1
```
```powershell
> Import-Csv -Path "Reservations.csv" | Add-DhcpServerv4Reservation -ComputerName "SEA-SVR3.azseblab.com"

> Get-DhcpServerv4Reservation -ScopeId 192.168.100.0

IPAddress            ScopeId              ClientId             Name                 Type                 Description
---------            -------              --------             ----                 ----                 -----------
192.168.101.100      192.168.100.0        f0-de-f1-7a-00-5e    Print1               Both                 Reservation for P...
192.168.101.101      192.168.100.0        f0-de-f1-7a-00-5f    Print2               Both                 Reservation for P...
192.168.101.102      192.168.100.0        f0-de-f1-7a-00-6a    Print3               Both                 Reservation for P...
192.168.101.114      192.168.100.0        1a-1b-1c-1d-1e-2f    Komputer14           Both                 Rezerwacja dla ko...
192.168.101.113      192.168.100.0        1a-1b-1c-1d-1e-1f    Komputer13           Both                 Rezerwacja dla ko...
192.168.101.120      192.168.100.0        1a-1b-1c-1d-1e-8f    Komputer20           Both                 Rezerwacja dla ko...
192.168.101.117      192.168.100.0        1a-1b-1c-1d-1e-5f    Komputer17           Both                 Rezerwacja dla ko...
192.168.101.115      192.168.100.0        1a-1b-1c-1d-1e-3f    Komputer15           Both                 Rezerwacja dla ko...
192.168.101.118      192.168.100.0        1a-1b-1c-1d-1e-6f    Komputer18           Both                 Rezerwacja dla ko...
192.168.101.116      192.168.100.0        1a-1b-1c-1d-1e-4f    Komputer16           Both                 Rezerwacja dla ko...
192.168.101.119      192.168.100.0        1a-1b-1c-1d-1e-7f    Komputer19           Both                 Rezerwacja dla ko...
```