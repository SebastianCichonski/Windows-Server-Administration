# Failover cluster


## Serwery wykożystane w konfiguracji
**VL-DC1.virtuallab.com** - kontroler domeny, na nim będą wykonywane wszystkie komendy\
**VL-STOR1.virtuallab.com** - serwer udostępniający objekt docelowy iSCSI\
**VL-CL1.virtuallab.com** - pierwszy nod klastra\
**VL-VL2.virtuallab.com** - drugi nod klastra

## Krok 0. Przygotowanie obiektu docelowego iSCSI
Nawiązanie sesji zdalnej z VL-STOR1:
```powershell
PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-STOR1

[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents>
```
Instalacja obiektu docelowego iSCSI:
```powershell
[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -Name FS-iSCSITarget-Server -IncludeManagementTools

RunspaceId     : 8323bfec-7c84-4e9d-885b-8b7c974e0e7c
Success        : True
RestartNeeded  : No
FeatureResult  : {File and iSCSI Services, File Server, iSCSI Target Server}
ExitCode       : Success
```
Sprawdzamy dostępne dyski:
```powershell
[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-Disk | ft

Number Friendly Name                                                          Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                      Style     
------ -------------                                                          -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                              Healthy              Online                      40 GB MBR       
1      Msft Virtual Disk                                                                                       Healthy              Offline                    127 GB RAW       
```
Do przechowywania dysku iSCSI posłuży jeszcze nie zainicjalizowany dysk o numerze 1. Inicjujemy i tworzymy volumin na dysku numer 1:
```powershell
[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Initialize-Disk -Number 1
Get-Disk | ft

Number Friendly Name                                                          Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                      Style     
------ -------------                                                          -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                              Healthy              Online                      40 GB MBR       
1      Msft Virtual Disk                                                                                       Healthy              Online                     127 GB GPT       

[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter L

DiskPath: \\?\scsi#disk&ven_msft&prod_virtual_disk#6&2cdaf2aa&0&000000#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}

PartitionNumber  DriveLetter Offset                                              Size Type                                          PSComputerName                              
---------------  ----------- ------                                              ---- ----                                          --------------                              
2                L           16777216                                       126.98 GB Basic                                         VL-STOR1                                    

[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Format-Volume -DriveLetter L -FileSystem ReFS

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining      Size PSComputerName
----------- ------------ -------------- --------- ------------ ----------------- -------------      ---- --------------
L                        ReFS           Fixed     Healthy      OK                    125.05 GB 126.94 GB VL-STOR1      
```
Przepuszczamy ruch dotyczący iSCSI przez zapore systemu Windows:
```powershell
[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-NetFirewallRule -DisplayName 'iSCSITargetIn' -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3260

Name                          : {9d0cb2ee-677e-482a-a9ba-9ef0f7e85d8f}
DisplayName                   : iSCSITargetIn
Description                   : 
DisplayGroup                  : 
Group                         : 
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Inbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         : 
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}


[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-NetFirewallRule -DisplayName 'iSCSITargetOut' -Profile Any -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3260

Name                          : {a22e084b-d32c-4240-aca4-4d9be661e463}
DisplayName                   : iSCSITargetOut
Description                   : 
DisplayGroup                  : 
Group                         : 
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Outbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         : 
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}
```
Tworzymy dysk iSCSI:
```powershell
[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-IscsiVirtualDisk -Path "L:\iSCSIVirtualDisk\iSCSIDisk1.vhdx" -Size 10GB

ClusterGroupName   : 
ComputerName       : VL-STOR1.virtuallab.com
Description        : 
DiskType           : Dynamic
HostVolumeId       : {72ADAF97-598A-4C62-A0D6-B7FC889F2E6A}
LocalMountDeviceId : 
OriginalPath       : 
ParentPath         : 
Path               : L:\iSCSIVirtualDisk\iSCSIDisk1.vhdx
SerialNumber       : 1A35B21D-B310-43BA-8B2D-3C27A36B1B5A
Size               : 10737418240
SnapshotIds        : 
Status             : NotConnected
VirtualDiskIndex   : 708223650
```
Tworzymy obiekt docelowy iSCSI:
```powershell
[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-IscsiServerTarget -TargetName Target1 -InitiatorIds @("IQN:*")

ChapUserName                : 
ClusterGroupName            : 
ComputerName                : VL-STOR1.virtuallab.com
Description                 : 
EnableChap                  : False
EnableReverseChap           : False
EnforceIdleTimeoutDetection : True
FirstBurstLength            : 65536
IdleDuration                : 00:00:00
InitiatorIds                : {IQN:*}
LastLogin                   : 
LunMappings                 : {}
MaxBurstLength              : 262144
MaxReceiveDataSegmentLength : 65536
ReceiveBufferCount          : 10
ReverseChapUserName         : 
Sessions                    : {}
Status                      : NotConnected
TargetIqn                   : iqn.1991-05.com.microsoft:vl-stor1-Target1-target
TargetName                  : Target1
```
Przypisujemy dysk wirtualny do obiektu docelowego iSCSI:
```powershell
[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Add-IscsiVirtualDiskTargetMapping -TargetName Target1 -Path "L:\iSCSIVirtualDisk\iSCSIDisk1.vhdx" 

[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents>Exit-PSSession
```
## Krok 1. Podłączenie dysku iSCSI do serwerów VL-CL1 i VL-CL2

