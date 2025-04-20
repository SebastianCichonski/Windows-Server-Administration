<#

Adresacja:

Hyper-V host: adres zmienny w zależności z jaką siecią się połączy
VMs IP-range: 192.168.100.0 /23

#>

# Utworzenie nowego wirtualnego switcha typu Internal
New-VMSwitch -Name vSwitch-NAT -SwitchType Internal

Get-VMSwitch

# sprawdzenie do jakich switchy podłączone są VMs
Get-VMNetworkAdapter *  

# Zmiana switcha u wszystkich VMs podłączonych do innych switchy niż wymagany
Get-VMNetworkAdapter * | Where-Object { $_.SwitchName -Ne "vSwitch-NAT" } | Connect-VMNetworkAdapter -SwitchName "vSwitch-NAT"

# Sprawdzenie 
Get-VMNetworkAdapter *

# Sprawdzenie ID utworzonego interface'u 
Get-NetAdapter

# przypisanie pierwszego adresu z zakresu do nowego interface'u
New-NetIPAddress -IPAddress 192.168.100.1 -PrefixLength 23 -InterfaceIndex 33

# utworzenie obiektu NAT
New-NetNat -Name vNAT -InternalIPInterfaceAddressPrefix 192.168.100.0/23

# Sprawdzenie
Get-NetNat

