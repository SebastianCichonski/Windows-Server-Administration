# Data Deduplication — opis konfiguracji i kroki

Ten dokument opisuje konfigurację i uruchomienie Data Deduplication w systemie Windows Server, na podstawie skryptu `DataDeduplication.ps1`.

Zawiera: cel, wymagania, kroki instalacji i konfiguracji, przykładowe polecenia wraz z fragmentami wyjścia, problemy i wskazówki oraz bezpieczeństwo i dobre praktyki.

## Cel
Zmniejszenie zajętości przestrzeni dyskowej poprzez wykrywanie i przechowywanie powtarzających się bloków danych w jednym wspólnym miejscu (deduplikacja), co pozwala zaoszczędzić miejsce na woluminach zawierających duplikaty danych (dokumenty, obrazy dysków VHD/VHDX, pliki instalacyjne itp.).

## Wymagania
- System Windows Server z rolą File Server.
- Uprawnienia administratora lokalnego lub domenowego do instalacji funkcji i konfiguracji woluminów.
- Wymagany dysk/wolumin przeznaczony do deduplikacji (najlepiej dedykowany wolumin danych).
- Dla najlepszej wydajności: ReFS (zalecane) lub NTFS; wystarczająca ilość pamięci i CPU dla operacji deduplikacji.

## Krok po kroku (polecenia z `DataDeduplication.ps1`)

1) Start logowania (transkrypcja)

```powershell
Start-Transcript -Path C:\Dedup_1.txt
```

2) Instalacja roli Data Deduplication

```powershell
Install-WindowsFeature -Name FS-Data-Deduplication -IncludeAllSubFeature

Success Restart Needed Exit Code      Feature Result
------- -------------- ---------      --------------
True    No             Success        {File and iSCSI Services, Data Deduplicati... 

Get-ScheduledTask -TaskPath \Microsoft\Windows\Deduplication\

TaskPath                                       TaskName                          State
--------                                       --------                          -----
\Microsoft\Windows\Deduplication\              BackgroundOptimization            Ready
\Microsoft\Windows\Deduplication\              WeeklyGarbageCollection           Ready
\Microsoft\Windows\Deduplication\              WeeklyScrubbing                   Ready
```


>Ustawienia domyślne:\
 **Optymization** - deduplikuje dane i kompresuje fragmenty plików - raz na godzinę\
**Garbage Collection** - odzyskuje miejsce na dysku, usuwa niepotrzebne fragmenty do których nie ma już odwołań - w każdą sobotę o 2:35\
**Integrity Scrubbing** - identyfikuje uszkodzenia w magazynie fragmentów z powodu awarIi dysków - w każdą sobotę o 3:35
3) Przygotowanie dysku i woluminu

Wyświetlenie dysków i inicjalizacja (przykład dla dysku numer 1):

```powershell
Get-Disk

Number Friendly Name                                                                                      Serial Number                    HealthStatus         OperationalStatus      Total Size Partition
                                                                                                                                                                                                  Style
------ -------------                                                                                      -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                                                          Healthy              Online                      40 GB MBR
1      Msft Virtual Disk                                                                                                                   Healthy              Offline                     14 GB GPT

Initialize-Disk -Number 1
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter J

   DiskPath: \\?\scsi#disk&ven_msft&prod_virtual_disk#6&278c6171&0&000000#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}

PartitionNumber  DriveLetter Offset                                                                                   Size Type
---------------  ----------- ------                                                                                   ---- ----
2                J           16777216                                                                             13.98 GB Basic

Format-Volume -DriveLetter J -FileSystem ReFS

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining     Size
----------- ------------ -------------- --------- ------------ ----------------- -------------     ----
J                        ReFS           Fixed     Healthy      OK                     12.87 GB 13.94 GB
```
4) Utworzenie danych do deduplikacji
   - tworzymy na dysku ktalog 'Data"
   - uruchamiamy skrypt który utworzy pliki
   - sprawdzamy zajętość dysku

```powershell
New-Item -Type Directory -Path 'J:\Data' -Force

    Directory: J:\

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----         8/15/2024  12:57 PM                Data

Start-Process -FilePath J:\CreateFiles.cmd  -PassThru

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
     15       3     1444       2168       0.02   6408   2 cmd

Get-PSDrive -Name J

Name           Used (GB)     Free (GB) Provider      Root                                                                                                                                    CurrentLocation
----           ---------     --------- --------      ----                                                                                                                                    ---------------
J                   5.35          8.59 FileSystem    J:\
```


5) Włączenie deduplikacji na woluminie i uruchomienie optymalizacji

```powershell
Enable-DedupVolume -Volume "J:" -UsageType Default 

Enabled            UsageType          SavedSpace           SavingsRate          Volume
-------            ---------          ----------           -----------          ------
True               Default            0 B                  0 %                  J:
Set-DedupVolume -Volume "J:" -MinimumFileAgeDays 0 

Start-DedupJob -Volume "J:" -Type Optimization -Full

Type               ScheduleType       StartTime              Progress   State                  Volume
----               ------------       ---------              --------   -----                  ------
Optimization       Manual                                    0 %        Queued                 J:
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
Get-PSDrive -Name J

Name           Used (GB)     Free (GB) Provider      Root                                                                                                                                    CurrentLocation
----           ---------     --------- --------      ----                                                                                                                                    ---------------
J                   1.27         12.67 FileSystem    J:\
```



Interpretacja: Deduplikacja zredukowała zajętość z ~5.5 GB do ~1.27 GB, zapisując ~4.28 GB miejsca (ok. 77% oszczędności na tej próbce danych).

6) Zakończenie transkrypcji

```powershell
Stop-Transcript
```

## Najczęstsze problemy i wskazówki

- Zadania harmonogramu nie uruchamiają się: sprawdź czy usługa deduplikacji jest zainstalowana oraz czy harmonogram jest w stanie `Ready` (`Get-ScheduledTask`).
- Brak oszczędności miejsca po optymalizacji:
    - Upewnij się, że pliki spełniają kryteria polityki (np. minimalny wiek pliku) — w przykładzie ustawiono `MinimumFileAgeDays` na 0, aby przetestować natychmiastową optymalizację.
    - Małe pliki i pliki o dużej entropii (szyfrowane, skompresowane) nie będą dobrze się deduplikować.
- Problemy z wydajnością: deduplikacja jest operacją CPU- i I/O-intensywną — monitoruj zużycie i w razie potrzeby planuj zadania poza godzinami szczytu.

## Bezpieczeństwo i dobre praktyki

- Testuj na środowisku nieprodukcyjnym przed wdrożeniem na produkcyjne woluminy.
- Używaj deduplikacji tam, gdzie występują duplikaty (udostępnione foldery z dokumentami, obrazy dysków, repozytoria aktualizacji itp.). Nie stosuj deduplikacji na woluminach z wrażliwymi danymi, które muszą pozostać niezmienione lub są silnie zaszyfrowane.
- Regularnie monitoruj `Get-DedupStatus` i harmonogram zadań (Garbage Collection, Scrubbing).
- Rozważ użycie ReFS dla większej odporności (szczególnie dla maszyn wirtualnych i dużych magazynów).
- Upewnij się, że backup/restore narzędzia obsługują deduplikację (niektóre rozwiązania backupowe mają specjalne wymagania).

## Dodatkowe uwagi

- Deduplikacja dobrze sprawdza się dla: dokumentów użytkowników, repozytoriów plików binarnych (pliki instalacyjne, CAB), magazynów VHD/VHDX/VDI, oraz kopii zapasowych MSSQL/Exchange (w zależności od scenariusza).

---
