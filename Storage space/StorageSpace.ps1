# Dyski fizyczne dostępne do dodania do puli magazynów (znajdujące sie w puli pierwotnej)
Get-PhysicalDisk -CanPool $true

# Pierwotna pula magazynów
Get-StoragePool -IsPrimordial $true

# Nowa pula magazynów utworzona z wszystkich dysków z puli pierwotnej
New-StoragePool –FriendlyName SP1 –StorageSubsystemFriendlyName "Windows Storage*" –PhysicalDisks (Get-PhysicalDisk –CanPool $True)

# Spraedzenie wszystkich pul magazynów
Get-StoragePool

# utworzenie dublowanego wirtualnego dysku w puli SP1 z maksymalnej pojemności puli
New-VirtualDisk –StoragePoolFriendlyName SP1 –FriendlyName VD1 –ResiliencySettingName Mirror –UseMaximumSize -ProvisioningType Fixed

# Pobieramy dysk fizyczny z dysku wirtualnego inicjujemy go domyślnym stylem partycji GPT, tworzymy nową partycję używając maksymalnej dostępnej ilości miejsca, 
# formatujemy wolumin systemem plików ReFS i nadajemy etykirtę "Mirror"
Get-VirtualDisk -FriendlyName VD1 | Get-Disk | Initialize-Disk -PassThru | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem ReFS -NewFileSystemLabel "Mirror"