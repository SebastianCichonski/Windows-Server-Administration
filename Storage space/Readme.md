## Storage Spaces — opis i instrukcja

Ten dokument został przygotowany na podstawie skryptu `StorageSpace.ps1`. Zawiera cel, wymagania, kroki konfiguracji (polecenia PowerShell z przykładowymi wyjściami), typowe problemy i wskazówki oraz bezpieczeństwo i dobre praktyki.

## Cel
Utworzenie puli magazynów (Storage Pool) z dostępnych dysków fizycznych, a następnie utworzenie wirtualnego dysku o odporności Mirror i sformatowanie go systemem plików ReFS. Rozwiązanie pozwala na logiczne grupowanie fizycznych urządzeń magazynowych i tworzenie odpornych woluminów.

## Wymagania
- Windows Server z rolą Storage (obsługa Storage Spaces).
- co najmniej jeden dysk fizyczny dostępny do dodania do puli (pusta powierzchnia, bez woluminów).
- Do mirror (dublowania) wymagane co najmniej 2 dyski fizyczne.
- Do parity (parzystości) wymagane co najmniej 3 dyski fizyczne.
- Trójstronne mirror/3-way mirror wymaga co najmniej 5 dysków.
- Dyski najlepiej mieć w stanie `CanPool = True` (niesformatowane, bez woluminów).
- Zalecane: nowe dyski dedykowane do puli lub dyski o tej samej pojemności i typie (HDD/SSD/NVMe) dla lepszej wydajności.

## Kroki konfiguracji (przykładowe polecenia)
Poniższe polecenia pochodzą ze skryptu `StorageSpace.ps1`. Uruchom je w sesji PowerShell uruchomionej jako administrator.

1) Sprawdź dyski możliwe do dodania do puli:

```powershell
Get-PhysicalDisk -CanPool $true
```

Przykładowe wyjście:

```text
Number FriendlyName      SerialNumber MediaType   CanPool OperationalStatus HealthStatus Usage        Size
------ ------------      ------------ ---------   ------- ----------------- ------------ -----        ----
1      Msft Virtual Disk              Unspecified True    OK                Healthy      Auto-Select 40 GB
2      Msft Virtual Disk              Unspecified True    OK                Healthy      Auto-Select 40 GB
```

2) Zobacz pulę pierwotną (Primordial), w której znajdują się dyski gotowe do zassania:

```powershell
Get-StoragePool -IsPrimordial $true
```

Przykładowe wyjście:

```text
FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly   Size AllocatedSize
------------ ----------------- ------------ ------------ ----------   ---- -------------
Primordial   OK                Healthy      True         False      120 GB           0 B
```

3) Utwórz nową pulę magazynów z dysków dostępnych w puli pierwotnej:

```powershell
New-StoragePool -FriendlyName SP1 -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks (Get-PhysicalDisk -CanPool $True)
```

Przykładowe potwierdzenie:

```text
FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly     Size AllocatedSize
------------ ----------------- ------------ ------------ ----------     ---- -------------
SP1          OK                Healthy      False        False      78.97 GB        512 MB
```

4) Sprawdź listę pul magazynów:

```powershell
 Get-StoragePool

FriendlyName OperationalStatus HealthStatus IsPrimordial IsReadOnly     Size AllocatedSize
------------ ----------------- ------------ ------------ ----------     ---- -------------
Primordial   OK                Healthy      True         False        120 GB      79.97 GB
SP1          OK                Healthy      False        False      78.97 GB        512 MB
```

5) Utwórz wirtualny dysk o odporności Mirror (dublowany) i wykorzystaj maksymalną dostępną pojemność:

```powershell
New-VirtualDisk -StoragePoolFriendlyName SP1 -FriendlyName VD1 -ResiliencySettingName Mirror -UseMaximumSize -ProvisioningType Fixed
```

6) Zainicjuj dysk wirtualny, utwórz partycję, przypisz literę i sformatuj wolumin jako ReFS (etykieta: Mirror):

```powershell
Get-VirtualDisk -FriendlyName VD1 | Get-Disk | Initialize-Disk -PassThru | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem ReFS -NewFileSystemLabel "Mirror"
```

Przykładowe sprawdzenie woluminów:

```powershell
Get-Volume

DriveLetter FriendlyName          FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining     Size
----------- ------------          -------------- --------- ------------ ----------------- -------------     ----
E           Mirror                ReFS           Fixed     Healthy      OK                     36.74 GB 37.94 GB
C           SDT_x64FREE_EN-US_VHD NTFS           Fixed     Healthy      OK                     28.17 GB    40 GB
D                                 Unknown        CD-ROM    Healthy      Unknown                     0 B      0 B
```

## Najczęstsze problemy i wskazówki
- Dyski nie są dostępne do poolowania (`CanPool = False`):
  - Upewnij się, że dysk jest pusty (nie ma na nim partycji/woluminów). Usuń istniejące woluminy przed dodaniem do puli.
  - Niektóre dyski USB lub zewnętrzne obudowy mogą nie obsługiwać poolowania.

- Błędy przy tworzeniu StoragePool:
  - Sprawdź, czy przekazujesz właściwe dyski (`Get-PhysicalDisk -CanPool $True`).
  - Upewnij się, że Storage Spaces service jest uruchomiona i że masz uprawnienia administratora.

- Nierównomierna wydajność lub niższa pojemność niż oczekiwana:
  - Zwróć uwagę na różnice w pojemności dysków; Storage Spaces wykorzystuje sumę dostępnych pojemności i może rezerwować przestrzeń.
  - Dla najlepszej wydajności stosuj dyski o podobnych parametrach (typ, prędkość, pojemność).

- Wybranie niewłaściwego ProvisioningType:
  - `Fixed` rezerwuje miejsce od razu; `Thin` (ThinProvisioning) pozwala na alokację na żądanie, ale wymaga monitorowania wykorzystania.

## Bezpieczeństwo i dobre praktyki
- Testuj proces na środowisku testowym przed wdrożeniem produkcyjnym.
- Zawsze wykonaj backup ważnych danych przed manipulacją dyskami/pulami.
- Monitoruj stan pul i dysków (`Get-StoragePool`, `Get-PhysicalDisk`, `Get-VirtualDisk`, `Get-Volume`).
- Ustal proces alarmowania (np. skrypt monitorujący status dysków i wysyłający e-mail/SMS przy awarii).
- Rozważ użycie ReFS dla lepszej odporności i integralności danych, szczególnie na dużych woluminach.
- Przy planowaniu odporności dobierz właściwy typ (Mirror vs Parity) do scenariusza: Mirror zapewnia lepszą wydajność i szybszą odbudowę; Parity lepszą oszczędność miejsca przy archiwach.
---