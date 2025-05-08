# Krok 0. Przygotowanie obiektu docelowego iSCSI (Serwer: VL-STOR1)

Enter-PSSession -ComputerName VL-STOR1

# Instalacja iSCSI Server Target na VL-STOR1
Install-WindowsFeature -Name FS-iSCSITarget-Server -IncludeManagementTools

Get-Disk | ft

# Inicializacja dysku i tworzenie nowego woluminu
Initialize-Disk -Number 1

New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter L

Format-Volume -DriveLetter L -FileSystem ReFS

# Przepuszczenie ruchu dot. iscsi przez zaporę windows
New-NetFirewallRule -DisplayName 'iSCSITargetIn' -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3260

New-NetFirewallRule -DisplayName 'iSCSITargetOut' -Profile Any -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3260

# Tworzenie nowego dysku iSCSI
New-IscsiVirtualDisk -Path "L:\iSCSIVirtualDisk\iSCSIDisk1.vhdx" -Size 10GB

New-IscsiServerTarget -TargetName Target1 -InitiatorIds @("IQN:*")

Add-IscsiVirtualDiskTargetMapping -TargetName Target1 -Path "L:\iSCSIVirtualDisk\iSCSIDisk1.vhdx" 

Exit-PSSession


# Krok 1. Podłączenie dysku iSCSI do serwerów: VL-CL1 i VL-CL2
Enter-PSSession -ComputerName VL-CL1

# Ustawienie automatycznego startu i uruchomienie usługi: msiscsi
Set-service -Name msiscsi -StartupType 'Automatic'

Start-Service -Name msiscsi

# Konfiguracja portalu iSCSI 
New-IscsiTargetPortal -TargetPortalAddress vl-stor1.virtuallab.com -TargetPortalPortNumber 3260

Get-IscsiTarget

Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-target1-target"

Get-Disk

New-Volume -DiskNumber 1 -FriendlyName "CSV1" -FileSystem ReFS -DriveLetter 'S'

Exit-PSSession

# Ta sama konfiguracja na drugim z serwerów
Enter-PSSession -ComputerName VL-CL2

Set-service -Name msiscsi -StartupType 'Automatic'

Start-Service -Name msiscsi

New-IscsiTargetPortal -TargetPortalAddress vl-stor1.virtuallab.com -TargetPortalPortNumber 3260

Get-IscsiTarget

Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-target1-target"

Get-Disk

New-Volume -DiskNumber 1 -FriendlyName "CSV2" -FileSystem ReFS -DriveLetter 'S'

Exit-PSSession

# Krok 2. Tworzenie klastra 

Install-WindowsFeature -ComputerName VL-CL1 -Name Failover-Clustering -IncludeManagementTools
Install-WindowsFeature -ComputerName VL-CL2 -Name Failover-Clustering -IncludeManagementTools

Add-WindowsFeature -Name RSAT-Clustering-PowerShell

Test-Cluster -Node VL-CL1, VL-CL2 -ReportName "c:\"

New-Cluster -Name Cluster1 -Node VL-CL1 -StaticAddress 10.6.226.200

#Get-Cluster -Name Cluster1 | fl *subnet*

#(Get-Cluster -Name Cluster1).SameSubnetThreshold = 30

Get-Cluster -Name Cluster1 |  Add-ClusterNode -Name VL-CL2

# Konfiguracja kworum

# tworzenie udziau na VL-STOR1
Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {New-Item -Path c:\Quorum -ItemType Directory}
Invoke-Command -ComputerName VL-STOR1 -ScriptBlock { New-SmbShare -Name Quorum -Path c:\Quorum -FullAccess Everyone}

Get-Cluster -Name Cluster1 | Set-ClusterQuorum -FileShareWitness \\VL-STOR1\Quorum

Get-Cluster -Name Cluster1 | Get-ClusterResource | Where-Object ResourceType -eq 'Physical Disk'

Get-Cluster -Name Cluster1 | Add-ClusterSharedVolume -Name 'Cluster Disk 1'