# Wirtualizacja zagnieżdżona
Wirtualizacja zagnieżdżona jest funkcją umożliwiającą uruchomienie funkcji Hyper-V wewnątrz maszyny wirtualnej.

Wymagania:
> - Procesor Intel z technologią VT-x i EPT
> - Host funkcji Hyper-V musi mieć system Windows Server 2016 lub nowszy albo Windows 10 lub nowszy.
> - Konfiguracja maszyny wirtualnej w wersji 8.0 lub nowszej.

> - Procesor AMD EPYC / Ryzen lub nowszy
> - Host funkcji Hyper-V musi mieć system Windows Server 2022 lub nowszy albo Windows 11 lub nowszy.
> - Konfiguracja maszyny wirtualnej w wersji 9.3 lub nowszej.

Włączyć wirtualizację zagnieżdżoną możemy gdy maszyna jest w stanie wyłączonym.

Sprawdzamy w jakim stanie jest maszyna:
```powershell
> Get-VM -Name SEA-SVR2

Name     State CPUUsage(%) MemoryAssigned(M) Uptime   Status           Version
----     ----- ----------- ----------------- ------   ------           -------
SEA-SVR2 Off   0           0                 00:00:00 Działa normalnie 11.0   
```
Włączamy obsługę wirtualizacji zagnieżdżonej dla tej maszyny, wydając poniższą komendę na hoście funkcji Hyper-V:
```powershell
> Set-VMProcessor -VMName SEA-SVR2 -ExposeVirtualizationExtensions $true
```
Sprawdzamy:
```powershell
> Get-VMProcessor -VMName SEA-SVR2 | Select-Object -Property ExposeVirtualizationExtensions

ExposeVirtualizationExtensions
------------------------------
                          True
```
Aby zagnieżdżone maszyny wirtualne mogły komunikować się po przez sieć LAN, musimy przepuścić pakiety przez dwa przełączniki wirtualne, żeby to zrobić włączamy fałszowanie adresów MAC na pierwszym przełączniku:
```powershell
> Get-VMNetworkAdapter -VMName SEA-SVR2 | Set-VMNetworkAdapter -MacAddressSpoofing On
```
Sprawdzamy:
```powershell
> Get-VMNetworkAdapter -VMName SEA-SVR2 | Select-Object -Property MacAddressSpoofing

MacAddressSpoofing
------------------
                On
```
Inną opcją udostępniania maszynom zagnieżdżonym sieci jest wykorzystanie translacji adresów sieciowych.

Na tak skonfigurowanej maszynie możemy uruchamiać kolejne maszyny wirtualne.