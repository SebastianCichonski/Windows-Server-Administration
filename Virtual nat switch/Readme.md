# Nat switch
**Problem -** udostępnić maszyną wirtualnym połączenie z Internetem za pomocą obiektu translatora adresów.
#

***Adresacja:***

***Hyper-V host: adres zmienny w zależności z jaką siecią się połączy***

**VMs IP-range: 192.168.100.0/23**
#

Na początek tworzymy nowy wirtualny switch typu **Internal**.

```powershell
New-VMSwitch -Name vSwitch-NAT -SwitchType Internal

Name        SwitchType NetAdapterInterfaceDescription
----        ---------- ------------------------------
vSwitch-NAT Internal
```
Sprawdzamy jakie mamy dostępne switche wirtualne:
```powershell
Get-VMSwitch

Name           SwitchType NetAdapterInterfaceDescription
----           ---------- ------------------------------
vSwitch_Ext    External   Intel(R) Wi-Fi 6 AX200 160MHz
Default Switch Internal
vSwitch-NAT    Internal
```
Następnie sprawdzamy z jakich switchy korzystają maszyny wirtualne:

```powershell
Get-VMNetworkAdapter * 

Name            IsManagementOs VMName   SwitchName     MacAddress   Status IPAddresses
----            -------------- ------   ----------     ----------   ------ -----------
Karta sieciowa  False          SEA-SVR1 Default Switch 00155D60A90A {Ok}   {}
Karta sieciowa  False          SEA-SVR1 Default Switch 00155D60A90F {Ok}   {}
Karta sieciowa  False          SEA-SVR1 Default Switch 00155D60A910 {Ok}   {192.168.100.21, fe80::206a:8e9:140a:24fb}
Karta sieciowa  False          SEA-SVR3 Default Switch 00155D60A90C        {}
Karta sieciowa  False          NYC-DC2  Default Switch 00155D60A907        {}
Network Adapter False          NYC-DC1  Default Switch 00155D60A906 {Ok}   {192.168.100.11, fe80::ecde:6512:f8f7:9adf}
Karta sieciowa  False          SEA-SVR2 Default Switch 00155D60A90B        {}
Karta sieciowa  False          PAR-DC1  Default Switch 00155D60A908        {}
Network Adapter False          COMP001  Default Switch 00155D60A909        {}
```
Wszystkie maszyny podłączone są do domyślnego switcha, zmieniamy to ustawienie na nowoutworzony switch.

```powershell
Get-VMNetworkAdapter * | Where-Object { $_.SwitchName -Ne "vSwitch-NAT" } | Connect-VMNetworkAdapter -SwitchName "vSwitch-NAT"
```

Sprawdzamy czy wszystkie maszyny mają podłączony nowy switch:
```powershell
Get-VMNetworkAdapter *

Name            IsManagementOs VMName   SwitchName  MacAddress   Status IPAddresses
----            -------------- ------   ----------  ----------   ------ -----------
Karta sieciowa  False          SEA-SVR1 vSwitch-NAT 00155D60A90A {Ok}   {}
Karta sieciowa  False          SEA-SVR1 vSwitch-NAT 00155D60A90F {Ok}   {}
Karta sieciowa  False          SEA-SVR1 vSwitch-NAT 00155D60A910 {Ok}   {192.168.100.21, fe80::206a:8e9:140a:24fb}
Karta sieciowa  False          SEA-SVR3 vSwitch-NAT 00155D60A90C        {}
Karta sieciowa  False          NYC-DC2  vSwitch-NAT 00155D60A907        {}
Network Adapter False          NYC-DC1  vSwitch-NAT 00155D60A906 {Ok}   {192.168.100.11, fe80::ecde:6512:f8f7:9adf}
Karta sieciowa  False          SEA-SVR2 vSwitch-NAT 00155D60A90B        {}
Karta sieciowa  False          PAR-DC1  vSwitch-NAT 00155D60A908        {}
Network Adapter False          COMP001  vSwitch-NAT 00155D60A909        {}
```
jak widać wszystko jest ok.
Teraz musimy uzyskać index interfaceu który utworzyliśmy w poprzednich krokach:
```powershell
Get-NetAdapter

Name                      InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed
----                      --------------------                    ------- ------       ----------             ---------
Wi-Fi                     Intel(R) Wi-Fi 6 AX200 160MHz                24 Up           84-1B-77-86-05-9C     144.4 Mbps
Połączenie sieciowe Bl... Bluetooth Device (Personal Area Netw...      18 Disconnected 84-1B-77-86-05-A0         3 Mbps
Ethernet                  Realtek PCIe GbE Family Controller           15 Disconnected 6C-02-E0-96-8A-12          0 bps
vEthernet (vSwitch-NAT)   Hyper-V Virtual Ethernet Adapter #3          33 Up           00-15-5D-60-A9-12        10 Gbps
vEthernet (vSwitch_Ext)   Hyper-V Virtual Ethernet Adapter #2          10 Up           84-1B-77-86-05-9C     144.4 Mbps
Mostek sieciowy           Microsoft Network Adapter Multiplexo...       8 Up           84-1B-77-86-05-9C     144.4 Mbps
```
jak widać indeks vSwitch-NAT to 33.
Przypisujemy adres z zakresu który chcemy używać do interfacu o indeksie 33: 
```powershell
New-NetIPAddress -IPAddress 192.168.100.1 -PrefixLength 23 -InterfaceIndex 33

IPAddress         : 192.168.100.1
InterfaceIndex    : 33
InterfaceAlias    : vEthernet (vSwitch-NAT)
AddressFamily     : IPv4
Type              : Unicast
PrefixLength      : 23
PrefixOrigin      : Manual
SuffixOrigin      : Manual
AddressState      : Tentative
ValidLifetime     :
PreferredLifetime :
SkipAsSource      : False
PolicyStore       : ActiveStore

IPAddress         : 192.168.100.1
InterfaceIndex    : 33
InterfaceAlias    : vEthernet (vSwitch-NAT)
AddressFamily     : IPv4
Type              : Unicast
PrefixLength      : 23
PrefixOrigin      : Manual
SuffixOrigin      : Manual
AddressState      : Invalid
ValidLifetime     :
PreferredLifetime :
SkipAsSource      : False
PolicyStore       : PersistentStore
```
tworzymy obiekt translacji adresów sieciowych, który tłumaczy wewnętrzny adres sieciowy na zewnętrzny adres sieciowy.
```powershell
New-NetNat -Name vNAT -InternalIPInterfaceAddressPrefix 192.168.100.0/23

Name                             : vNAT
ExternalIPInterfaceAddressPrefix :
InternalIPInterfaceAddressPrefix : 192.168.100.0/23
IcmpQueryTimeout                 : 30
TcpEstablishedConnectionTimeout  : 1800
TcpTransientConnectionTimeout    : 120
TcpFilteringBehavior             : AddressDependentFiltering
UdpFilteringBehavior             : AddressDependentFiltering
UdpIdleSessionTimeout            : 120
UdpInboundRefresh                : False
Store                            : Local
Active                           : True
```
Pozostaje jeszcze zaadresowanie maszyn wirtualnych adresami z wybranej puli adresowej.

Technika translacji adresów sieciowych może być wykorzystana żeby umozliwić łączność sieciową zagnieżdżonym maszyną wirtualnym (nested virtualization).