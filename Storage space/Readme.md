# Storage Space
**Storage space** to technologia umożliwiająca grupowanie dysków w pule magazynów a następnie tworzenie z tych pul dysków wirtualnych, technologia zapewnia także dwa typy odporności: **Mirror** i **Parity**.

Poziomy odporności i wymagania dot. dysków:
- Do utworzenia puli magazynów wymagany jest jeden dysk fizyczny.
- Do utworzenia odpornego dublowanego dysku wirtualnego wymagane są co najmniej dwa dyski fizyczne.
- Do utworzenia dysku wirtualnego z odpornością dzięki parzystości wymagane są co najmniej trzy dyski fizyczne.
- Trójstronne dublowanie wymaga co najmniej pięciu dysków fizycznych.
- Dyski muszą być puste i niesformatowane. Na dyskach nie może istnieć żaden wolumin.
- Dyski można dołączać przy użyciu różnych interfejsów magistrali, w tym interfejsu SCSI (Small Computer System Interface), Serial Attached SCSI (SAS), Serial ATA (SATA), NVM Express (NVMe).

Sprawdzamy dostępne dyski, które możemy dodać do puli magazynu:
```powershell
Get-PhysicalDisk -CanPool $true

Number FriendlyName      SerialNumber MediaType   CanPool OperationalStatus HealthStatus Usage        Size
------ ------------      ------------ ---------   ------- ----------------- ------------ -----        ----
1      Msft Virtual Disk              Unspecified True    OK                Healthy      Auto-Select 40 GB
2      Msft Virtual Disk              Unspecified True    OK                Healthy      Auto-Select 40 GB
```
**CanPoll** to pula pierwotna w której znajdują się dyski dostępne do dodania do puli magazynów (niewykorzystane).

Sprawdzamy dostępne pule magazynów na komputerze:
```powershell
Get-StoragePool 

FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly   Size AllocatedSize
------------ ----------------- ------------ ------------ ----------   ---- -------------
Primordial   OK                Healthy      True         False      120 GB           0 B
```
Tworzymy nową pulę magazynu ze wszystkich dostępnych dysków w puli pierwotnej:
```powershell
New-StoragePool –FriendlyName SP1 –StorageSubsystemFriendlyName "Windows Storage*" –PhysicalDisks (Get-PhysicalDisk –CanPool $True)

FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly     Size AllocatedSize
------------ ----------------- ------------ ------------ ----------     ---- -------------
SP1          OK                Healthy      False        False      78.97 GB        512 MB
```
Sprawdzamy dostępne pule magazynów
```powershell
 Get-StoragePool

FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly     Size AllocatedSize
------------ ----------------- ------------ ------------ ----------     ---- -------------
Primordial   OK                Healthy      True         False        120 GB      79.97 GB
SP1          OK                Healthy      False        False      78.97 GB        512 MB
```
Tworzymy dublowany wirtualny dysk w puli SP1 z maksymalnej dostępnej pojemności. Opis typów odporności dostępny tu: [klik](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh831739(v=ws.11))

```powershell
New-VirtualDisk –StoragePoolFriendlyName SP1 –FriendlyName VD1 –ResiliencySettingName Mirror –UseMaximumSize -ProvisioningType Fixed
```
Pobieramy dysk fizyczny z dysku wirtualnego inicjujemy go domyślnym stylem partycji GPT, tworzymy nową partycję używając maksymalnej dostępnej ilości miejsca, formatujemy wolumin systemem plików ReFS i nadajemy etykirtę "Mirror"
```powershell
Get-VirtualDisk -FriendlyName VD1 | Get-Disk | Initialize-Disk -PassThru | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem ReFS -NewFileSystemLabel "Mirror"
```
Sprawdzamy czy dysk jest dostępny:

```powershell
Get-Volume

DriveLetter FriendlyName          FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining     Size
----------- ------------          -------------- --------- ------------ ----------------- -------------     ----
E           Mirror                ReFS           Fixed     Healthy      OK                     36.74 GB 37.94 GB
C           SDT_x64FREE_EN-US_VHD NTFS           Fixed     Healthy      OK                     28.17 GB    40 GB
D                                 Unknown        CD-ROM    Healthy      Unknown                     0 B      0 B
```