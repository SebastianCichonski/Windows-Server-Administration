PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {Install-WindowsFeature -Name FS-iSCSITarget-Server -IncludeManagementTools}


PSComputerName : VL-STOR1
RunspaceId     : 8323bfec-7c84-4e9d-885b-8b7c974e0e7c
Success        : True
RestartNeeded  : No
FeatureResult  : {File and iSCSI Services, File Server, iSCSI Target Server}
ExitCode       : Success




PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {Get-Disk}


DiskNumber           : 0
PSComputerName       : VL-STOR1
RunspaceId           : cb89ff23-4430-4678-ba39-eff9bd636def
ObjectId             : {1}\\VL-STOR1\root/Microsoft/Windows/Storage/Providers_v2\WSP_Disk.ObjectId="{baa8a04d-1faa-11f0-b07c-806e6f6e6963}:DI:\\?\ide#diskvirtual_hd____________
                       __________________1.1.0___#5&35dc7040&0&0.0.0#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}"
PassThroughClass     : 
PassThroughIds       : 
PassThroughNamespace : 
PassThroughServer    : 
UniqueId             : IDE\DISKVIRTUAL_HD______________________________1.1.0___\5&35DC7040&0&0.0.0:VL-STOR1
AdapterSerialNumber  : 
AllocatedSize        : 42949672960
BootFromDisk         : True
BusType              : 3
FirmwareVersion      : 1.1.0
FriendlyName         : Virtual HD
Guid                 : 
HealthStatus         : 0
IsBoot               : True
IsClustered          : False
IsHighlyAvailable    : False
IsOffline            : False
IsReadOnly           : False
IsScaleOut           : False
IsSystem             : True
LargestFreeExtent    : 0
Location             : PCI Slot 0 : Adapter 0 : Channel 0 : Device 0
LogicalSectorSize    : 512
Manufacturer         : 
Model                : Virtual HD
Number               : 0
NumberOfPartitions   : 1
OfflineReason        : 0
OperationalStatus    : {53264}
PartitionStyle       : 1
Path                 : \\?\ide#diskvirtual_hd______________________________1.1.0___#5&35dc7040&0&0.0.0#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}
PhysicalSectorSize   : 512
ProvisioningType     : 2
SerialNumber         : 
Signature            : 528716208
Size                 : 42949672960
UniqueIdFormat       : 0

DiskNumber           : 1
PSComputerName       : VL-STOR1
RunspaceId           : cb89ff23-4430-4678-ba39-eff9bd636def
ObjectId             : {1}\\VL-STOR1\root/Microsoft/Windows/Storage/Providers_v2\WSP_Disk.ObjectId="{baa8a04d-1faa-11f0-b07c-806e6f6e6963}:DI:\\?\scsi#disk&ven_msft&prod_virtua
                       l_disk#6&2cdaf2aa&0&000000#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}"
PassThroughClass     : 
PassThroughIds       : 
PassThroughNamespace : 
PassThroughServer    : 
UniqueId             : 60022480495F67CBC95FD232E88561A7
AdapterSerialNumber  : 
AllocatedSize        : 0
BootFromDisk         : False
BusType              : 10
FirmwareVersion      : 1.0 
FriendlyName         : Msft Virtual Disk
Guid                 : 
HealthStatus         : 0
IsBoot               : False
IsClustered          : False
IsHighlyAvailable    : False
IsOffline            : True
IsReadOnly           : True
IsScaleOut           : False
IsSystem             : False
LargestFreeExtent    : 0
Location             : Integrated : Bus 0 : Device 8331 : Function 65486 : Adapter 2 : Port 0 : Target 0 : LUN 0
LogicalSectorSize    : 512
Manufacturer         : Msft    
Model                : Virtual Disk    
Number               : 1
NumberOfPartitions   : 0
OfflineReason        : 1
OperationalStatus    : {53267}
PartitionStyle       : 0
Path                 : \\?\scsi#disk&ven_msft&prod_virtual_disk#6&2cdaf2aa&0&000000#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}
PhysicalSectorSize   : 512
ProvisioningType     : 1
SerialNumber         : 
Signature            : 
Size                 : 136365211648
UniqueIdFormat       : 3




PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {Get-Disk | ft}

Number Friendly Name                                                          Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                      Style     
------ -------------                                                          -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                              Healthy              Online                      40 GB MBR       
1      Msft Virtual Disk                                                                                       Healthy              Offline                    127 GB RAW       



PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {Initialize-Disk -Number 1}

PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {Get-Disk | ft}

Number Friendly Name                                                          Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                      Style     
------ -------------                                                          -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                              Healthy              Online                      40 GB MBR       
1      Msft Virtual Disk                                                                                       Healthy              Online                     127 GB GPT       



PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter L}


   DiskPath: \\?\scsi#disk&ven_msft&prod_virtual_disk#6&2cdaf2aa&0&000000#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}

PartitionNumber  DriveLetter Offset                                              Size Type                                          PSComputerName                              
---------------  ----------- ------                                              ---- ----                                          --------------                              
2                L           16777216                                       126.98 GB Basic                                         VL-STOR1                                    



PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {Format-Volume -DriveLetter L -FileSystem ReFS}

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining      Size PSComputerName
----------- ------------ -------------- --------- ------------ ----------------- -------------      ---- --------------
L                        ReFS           Fixed     Healthy      OK                    125.05 GB 126.94 GB VL-STOR1      



PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-STOR1

[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-NetFirewallRule -DisplayName 'iSCSITargetIn' -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3260

New-NetFirewallRule -DisplayName 'iSCSITargetOut' -Profile Any -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3260


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




[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-IscsiServerTarget -TargetName VL-STOR1-iT1 -InitiatorIds @("DNSName:VL-CL1","DNSName:VL-CL2")
WARNING: One or more InitiatorId parameters may be invalid. Ensure you enter the primary FQDN for an InitiatorId specified by a DNS name.


ChapUserName                : 
ClusterGroupName            : 
ComputerName                : VL-STOR1.virtuallab.com
Description                 : 
EnableChap                  : False
EnableReverseChap           : False
EnforceIdleTimeoutDetection : True
FirstBurstLength            : 65536
IdleDuration                : 00:00:00
InitiatorIds                : {DnsName:VL-CL1, DnsName:VL-CL2}
LastLogin                   : 
LunMappings                 : {}
MaxBurstLength              : 262144
MaxReceiveDataSegmentLength : 65536
ReceiveBufferCount          : 10
ReverseChapUserName         : 
Sessions                    : {}
Status                      : NotConnected
TargetIqn                   : iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target
TargetName                  : VL-STOR1-iT1




[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Add-IscsiVirtualDiskTargetMapping -TargetName VL-STOR1-iT1 -Path "L:\iSCSIVirtualDisk\iSCSIDisk1.vhdx"

[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> start-service msiscsi
WARNING: Waiting for service 'Microsoft iSCSI Initiator Service (msiscsi)' to start...
[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-IscsiTargetPortal -TargetPortalAddress vl-stor1.virtuallab.com -TargetPortalPortNumber 3260


InitiatorInstanceName  :
InitiatorPortalAddress :
IsDataDigest           : False
IsHeaderDigest         : False
TargetPortalAddress    : vl-stor1.virtuallab.com
TargetPortalPortNumber : 3260
PSComputerName         :


[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL1

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service msisci
Start-Service : Cannot find any service with service name 'msisci'.
    + CategoryInfo          : ObjectNotFound: (msisci:String) [Start-Service], ServiceCommandException
    + FullyQualifiedErrorId : NoServiceFoundForGivenName,Microsoft.PowerShell.Commands.StartServiceCommand
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service msiscsi

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> ipconfig

Windows IP Configuration


Ethernet adapter Ethernet:

   Connection-specific DNS Suffix  . : 
   Link-local IPv6 Address . . . . . : fe80::149b:1ddc:7508:ae91%6
   IPv4 Address. . . . . . . . . . . : 10.6.226.11
   Subnet Mask . . . . . . . . . . . : 255.255.254.0
   Default Gateway . . . . . . . . . : 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName vl-cl2

[vl-cl2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The Microsoft iSCSI Initiator Service is not running. Please start the service and retry. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff003e,Connect-IscsiTarget
 

[vl-cl2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service msiscsi

[vl-cl2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[vl-cl2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL1

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service msiscsi

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target" -InitiatorPortalAddress '10.6.226.11'
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target" -InitiatorPortalAddress '10.6.226.13'
Connect-IscsiTarget : An internal error occurred. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0x54f,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "qn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"


AuthenticationType      : NONE
InitiatorInstanceName   : ROOT\ISCSIPRT\0000_0
InitiatorNodeAddress    : iqn.1991-05.com.microsoft:vl-cl1.virtuallab.com
InitiatorPortalAddress  : 0.0.0.0
InitiatorSideIdentifier : 400001370000
IsConnected             : True
IsDataDigest            : False
IsDiscovered            : False
IsHeaderDigest          : False
IsPersistent            : True
NumberOfConnections     : 1
SessionIdentifier       : ffff990fafe34010-4000013700000006
TargetNodeAddress       : iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target
TargetSideIdentifier    : 0100
PSComputerName          : 




[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL2

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service msiscsi

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "IQN:iqn.1991-05.com.microsoft:vl-stor1-vl-stor1-it1-target"
Connect-IscsiTarget : The target name is not found or is marked as hidden from login. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Connect-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff0029,Connect-IscsiTarget
 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> 






PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-STOR1

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
InitiatorIds                : {Iqn:*}
LastLogin                   : 
LunMappings                 : {}
MaxBurstLength              : 262144
MaxReceiveDataSegmentLength : 65536
ReceiveBufferCount          : 10
ReverseChapUserName         : 
Sessions                    : {}
Status                      : NotConnected
TargetIqn                   : iqn.1991-05.com.microsoft:vl-stor1-target1-target
TargetName                  : Target1




[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Add-IscsiVirtualDiskTargetMapping -TargetName Target1 -Path "L:\iSCSIVirtualDisk\iSCSIDisk1.vhdx"

[VL-STOR1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL1

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service msiscsi

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-IscsiTargetPortal -TargetPortalAddress vl-stor1.virtuallab.com -TargetPortalPortNumber 3260


InitiatorInstanceName  : 
InitiatorPortalAddress : 
IsDataDigest           : False
IsHeaderDigest         : False
TargetPortalAddress    : vl-stor1.virtuallab.com
TargetPortalPortNumber : 3260
PSComputerName         : 




[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-IscsiTarget

IsConnected NodeAddress                                       PSComputerName
----------- -----------                                       --------------
      False iqn.1991-05.com.microsoft:vl-stor1-target1-target               



[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Connect-IscsiTarget -NodeAddress "iqn.1991-05.com.microsoft:vl-stor1-target1-target"


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




[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL2

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




[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Enter-PSSession -ComputerName VL-CL1
Enter-PSSession : You are currently in a Windows PowerShell PSSession and cannot use the Enter-PSSession cmdlet to enter another PSSession.
    + CategoryInfo          : InvalidArgument: (:) [Enter-PSSession], ArgumentException
    + FullyQualifiedErrorId : RemoteHostDoesNotSupportPushRunspace,Microsoft.PowerShell.Commands.EnterPSSessionCommand
 

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

PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL1

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-Disk

Number Friendly Name                                                               Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                           Style     
------ -------------                                                               -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                                   Healthy              Online                      40 GB MBR       
1      MSFT Virtual HD                                                             1A35B21D-B310-43BA-8B2D-3C27A... Healthy              Offline                     10 GB RAW       



[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-Volume -DiskNumber 1 -FriendlyName "CSV1" -FileSystem ReFS -DriveLetter 'S'

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining    Size
----------- ------------ -------------- --------- ------------ ----------------- -------------    ----
S           CSV1         ReFS           Fixed     Healthy      OK                      8.93 GB 9.94 GB



[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-Disk

Number Friendly Name                                                               Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                           Style     
------ -------------                                                               -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                                   Healthy              Online                      40 GB MBR       
1      MSFT Virtual HD                                                             1A35B21D-B310-43BA-8B2D-3C27A... Healthy              Online                      10 GB GPT       



[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -ComputerName "VL-CL1", "VL-CL2" -Name Filover-Clustering -IncludeManagementTools $true
Cannot convert 'VL-CL1 VL-CL2' to the type 'System.String' required by parameter 'ComputerName'. Specified method is not supported.
    + CategoryInfo          : InvalidArgument: (:) [Install-WindowsFeature], ParameterBindingException
    + FullyQualifiedErrorId : CannotConvertArgument,Microsoft.Windows.ServerManager.Commands.AddWindowsFeatureCommand
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -ComputerName VL-CL1 -Name Filover-Clustering -IncludeManagementTools $true
Install-WindowsFeature -ComputerName VL-CL2 -Name Filover-Clustering -IncludeManagementTools $true

A positional parameter cannot be found that accepts argument 'True'.
    + CategoryInfo          : InvalidArgument: (:) [Install-WindowsFeature], ParameterBindingException
    + FullyQualifiedErrorId : PositionalParameterNotFound,Microsoft.Windows.ServerManager.Commands.AddWindowsFeatureCommand
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -ComputerName VL-CL1 -Name Failover-Clustering -IncludeManagementTools $true
A positional parameter cannot be found that accepts argument 'True'.
    + CategoryInfo          : InvalidArgument: (:) [Install-WindowsFeature], ParameterBindingException
    + FullyQualifiedErrorId : PositionalParameterNotFound,Microsoft.Windows.ServerManager.Commands.AddWindowsFeatureCommand
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -ComputerName VL-CL1 -Name Failover-Clustering -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
True    No             Success        {Failover Clustering, Remote Server Admini...



[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -ComputerName VL-CL2 -Name Failover-Clustering -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
False   Maybe          Failed         {}                                           
Install-WindowsFeature : WinRM cannot process the request. The following error with errorcode 0x8009030e occurred while using Kerberos authentication: A specified logon session 
does not exist. It may already have been terminated.  
 Possible causes are:
  -The user name or password specified are invalid.
  -Kerberos is used when no authentication method and no user name are specified.
  -Kerberos accepts domain user names, but not local user names.
  -The Service Principal Name (SPN) for the remote computer name and port does not exist.
  -The client and remote computers are in different domains and there is no trust between the two domains.
 After checking for the above issues, try the following:
  -Check the Event Viewer for events related to authentication.
  -Change the authentication method; add the destination computer to the WinRM TrustedHosts configuration setting or use HTTPS transport.
 Note that computers in the TrustedHosts list might not be authenticated.
   -For more information about WinRM configuration, run the following command: winrm help config.
    + CategoryInfo          : DeviceError: (Microsoft.Manag...rDetailsHandle):CimException) [Install-WindowsFeature], Exception
    + FullyQualifiedErrorId : UnSupportedTargetDevice,Microsoft.Windows.ServerManager.Commands.AddWindowsFeatureCommand
 



[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -ComputerName VL-CL2 -Name Failover-Clustering -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
False   Maybe          Failed         {}                                           
Install-WindowsFeature : WinRM cannot process the request. The following error with errorcode 0x8009030e occurred while using Kerberos authentication: A specified logon session 
does not exist. It may already have been terminated.  
 Possible causes are:
  -The user name or password specified are invalid.
  -Kerberos is used when no authentication method and no user name are specified.
  -Kerberos accepts domain user names, but not local user names.
  -The Service Principal Name (SPN) for the remote computer name and port does not exist.
  -The client and remote computers are in different domains and there is no trust between the two domains.
 After checking for the above issues, try the following:
  -Check the Event Viewer for events related to authentication.
  -Change the authentication method; add the destination computer to the WinRM TrustedHosts configuration setting or use HTTPS transport.
 Note that computers in the TrustedHosts list might not be authenticated.
   -For more information about WinRM configuration, run the following command: winrm help config.
    + CategoryInfo          : DeviceError: (Microsoft.Manag...rDetailsHandle):CimException) [Install-WindowsFeature], Exception
    + FullyQualifiedErrorId : UnSupportedTargetDevice,Microsoft.Windows.ServerManager.Commands.AddWindowsFeatureCommand
 



[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -ComputerName VL-CL2 -Name Failover-Clustering -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
False   Maybe          Failed         {}                                           
Install-WindowsFeature : WinRM cannot process the request. The following error with errorcode 0x8009030e occurred while using Kerberos authentication: A specified logon session 
does not exist. It may already have been terminated.  
 Possible causes are:
  -The user name or password specified are invalid.
  -Kerberos is used when no authentication method and no user name are specified.
  -Kerberos accepts domain user names, but not local user names.
  -The Service Principal Name (SPN) for the remote computer name and port does not exist.
  -The client and remote computers are in different domains and there is no trust between the two domains.
 After checking for the above issues, try the following:
  -Check the Event Viewer for events related to authentication.
  -Change the authentication method; add the destination computer to the WinRM TrustedHosts configuration setting or use HTTPS transport.
 Note that computers in the TrustedHosts list might not be authenticated.
   -For more information about WinRM configuration, run the following command: winrm help config.
    + CategoryInfo          : DeviceError: (Microsoft.Manag...rDetailsHandle):CimException) [Install-WindowsFeature], Exception
    + FullyQualifiedErrorId : UnSupportedTargetDevice,Microsoft.Windows.ServerManager.Commands.AddWindowsFeatureCommand
 



[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Enter-PSSession -ComputerName VL-CL2
Enter-PSSession : You are currently in a Windows PowerShell PSSession and cannot use the Enter-PSSession cmdlet to enter another PSSession.
    + CategoryInfo          : InvalidArgument: (:) [Enter-PSSession], ArgumentException
    + FullyQualifiedErrorId : RemoteHostDoesNotSupportPushRunspace,Microsoft.PowerShell.Commands.EnterPSSessionCommand
 

[VL-CL1]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Install-WindowsFeature -ComputerName VL-CL2 -Name Failover-Clustering -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
True    No             Success        {Failover Clustering, Remote Server Admini...



PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL2

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-IscsiTarget
Get-IscsiTarget : The Microsoft iSCSI Initiator Service is not running. Please start the service and retry. 
    + CategoryInfo          : NotSpecified: (MSFT_iSCSITarget:ROOT/Microsoft/...SFT_iSCSITarget) [Get-IscsiTarget], CimException
    + FullyQualifiedErrorId : HRESULT 0xefff003e,Get-IscsiTarget
 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-Service msiscsi

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
SessionIdentifier       : ffffa70a1503f010-4000013700000002
TargetNodeAddress       : iqn.1991-05.com.microsoft:vl-stor1-target1-target
TargetSideIdentifier    : 0200
PSComputerName          : 




[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-Disk

Number Friendly Name                                                                                                                                           Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                                                                                                       Style     
------ -------------                                                                                                                                           -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                                                                                                               Healthy              Online                      40 GB MBR       
1      MSFT Virtual HD                                                                                                                                         1A35B21D-B310-43BA-8B2D-3C27A... Healthy              Offline                     10 GB GPT       



[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-Volume -DiskNumber 1 -FriendlyName "CSV2" -FileSystem ReFS -DriveLetter 'S'
New-Volume : The disk has already been initialized.
 
Extended information:
The operation requires that the disk is either RAW or GPT with only MSR partition.
 
Recommended Actions:
- Clear the disk.
 
Activity ID: {e6db09d3-e096-4e89-81cd-fb19f1887ad7}
    + CategoryInfo          : NotSpecified: (:) [New-Volume], CimException
    + FullyQualifiedErrorId : StorageWMI 41001,Microsoft.Management.Infrastructure.CimCmdlets.InvokeCimMethodCommand,New-Volume
 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-Disk

Number Friendly Name                                                                                                                                           Serial Number                    HealthStatus         OperationalStatus      Total Size Partition 
                                                                                                                                                                                                                                                       Style     
------ -------------                                                                                                                                           -------------                    ------------         -----------------      ---------- ----------
0      Virtual HD                                                                                                                                                                               Healthy              Online                      40 GB MBR       
1      MSFT Virtual HD                                                                                                                                         1A35B21D-B310-43BA-8B2D-3C27A... Healthy              Offline                     10 GB GPT       



[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-Volume -DiskNumber 1 -FriendlyName "CSV2" -FileSystem ReFS -DriveLetter 'S'
New-Volume : The disk has already been initialized.
 
Extended information:
The operation requires that the disk is either RAW or GPT with only MSR partition.
 
Recommended Actions:
- Clear the disk.
 
Activity ID: {1e27d291-f486-4816-9000-17304d0aeff5}
    + CategoryInfo          : NotSpecified: (:) [New-Volume], CimException
    + FullyQualifiedErrorId : StorageWMI 41001,Microsoft.Management.Infrastructure.CimCmdlets.InvokeCimMethodCommand,New-Volume
 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Clear-Disk -Number 1
Clear-Disk : Cannot clear with data partitions present. To clear data partitions, use the RemoveData flag.
Activity ID: {9d06f682-52ae-4057-8ef7-7270b4f62ace}
    + CategoryInfo          : NotSpecified: (StorageWMI:ROOT/Microsoft/Windows/Storage/MSFT_Disk) [Clear-Disk], CimException
    + FullyQualifiedErrorId : StorageWMI 41008,Clear-Disk
 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Clear-Disk -Number 1 -RemoveData 

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> New-Volume -DiskNumber 1 -FriendlyName "CSV2" -FileSystem ReFS -DriveLetter 'S'

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining    Size
----------- ------------ -------------- --------- ------------ ----------------- -------------    ----
S           CSV2         ReFS           Fixed     Healthy      OK                      8.93 GB 9.94 GB



[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Import-Module -Name FailoverCluster
Import-Module : The specified module 'FailoverCluster' was not loaded because no valid module file was found in any module directory.
At line:1 char:1
+ Import-Module -Name FailoverCluster
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (FailoverCluster:String) [Import-Module], FileNotFoundException
    + FullyQualifiedErrorId : Modules_ModuleNotFound,Microsoft.PowerShell.Commands.ImportModuleCommand
 

PS C:\Users\administrator.VIRTUALLAB> Import-Module -Name FailoverClusters
Import-Module : The specified module 'FailoverClusters' was not loaded because no valid module file was found in any module directory.
At line:1 char:1
+ Import-Module -Name FailoverClusters
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (FailoverClusters:String) [Import-Module], FileNotFoundException
    + FullyQualifiedErrorId : Modules_ModuleNotFound,Microsoft.PowerShell.Commands.ImportModuleCommand
 

PS C:\Users\administrator.VIRTUALLAB> Import-Module -Name Failover-Clustering
Import-Module : The specified module 'Failover-Clustering' was not loaded because no valid module file was found in any module directory.
At line:1 char:1
+ Import-Module -Name Failover-Clustering
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (Failover-Clustering:String) [Import-Module], FileNotFoundException
    + FullyQualifiedErrorId : Modules_ModuleNotFound,Microsoft.PowerShell.Commands.ImportModuleCommand
 

PS C:\Users\administrator.VIRTUALLAB> Enter-PSSession -ComputerName VL-CL2

[VL-CL2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession

PS C:\Users\administrator.VIRTUALLAB> Add-WindowsFeature -Name RSAT-Clustering-PowerShell

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
True    No             Success        {Failover Clustering Tools, Failover Clust...



PS C:\Users\administrator.VIRTUALLAB> Test-Cluster -Node VL-CL1, VL-CL2 -ReportName "c:\"
Test-Cluster : Unable to connect to VL-CL2 via WMI.  This may be due to networking issues or firewall configuration on VL-CL2.
    The RPC server is unavailable. (Exception from HRESULT: 0x800706BA)
At line:1 char:1
+ Test-Cluster -Node VL-CL1, VL-CL2 -ReportName "c:\"
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Test-Cluster], ClusterCmdletException
    + FullyQualifiedErrorId : Test-Cluster,Microsoft.FailoverClusters.PowerShell.TestClusterCommand

PS C:\Users\administrator.VIRTUALLAB> Install-WindowsFeature -ComputerName VL-CL2 -Name Failover-Clustering -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
True    No             Success        {Failover Clustering, Remote Server Admini...



PS C:\Users\administrator.VIRTUALLAB> Test-Cluster -Node VL-CL1, VL-CL2 -ReportName "c:\"
WARNING: System Configuration - Validate All Drivers Signed: The test reported some warnings..
WARNING: System Configuration - Validate Software Update Levels: The test reported some warnings..
WARNING: Network - Validate IP Configuration: The test reported some warnings..
WARNING: Network - Validate Network Communication: The test reported some warnings..
WARNING: 
Test Result:
HadUnselectedTests, ClusterConditionallyApproved
Testing has completed for the tests you selected. You should review the warnings in the Report.  A cluster solution is supported by Microsoft only if you run all cluster validation tests, and all tests succeed (with or without warnings).
Test report file path: c:\.htm

Mode                LastWriteTime         Length Name                                                                                                                                                                                                            
----                -------------         ------ ----                                                                                                                                                                                                            
-a----        4/23/2025  12:13 PM         714233 .htm                                                                                                                                                                                                            



PS C:\Users\administrator.VIRTUALLAB> New-Cluster -Name Cluster1 -Node VL-CL1, VL-CL2 -StaticAddress 10.6.226.200
The clustered role was not successfully created. For more information view the report file below.
Report file location: C:\WINDOWS\cluster\Reports\Create Cluster Wizard Cluster1 on 2025.04.23 At 12.19.46.htm
New-Cluster : An error occurred while performing the operation.
    An error occurred while creating the cluster 'Cluster1'.
    An error occurred creating cluster 'Cluster1'.
    This operation returned because the timeout period expired
At line:1 char:1
+ New-Cluster -Name Cluster1 -Node VL-CL1, VL-CL2 -StaticAddress 10.6.2 ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [New-Cluster], ClusterCmdletException
    + FullyQualifiedErrorId : New-Cluster,Microsoft.FailoverClusters.PowerShell.NewClusterCommand

PS C:\Users\administrator.VIRTUALLAB> Clear-ClusterNode -Name VL-CL1 -Force

PS C:\Users\administrator.VIRTUALLAB> Clear-ClusterNode -Name VL-CL2 -Force

PS C:\Users\administrator.VIRTUALLAB> Test-Cluster -Node VL-CL1, VL-CL2 -ReportName "c:\"
WARNING: System Configuration - Validate All Drivers Signed: The test reported some warnings..
WARNING: System Configuration - Validate Software Update Levels: The test reported some warnings..
WARNING: Network - Validate IP Configuration: The test reported some warnings..
WARNING: Network - Validate Network Communication: The test reported some warnings..
WARNING: 
Test Result:
HadUnselectedTests, ClusterConditionallyApproved
Testing has completed for the tests you selected. You should review the warnings in the Report.  A cluster solution is supported by Microsoft only if you run all cluster validation tests, and all tests succeed (with or without warnings).
Test report file path: c:\.htm

Mode                LastWriteTime         Length Name                                                                                                                                                                                                            
----                -------------         ------ ----                                                                                                                                                                                                            
-a----        4/23/2025   1:12 PM         707599 .htm                                                                                                                                                                                                            



PS C:\Users\administrator.VIRTUALLAB> New-Cluster -Name Cluster1 -Node VL-CL1, VL-CL2 -StaticAddress 10.6.226.200
The clustered role was not successfully created. For more information view the report file below.
Report file location: C:\WINDOWS\cluster\Reports\Create Cluster Wizard Cluster1 on 2025.04.23 At 13.13.01.htm
New-Cluster : An error occurred while performing the operation.
    An error occurred while creating the cluster 'Cluster1'.
    An error occurred creating cluster 'Cluster1'.
    The handle is invalid
At line:1 char:1
+ New-Cluster -Name Cluster1 -Node VL-CL1, VL-CL2 -StaticAddress 10.6.2 ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [New-Cluster], ClusterCmdletException
    + FullyQualifiedErrorId : InvalidHandle,Microsoft.FailoverClusters.PowerShell.NewClusterCommand

PS C:\Users\administrator.VIRTUALLAB> New-Cluster -Name Cluster1 -Node VL-CL1, VL-CL2 -StaticAddress 10.6.226.200
The clustered role was not successfully created. For more information view the report file below.
Report file location: C:\WINDOWS\cluster\Reports\Create Cluster Wizard Cluster1 on 2025.04.23 At 13.24.00.htm
New-Cluster : An error occurred while performing the operation.
    An error occurred while creating the cluster 'Cluster1'.
    An error occurred creating cluster 'Cluster1'.
    The handle is invalid
At line:1 char:1
+ New-Cluster -Name Cluster1 -Node VL-CL1, VL-CL2 -StaticAddress 10.6.2 ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [New-Cluster], ClusterCmdletException
    + FullyQualifiedErrorId : InvalidHandle,Microsoft.FailoverClusters.PowerShell.NewClusterCommand

PS C:\Users\administrator.VIRTUALLAB> New-Cluster -Name Cluster1 -Node VL-CL1, VL-CL2 -StaticAddress 10.6.226.200
The clustered role was not successfully created. For more information view the report file below.
Report file location: C:\WINDOWS\cluster\Reports\Create Cluster Wizard Cluster1 on 2025.04.23 At 13.33.56.htm
New-Cluster : An error occurred while performing the operation.
    An error occurred while creating the cluster 'Cluster1'.
    An error occurred creating cluster 'Cluster1'.
    This operation returned because the timeout period expired
At line:1 char:1
+ New-Cluster -Name Cluster1 -Node VL-CL1, VL-CL2 -StaticAddress 10.6.2 ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [New-Cluster], ClusterCmdletException
    + FullyQualifiedErrorId : New-Cluster,Microsoft.FailoverClusters.PowerShell.NewClusterCommand

PS C:\Users\administrator.VIRTUALLAB> remove-ClusterNode -Name VL-CL1 -Force
WARNING: If you are running Windows PowerShell remotely, note that some failover clustering cmdlets do not work remotely. When possible, run the cmdlet locally and specify a remote computer as the target. To run the cmdlet remotely, try using the Credential 
Security Service Provider (CredSSP). All additional errors or warnings from this cmdlet might be caused by running it remotely.
remove-ClusterNode : The cluster service is not running.  Make sure that the service is running on all nodes in the cluster.
    There are no more endpoints available from the endpoint mapper
At line:1 char:1
+ remove-ClusterNode -Name VL-CL1 -Force
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ConnectionError: (:) [Remove-ClusterNode], ClusterCmdletException
    + FullyQualifiedErrorId : ClusterEndpointNotRegistered,Microsoft.FailoverClusters.PowerShell.RemoveClusterNodeCommand

PS C:\Users\administrator.VIRTUALLAB> Clear-ClusterNode -Name VL-CL2 -Force

PS C:\Users\administrator.VIRTUALLAB> Clear-ClusterNode -Name VL-CL1 -Force


 

PS C:\Users\administrator.VIRTUALLAB> New-Cluster -Name Cluster1 -Node VL-CL1 -StaticAddress 10.6.226.200 -IgnoreNetwork
New-Cluster : Missing an argument for parameter 'IgnoreNetwork'. Specify a parameter of type 'System.Collections.Specialized.StringCollection' and try again.
At line:1 char:69
+ ... Name Cluster1 -Node VL-CL1 -StaticAddress 10.6.226.200 -IgnoreNetwork
+                                                            ~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [New-Cluster], ParameterBindingException
    + FullyQualifiedErrorId : MissingArgument,Microsoft.FailoverClusters.PowerShell.NewClusterCommand
 

PS C:\Users\administrator.VIRTUALLAB> New-Cluster -Name Cluster1 -Node VL-CL1 -StaticAddress 10.6.226.200

Name    
----    
Cluster1



PS C:\Users\administrator.VIRTUALLAB> Get-Cluster
WARNING: If you are running Windows PowerShell remotely, note that some failover clustering cmdlets do not work remotely. When possible, run the cmdlet locally and specify a remote computer as the target. To run the cmdlet remotely, try using the Credential 
Security Service Provider (CredSSP). All additional errors or warnings from this cmdlet might be caused by running it remotely.
Get-Cluster : The cluster service is not running.  Make sure that the service is running on all nodes in the cluster.
    There are no more endpoints available from the endpoint mapper
At line:1 char:1
+ Get-Cluster
+ ~~~~~~~~~~~
    + CategoryInfo          : ConnectionError: (:) [Get-Cluster], ClusterCmdletException
    + FullyQualifiedErrorId : ClusterEndpointNotRegistered,Microsoft.FailoverClusters.PowerShell.GetClusterCommand

PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1

Name    
----    
Cluster1



PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | ft

Name    
----    
Cluster1



PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | fl


Name : Cluster1




PS C:\Users\administrator.VIRTUALLAB> Get-ClusterParameter -Name Cluster1 | fl
Get-ClusterParameter : No cluster object was specified.
At line:1 char:1
+ Get-ClusterParameter -Name Cluster1 | fl
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Get-ClusterParameter], ClusterCmdletException
    + FullyQualifiedErrorId : PSArgument,Microsoft.FailoverClusters.PowerShell.GetParameterCommand

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




PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 |  Add-ClusterNode -Name VL-CL2

PS C:\Users\administrator.VIRTUALLAB> Get-ClusterNode
WARNING: If you are running Windows PowerShell remotely, note that some failover clustering cmdlets do not work remotely. When possible, run the cmdlet locally and specify a remote computer as the target. To run the cmdlet remotely, try using the Credential 
Security Service Provider (CredSSP). All additional errors or warnings from this cmdlet might be caused by running it remotely.
Get-ClusterNode : The cluster service is not running.  Make sure that the service is running on all nodes in the cluster.
    There are no more endpoints available from the endpoint mapper
At line:1 char:1
+ Get-ClusterNode
+ ~~~~~~~~~~~~~~~
    + CategoryInfo          : ConnectionError: (:) [Get-ClusterNode], ClusterCmdletException
    + FullyQualifiedErrorId : ClusterEndpointNotRegistered,Microsoft.FailoverClusters.PowerShell.GetNodeCommand

PS C:\Users\administrator.VIRTUALLAB> Get-ClusterNode -Name Cluster1
WARNING: If you are running Windows PowerShell remotely, note that some failover clustering cmdlets do not work remotely. When possible, run the cmdlet locally and specify a remote computer as the target. To run the cmdlet remotely, try using the Credential 
Security Service Provider (CredSSP). All additional errors or warnings from this cmdlet might be caused by running it remotely.
Get-ClusterNode : The cluster service is not running.  Make sure that the service is running on all nodes in the cluster.
    There are no more endpoints available from the endpoint mapper
At line:1 char:1
+ Get-ClusterNode -Name Cluster1
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ConnectionError: (:) [Get-ClusterNode], ClusterCmdletException
    + FullyQualifiedErrorId : ClusterEndpointNotRegistered,Microsoft.FailoverClusters.PowerShell.GetNodeCommand

PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {New-Item -Path c:\Quorum -ItemType Directory
Missing closing '}' in statement block or type definition.
    + CategoryInfo          : ParserError: (:) [], ParentContainsErrorRecordException
    + FullyQualifiedErrorId : MissingEndCurlyBrace
 

PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock {New-Item -Path c:\Quorum -ItemType Directory}


    Directory: C:\


Mode                LastWriteTime         Length Name                                                               PSComputerName                                                   
----                -------------         ------ ----                                                               --------------                                                   
d-----        4/28/2025  11:05 AM                Quorum                                                             VL-STOR1                                                         



PS C:\Users\administrator.VIRTUALLAB> Invoke-Command -ComputerName VL-STOR1 -ScriptBlock { New-SmbShare -Name Quorum -Path c:\Quorum -FullAccess Everyone}

Name   ScopeName Path      Description PSComputerName
----   --------- ----      ----------- --------------
Quorum *         c:\Quorum             VL-STOR1      



PS C:\Users\administrator.VIRTUALLAB> Set-ClusterQuorum -NodeAndFilesShareMajority \\VL-STOR1\Quorum
Set-ClusterQuorum : A parameter cannot be found that matches parameter name 'NodeAndFilesShareMajority'.
At line:1 char:19
+ Set-ClusterQuorum -NodeAndFilesShareMajority \\VL-STOR1\Quorum
+                   ~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Set-ClusterQuorum], ParameterBindingException
    + FullyQualifiedErrorId : NamedParameterNotFound,Microsoft.FailoverClusters.PowerShell.SetClusterQuorumCommand
 

PS C:\Users\administrator.VIRTUALLAB> Set-ClusterQuorum -FileShareWitness \\VL-STOR1\Quorum
WARNING: If you are running Windows PowerShell remotely, note that some failover clustering cmdlets do not work remotely. When possible, run the cmdlet locally and specify a remote c
omputer as the target. To run the cmdlet remotely, try using the Credential Security Service Provider (CredSSP). All additional errors or warnings from this cmdlet might be caused by
 running it remotely.
Set-ClusterQuorum : The cluster service is not running.  Make sure that the service is running on all nodes in the cluster.
    There are no more endpoints available from the endpoint mapper
At line:1 char:1
+ Set-ClusterQuorum -FileShareWitness \\VL-STOR1\Quorum
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ConnectionError: (:) [Set-ClusterQuorum], ClusterCmdletException
    + FullyQualifiedErrorId : ClusterEndpointNotRegistered,Microsoft.FailoverClusters.PowerShell.SetClusterQuorumCommand

PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Set-ClusterQuorum -FileShareWitness \\VL-STOR1\Quorum

Cluster              QuorumResource                                                                                                                                                  
-------              --------------                                                                                                                                                  
Cluster1             File Share Witness                                                                                                                                              



PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Get-ClusterAvailableDisk

PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Get-ClusterResource

Name                 State  OwnerGroup        ResourceType              
----                 -----  ----------        ------------              
Cluster Disk 1       Online Available Storage Physical Disk             
Cluster IP Address   Online Cluster Group     IP Address                
Cluster Name         Online Cluster Group     Network Name              
File Share Witness   Online Cluster Group     File Share Witness        
Storage Qos Resource Online Cluster Group     Storage QoS Policy Manager



PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Get-ClusterAvailableDisk

PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Get-ClusterAvailableDisk -All

PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Get-ClusterResource | Where-Object ResourceType -eq 'Physical Disk'

Name           State  OwnerGroup        ResourceType 
----           -----  ----------        ------------ 
Cluster Disk 1 Online Available Storage Physical Disk



PS C:\Users\administrator.VIRTUALLAB> Add-ClusterSharedVolume -Name 'Cluster Disk 1'
WARNING: If you are running Windows PowerShell remotely, note that some failover clustering cmdlets do not work remotely. When possible, run the cmdlet locally and specify a remote c
omputer as the target. To run the cmdlet remotely, try using the Credential Security Service Provider (CredSSP). All additional errors or warnings from this cmdlet might be caused by
 running it remotely.
Add-ClusterSharedVolume : The cluster service is not running.  Make sure that the service is running on all nodes in the cluster.
    There are no more endpoints available from the endpoint mapper
At line:1 char:1
+ Add-ClusterSharedVolume -Name 'Cluster Disk 1'
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ConnectionError: (:) [Add-ClusterSharedVolume], ClusterCmdletException
    + FullyQualifiedErrorId : ClusterEndpointNotRegistered,Microsoft.FailoverClusters.PowerShell.AddClusterSharedVolumeCommand

PS C:\Users\administrator.VIRTUALLAB> Get-Cluster -Name Cluster1 | Add-ClusterSharedVolume -Name 'Cluster Disk 1'

Name           State  Node  
----           -----  ----  
Cluster Disk 1 Online VL-CL2