Tworzenie sesji zdalnej z VL-CL1
```powershell
Enter-PSSession -ComputerName VL-CL1
```
Do obiektu docelowego skonfigurowanego na serwerze VL-STOR1 podłączyć możemy się za pomocą inicjatora iscsi, jest on domyślnie instalowany w Windows Server ale nie jest skonfigurowana do automatycznego uruchamiania.
Ustawienie automatycznego startu i uruchonienie usługi: msiscsi
```powershell
[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Set-Service -Name msiscsi -StartupType 'Automatic'

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service -Name msiscsi
```
Konfigurujemy portal iscsi aby móc korzystać z okiektu doselowego na serwerze VL-CL1.
```powershell
[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-IscsiTargetPortal -TargetPortalAddress vl-stor1.virtuallab.com -TargetPortalPortNumber 3260

InitiatorInstanceName  :
InitiatorPortalAddress :
IsDataDigest           : False
IsHeaderDigest         : False
TargetPortalAddress    : vl-stor1.virtuallab.com
TargetPortalPortNumber : 3260
PSComputerName         :
```
Wyświetlamy obiekt docelowy iscsi dostępny za pomocą skonfigurowanego portalu:
```powershell
[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-IscsiTarget

IsConnected NodeAddress                                       PSComputerName
----------- -----------                                       --------------
      False iqn.1991-05.com.microsoft:vl-stor1-target1-target       
```
Następnie łączymy się z obiektem docelowym:
```powershell
Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-target1-target"


AuthenticationType      : NONE
InitiatorInstanceName   : ROOT\ISCSIPRT\0000_0
InitiatorNodeAddress    : iqn.1991-05.com.microsoft:vl-cl1.virtuallab.com
InitiatorPortalAddress  : 0.0.0.0
InitiatorSideIdentifier : 400001370000
IsConnected             : True
IsDataDigest            : False
IsDiscovered            : False
IsHeaderDigest          : False
IsPersistent            : False
NumberOfConnections     : 1
SessionIdentifier       : ffff990fafe34010-400001370000000e
TargetNodeAddress       : iqn.1991-05.com.microsoft:vl-stor1-target1-target
TargetSideIdentifier    : 0100
PSComputerName          : 
```
Listujemy dostępne dyski:
```powershell
[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-Disk

Number Friendly Name                                                               Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                           Style     
------ -------------                                                               -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                                   Healthy              Online                      40 GB MBR       
1      MSFT Virtual HD                                                             1A35B21D-B310-43BA-8B2D-3C27A... Healthy              Offline                     10 GB RAW       
```
Dysk numer 1 jest dyskiem podpiętym za pomocą iscsi. Tworzymy na nim wolumin:
```powershell
[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-Volume -DiskNumber 1 -FriendlyName "CSV1" -FileSystem ReFS -DriveLetter 'S'

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining    Size
----------- ------------ -------------- --------- ------------ ----------------- -------------    ----
S           CSV1         ReFS           Fixed     Healthy      OK                      8.93 GB 9.94 GB

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession
```

