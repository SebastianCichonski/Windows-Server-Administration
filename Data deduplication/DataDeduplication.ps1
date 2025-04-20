Start-Transcript -Path c:\Dedup_1.txt

#
# Krok 0. Instalacja Roli Deduplikacji danych
#
Install-WindowsFeature -Name FS-Data-Deduplication -IncludeAllSubFeature
Get-ScheduledTask -TaskPath \Microsoft\Windows\Deduplication\

#
# Krok 1. Przygotowanie dysku pod deduplikacje
#
Get-Disk
Initialize-Disk -Number 1
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter J
Format-Volume -DriveLetter J -FileSystem ReFS

#
# Krok 2. Utworzenie danych do deduplikacji
#
New-Item -Type Directory -Path 'J:\Data' -Force
Start-Process -FilePath J:\CreateFiles.cmd  -PassThru
Get-PSDrive -Name J

#
# Krok 3. Włączenie i konfigurowanie deduplikacji danych
#
Enable-DedupVolume -Volume "J:" -UsageType Default 
Set-DedupVolume -Volume "J:" -MinimumFileAgeDays 0 
Start-DedupJob -Volume "J:" -Type Optimization -Full
Get-DedupStatus | fl
Get-PSDrive -Name J
#
#
#
Stop-Transcript