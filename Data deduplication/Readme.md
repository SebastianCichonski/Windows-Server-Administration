# Data Deduplication
**Data deduplication** to funkcja, która może pomóc w zmniejszeniu zajętości przestrzeni na woluminie poprzez wyszukanie zduplikowanych danych i zastępienie ich jednym wystąpieniem.

## Krok 1.
Na początek instalujemy w systemie funkcję deduplikacji danych:
```powershell
> Install-WindowsFeature -Name FS-Data-Deduplication -IncludeAllSubFeature

Success Restart Needed Exit Code      Feature Result
------- -------------- ---------      --------------
True    No             Success        {File and iSCSI Services, Data Deduplicati...
```
Po zainstalowaniu funkcji w harmonogramie zadań tworzone są trzy zadania:
```powershell
> Get-ScheduledTask -TaskPath \Microsoft\Windows\Deduplication\

TaskPath                                       TaskName                          State
--------                                       --------                          -----
\Microsoft\Windows\Deduplication\              BackgroundOptimization            Ready
\Microsoft\Windows\Deduplication\              WeeklyGarbageCollection           Ready
\Microsoft\Windows\Deduplication\              WeeklyScrubbing                   Ready
```
**Optymization** - deduplikuje dane i kompresuje fragmenty plików - raz na godzinę

**Garbage Collection** - odzyskuje miejsce na dysku, usuwa niepotrzebne fragmenty do których nie ma już odwołań - w każdą sobotę o 2:35

**Integrity Scrubbing** - identyfikuje uszkodzenia w magazynie fragmentów z powodu awarIi dysków - w każdą sobotę o 3:35

## Krok 2.
Przygotujemy nowy dysk pod deduplikację danych.

Wyświetlamy dostępne dyski:
```powershell
> Get-Disk

Number Friendly Name                                                                                      Serial Number                    HealthStatus         OperationalStatus      Total Size Partition
                                                                                                                                                                                                  Style
------ -------------                                                                                      -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                                                          Healthy              Online                      40 GB MBR
1      Msft Virtual Disk                                                                                                                   Healthy              Offline                     14 GB GPT
```
Inicjujemy dysk numer 1 domyślnymi wartościami, spowoduje to zainicjowanie dysku przy użyciu stylu partycji GPT:
```powershell
> Initialize-Disk -Number 1

> Get-Disk

Number Friendly Name                                 Serial Number                    HealthStatus         OperationalStatus      Total Size Partition
                                                                                                                                             Style
------ -------------                                 -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                     Healthy              Online                      40 GB MBR
1      Msft Virtual Disk                                                              Healthy              Online                       14 GB GPT
```
Tworzymy nową partycję, przypisujemy literę dysku i formatujemy za pomocą systemu plików ReFS:
```powershell
> New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter J

   DiskPath: \\?\scsi#disk&ven_msft&prod_virtual_disk#6&278c6171&0&000000#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}

PartitionNumber  DriveLetter Offset                                                                                   Size Type
---------------  ----------- ------                                                                                   ---- ----
2                J           16777216                                                                             13.98 GB Basic

> Format-Volume -DriveLetter J -FileSystem ReFS

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining     Size
----------- ------------ -------------- --------- ------------ ----------------- -------------     ----
J                        ReFS           Fixed     Healthy      OK                     12.87 GB 13.94 GB
```
## Krok 3.
Tworzymy na dysku dane które będą poddane deduplikacji:
- tworzymy na dysku ktalog 'Data"
- uruchamiamy skrypt który utworzy pliki 
- sprawdzamy zajętość dysku
```powershell
> New-Item -Type Directory -Path 'J:\Data' -Force

    Directory: J:\

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         8/15/2024  12:57 PM                Data

> Start-Process -FilePath J:\CreateFiles.cmd  -PassThru

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
     15       3     1444       2168       0.02   6408   2 cmd

> Get-PSDrive -Name J

Name           Used (GB)     Free (GB) Provider      Root                                                                                                                                    CurrentLocation
----           ---------     --------- --------      ----                                                                                                                                    ---------------
J                   5.35          8.59 FileSystem    J:\
``` 
Utworzone pliki zajęły 5.35 GB, wolnego miejsca na dysku zostało 8.59 GB.

## Krok 4.
Włączamy deduplikację danych:
```powershell
Enable-DedupVolume -Volume "J:" -UsageType Default 

Enabled            UsageType          SavedSpace           SavingsRate          Volume
-------            ---------          ----------           -----------          ------
True               Default            0 B                  0 %                  J:
```
Ustawiamy minimalny wiek pliku przeznaczonego do deduplikacji na 0 dni i uruchamiamy zadanie deduplikacji:
```powershell
> Set-DedupVolume -Volume "J:" -MinimumFileAgeDays 0 

> Start-DedupJob -Volume "J:" -Type Optimization -Full

Type               ScheduleType       StartTime              Progress   State                  Volume
----               ------------       ---------              --------   -----                  ------
Optimization       Manual                                    0 %        Queued                 J:
```
Sprawdzamy stan deduplikacji:
```powershell
Get-DedupStatus | fl

Volume                             : J:
VolumeId                           : \\?\Volume{ffa5fcf8-1ec5-4b9f-8c85-d3b931121b2a}\
Capacity                           : 13.94 GB
FreeSpace                          : 12.67 GB
UsedSpace                          : 1.27 GB
UnoptimizedSize                    : 5.54 GB
SavedSpace                         : 4.28 GB
SavingsRate                        : 77 %
OptimizedFilesCount                : 60
OptimizedFilesSize                 : 4.28 GB
OptimizedFilesSavingsRate          : 99 %
InPolicyFilesCount                 : 60
InPolicyFilesSize                  : 4.28 GB
LastOptimizationTime               : 8/15/2024 1:11:44 PM
LastOptimizationResult             : 0x00000000
LastOptimizationResultMessage      : The operation completed successfully.
LastGarbageCollectionTime          :
LastGarbageCollectionResult        :
LastGarbageCollectionResultMessage :
LastScrubbingTime                  :
LastScrubbingResult                :
LastScrubbingResultMessage         :
```
Zmienna **LastOptimizationResultMessage** informuje że deduplikacja przebiegła pomyślnie. Jak widać z podsumowania na niewielkiej ilości danych 5.5GB zaoszczędziliśmy 4.2GB.
Sprawdzamy jeszcze dysk:
```powershell
Get-PSDrive -Name J

Name           Used (GB)     Free (GB) Provider      Root                                                                                                                                    CurrentLocation
----           ---------     --------- --------      ----                                                                                                                                    ---------------
J                   1.27         12.67 FileSystem    J:\
```
Na koniec należy jeszcze wspomnieć w jakich przypadkach może być użyta deduplikacja:
- dokumenty użytkowników
- miejsca przechowywania plików binarnych oprogramowania, pliki CAB, obrazy, aktualizacje
- miejsca przechowywania plików dysków twardych VHD, VHDX, VDI
- połączenie powyższych
- woluminy kopii zapasowych MSSQL i Exchange Server