Te same operacje musimy przeprowadzić na serwerze VL-CL2:

```powershell
PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL2

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Set-Service -Name msiscsi -StartupType 'Automatic'

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service msiscsi

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-IscsiTargetPortal -TargetPortalAddress vl-stor1.virtuallab.com -TargetPortalPortNumber 3260


InitiatorInstanceName  : 
InitiatorPortalAddress : 
IsDataDigest           : False
IsHeaderDigest         : False
TargetPortalAddress    : vl-stor1.virtuallab.com
TargetPortalPortNumber : 3260
PSComputerName         : 


[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-IscsiTarget

IsConnected NodeAddress                                       PSComputerName
----------- -----------                                       --------------
      False iqn.1991-05.com.microsoft:vl-stor1-target1-target               



[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-target1-target"


AuthenticationType      : NONE
InitiatorInstanceName   : ROOT\ISCSIPRT\0000_0
InitiatorNodeAddress    : iqn.1991-05.com.microsoft:vl-cl2.virtuallab.com
InitiatorPortalAddress  : 0.0.0.0
InitiatorSideIdentifier : 400001370000
IsConnected             : True
IsDataDigest            : False
IsDiscovered            : False
IsHeaderDigest          : False
IsPersistent            : False
NumberOfConnections     : 1
SessionIdentifier       : ffff9d8f471bc010-400001370000000b
TargetNodeAddress       : iqn.1991-05.com.microsoft:vl-stor1-target1-target
TargetSideIdentifier    : 0200
PSComputerName          : 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-Disk

Number Friendly Name                                                               Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                           Style     
------ -------------                                                               -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                                   Healthy              Online                      40 GB MBR       
1      MSFT Virtual HD                                                             1A35B21D-B310-43BA-8B2D-3C27A... Healthy              Offline                     10 GB RAW       


[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-Volume -DiskNumber 1 -FriendlyName "CSV2" -FileSystem ReFS -DriveLetter 'S'

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining    Size
----------- ------------ -------------- --------- ------------ ----------------- -------------    ----
S           CSV2         ReFS           Fixed     Healthy      OK                      8.93 GB 9.94 GB


[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession
```
## Krok 3. Tworzenie klastra

Instalowanie roli Failover Clustering na obu serwerach:
```powershell
Install-WindowsFeature -ComputerName VL-CL1 -Name Failover-Clustering -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
True    No             Success        {Failover Clustering, Remote Server Admini...

Install-WindowsFeature -ComputerName VL-CL2 -Name Failover-Clustering -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
True    No             Success        {Failover Clustering, Remote Server Admini...
```
Żeby wykonać testy klastra i utworzyć klaster z poziomu VL-DC1 musimy zainstalować na nim moduł: RSAT-Clustering-PowerShell

```powershell
PS C:\Users\administrator.VIRTUALLAB> Install-WindowsFeature -Name RSAT-Clustering-PowerShell

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
True    No             Success        {Failover Clustering Tools, Failover Clust...
```

Przed utworzeniem klastra wykonujemy test, którego wyniki zapisujemy na dysku C:

