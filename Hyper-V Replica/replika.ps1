# Krok 0. Przygotowanie hostów do obsługi wirtualizacji zagnieżdżonej i skonfigurowanie kart sieciowych

# Ponieważ serwerem docelowym i źródłowym repliki będzie maszyna wirtualna
# musimy na nich włączyć wirtualizację zagnieżdżoną a na kartach sieciowych włączyć fałszowanie adresów MAC
# Polecenia wykonujemy na komputerze który hostuje obie maszyny

Stop-VM -Name $VMName
Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
Get-VMNetworkAdapter -VMName $VMName | Set-VMNetworkAdapter -MacAddressSpoofing On

# Krok 1. Instalacja funkcji Hyper-V na serwerze docelowym repliki.

Enter-PSSession -ComputerName host2

Install-WindowsFeature -Name hyper-v -IncludeAllSubFeature -IncludeManagementTools -Restart

# Krok 2. Zapora

Get-NetFirewallRule -DisplayName "Hyper-V Replica HTTP Listener (TCP-In)"
Enable-NetFirewallRule -DisplayName "Hyper-V Replica HTTP Listener (TCP-In)"

Enter-PSSession -ComputerName HOST2

Get-NetFirewallRule -DisplayName "Hyper-V Replica HTTP Listener (TCP-In)"
Enable-NetFirewallRule -DisplayName "Hyper-V Replica HTTP Listener (TCP-In)"

Exit-PSSession

#Krok 3. Konfigurowanie funkcji repliki

Set-VMReplicationServer -ReplicationEnabled $true -AllowedAuthenticationType Kerberos -ReplicationAllowedFromAnyServer $true -DefaultStorageLocation 'c:\Replicas' -KerberosAuthenticationPort 80 -ComputerName 'HOST1', 'HOST2'
Get-VMReplicationServer

#kROK 4. Włączenie replikacji

Enable-VMReplication -VMName 'CORE1' -ComputerName 'HOST1' -ReplicaServerName 'HOST2' -ReplicaServerPort 80 -AuthenticationType Kerberos -CompressionEnabled $true -RecoveryHistory 5

Get-VM

#Krok 5. Inicjowanie replikacji

Start-VMInitialReplication -VMName 'CORE1'

Get-VMReplication

Measure-VMReplication -ComputerName 'HOST1'

Get-VM -ComputerName HOST2

#Krok 6. Test

Enter-PSSession -ComputerName HOST2
Get-VM
$testVM = Start-VMFailover -AsTest -VMName 'CORE1' -Confirm:$false 
Start-VM $testVM
Get-VM
Exit-PSSession

#Krok 7. zatrzymanie testu

Enter-PSSession -ComputerName HOST2

Stop-VMFailover -VMName 'CORE1'

Get-VM
Exit-PSSession

#Krok 8. Zatrymanie maszyny CORE1 na HOST1 (symulacja awarii) i przełączenie na HOST2

Stop-VM -VMName 'CORE1' -Force

Enter-PSSession -ComputerName HOST2

Start-VMFailover -VMName 'CORE1' -Confirm:$false

Complete-VMFailover -VMName 'CORE1' -Confirm:$false

Start-VM -VMName 'CORE1'


Get-VM
Exit-PSSession

Get-VM