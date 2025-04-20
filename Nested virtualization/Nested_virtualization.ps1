<#

Wymagania: 
Zarówno host funkcji Hyper-V, jak i maszyna wirtualna gościa muszą mieć system Windows Server 2016 lub nowszy.
Fizyczny komputer hosta musi mieć wystarczającą ilość statycznej pamięci RAM.
Maszyny wirtualne funkcji Hyper-V muszą mieć wersję konfiguracji 8.0 lub nowszą.
Fizyczny komputer hosta musi być wyposażony w procesor Intel z funkcjami rozszerzeń maszyn wirtualnych (VT-x) i rozszerzonych tabel stron (EPT), 
lub rocesor AMD EPYC/Ryzen lub nowszy

#>

# Sprawdzenie czy maszyna jest wyłączona
Get-VM -Name SEA-SVR2

# Włączenie obsługi wirtualizacj zagnieżdżonej przez procesor maszyny wirtualnej
Set-VMProcessor -VMName SEA-SVR2 -ExposeVirtualizationExtensions $true

# Sprawdzenie
Get-VMProcessor -VMName SEA-SVR2 | Select-Object -Property ExposeVirtualizationExtensions

# Włączenie fałszowania adresów MAC (inna opcja to translacja adresów sieciowych)
Get-VMNetworkAdapter -VMName SEA-SVR2 | Set-VMNetworkAdapter -MacAddressSpoofing On

#Sprawdzenie
Get-VMNetworkAdapter -VMName SEA-SVR2 | Select-Object -Property MacAddressSpoofing