```powershell
PS C:\Users\administrator.VIRTUALLAB> Test-Cluster -Node VL-CL1, VL-CL2 -ReportName "c:\cluster-test.htm"
WARNING: System Configuration - Validate All Drivers Signed: The test reported some warnings..
WARNING: System Configuration - Validate Software Update Levels: The test reported some warnings..
WARNING: Network - Validate IP Configuration: The test reported some warnings..
WARNING: Network - Validate Network Communication: The test reported some warnings..
WARNING: 
Test Result:
HadUnselectedTests, ClusterConditionallyApproved
Testing has completed for the tests you selected. You should review the warnings in the Report.  A cluster solution is supported by Microsoft only if you run all cluster validation tests, and all tests succeed (with or without warnings).
Test report file path: c:\cluster-test.htm

Mode                LastWriteTime         Length Name                                                                                                                                                                                                            
----                -------------         ------ ----                                                                                                                                                                                                            
-a----        4/23/2025  12:13 PM         714233 cluster-test.htm       
```

Tworzymy klaster z jednym nodem i nadajemy mu adres IP:
```powershell
PS C:\Users\administrator.VIRTUALLAB> New-Cluster -Name Cluster1 -Node VL-CL1 -StaticAddress 10.6.226.200

Name    
----    
Cluster1
```
Następnie dodajemy drugi nod do klastra:
```powershell
PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 |  Add-ClusterNode -Name VL-CL2
```
Zmiana ustawień dot. przełączania się w tryb failover:
```powershell
PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | fl *subnet*

CrossSubnetDelay          : 1000
CrossSubnetThreshold      : 20
PlumbAllCrossSubnetRoutes : 0
SameSubnetDelay           : 1000
SameSubnetThreshold       : 20

PS C:\Users\administrator.VIRTUALLAB> (Get-Cluster -Name Cluster1).SameSubnetThreshold = 30

PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | fl *subnet*

CrossSubnetDelay          : 1000
CrossSubnetThreshold      : 20
PlumbAllCrossSubnetRoutes : 0
SameSubnetDelay           : 1000
SameSubnetThreshold       : 30
```

Konfigurowanie kworum klastra:\
Do skonfigurowania kworum w klastrze można użyć:
* udziału plików
* dysku
* obiektów blob w usłudze Azure
użyjemy udzuału plików udostępnionego na serwerze VL-STOR1:
```powershell
PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {New-Item -Path c:\Quorum -ItemType Directory}


    Directory: C:\


Mode                LastWriteTime         Length Name                                                               PSComputerName                                                   
----                -------------         ------ ----                                                               --------------                                                   
d-----        4/28/2025  11:05 AM                Quorum                                                             VL-STOR1                                                         



PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock { New-SmbShare -Name Quorum -Path c:\Quorum -FullAccess Everyone}

Name   ScopeName Path      Description PSComputerName
----   --------- ----      ----------- --------------
Quorum *         c:\Quorum             VL-STOR1      
```
Następnie ustawiamy udział jako kworum klastra:
```powershell
PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Set-ClusterQuorum -FileShareWitness \\VL-STOR1\Quorum

Cluster              QuorumResource                                                                                                                                                  
-------              --------------                                                                                                                                                  
Cluster1             File Share Witness         
```
Sprawdzamy zasoby klastra, aby sprawdzić czy dostępny jest dysk, który posłuży jako dysk CSV:
```powershell
PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Get-ClusterResource

Name                 State  OwnerGroup        ResourceType              
----                 -----  ----------        ------------              
Cluster Disk 1       Online Available Storage Physical Disk             
Cluster IP Address   Online Cluster Group     IP Address                
Cluster Name         Online Cluster Group     Network Name              
File Share Witness   Online Cluster Group     File Share Witness        
Storage Qos Resource Online Cluster Group     Storage QoS Policy Manager
```
Dodanie dysku do woluminu CSV:
```powershell
PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Add-ClusterSharedVolume -Name 'Cluster Disk 1'

Name           State  Node  
----           -----  ----  
Cluster Disk 1 Online VL-CL2
```