# Hyper-V Replica — konfiguracja i procedury

Ten dokument opisuje kroki, jakie wykonano podczas konfiguracji Hyper-V Replica w środowisku labowym. Zawiera polecenia PowerShell użyte w procesie, objaśnienia oraz wskazówki diagnostyczne i najlepsze praktyki.

> Uwaga: wszystkie przykładowe polecenia były uruchamiane w PowerShell/Enter-PSSession na kontrolowanych hostach (HOST1, HOST2). Dostosuj nazwy komputerów, ścieżki i polityki bezpieczeństwa do własnego środowiska. \
> Ponieważ serwerem docelowym i źródłowym repliki będzie maszyną wirtualną musimy na nich włączyć wirtualizację zagnieżdżoną a na kartach sieciowych włączyć fałszowanie adresów MAC. Polecenia wykonujemy na komputerze który hostuje obie maszyny, dla obu maszym wiryualnych:
> ```powershell
>$VMName = HOST1
>Stop-VM -Name $VMName
>Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true
>Get-VMNetworkAdapter -VMName $VMName | Set-VMNetworkAdapter -MacAddressSpoofing On
>```

---

## Cel
Skonfigurować replikację maszyn wirtualnych pomiędzy dwoma hostami Hyper-V (HOST1 i HOST2) przy użyciu Kerberos (HTTP na porcie 80) oraz przetestować mechanizmy replikacji i failover.

## Wymagania wstępne
- Role Hyper-V zainstalowane na obu hostach.
- Zarządzanie z uprawnieniami administratora (konto Domain Admin lub odpowiednie prawa do konfiguracji Hyper-V i zapory).
- Jeśli używasz Kerberos (autentykacja Windows), hosty powinny znajdować się w tej samej domenie lub mieć skonfigurowane zaufanie, a SPN/ACL powinny być poprawne.
- Dopuszczony ruch sieciowy na porcie 80 (HTTP) lub 443 (HTTPS) między hostami, zależnie od konfiguracji.

## Kroki wykonane (z przykładami poleceń)

### 1. Połączenie z hostem zdalnym (PSSession)
Użyj `Enter-PSSession`, aby wykonywać polecenia bezpośrednio na zdalnym hoście:

```powershell
Enter-PSSession -ComputerName HOST2
```

### 2. Instalacja roli Hyper-V (jeśli brak)
Na hoście docelowym wykonano instalację roli Hyper-V wraz z narzędziami zarządzania:

```powershell
[host2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Install-WindowsFeature -Name hyper-v -IncludeAllSubFeature -IncludeManagementTools -Restart

Success Restart Needed Exit Code      Feature Result                               
------- -------------- ---------      --------------                               
True    Yes            SuccessRest... {Hyper-V, Hyper-V Module for Windows Power...
WARNING: You must restart this server to finish the installation process.
```

Po instalacji serwer wymaga restartu.

### 3. Włączenie reguły zapory dla Hyper-V Replica (HTTP)
Sprawdzenie reguły i włączenie jej:

```powershell
[host2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-NetFirewallRule -DisplayName "Hyper-V Replica HTTP Listener (TCP-In)"


Name                          : VIRT-HVRHTTPL-In-TCP-NoScope
DisplayName                   : Hyper-V Replica HTTP Listener (TCP-In)
Description                   : Inbound rule for Hyper-V Replica listener to accept HTTP connection for replication. [TCP]
DisplayGroup                  : Hyper-V Replica HTTP
Group                         : @%systemroot%\system32\vmms.exe,-251
Enabled                       : False
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
PolicyAppId                   : 
PackageFamilyName             : 

[host2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Enable-NetFirewallRule -DisplayName "Hyper-V Replica HTTP Listener (TCP-In)"

[host2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-NetFirewallRule -DisplayName "Hyper-V Replica HTTP Listener (TCP-In)"


Name                          : VIRT-HVRHTTPL-In-TCP-NoScope
DisplayName                   : Hyper-V Replica HTTP Listener (TCP-In)
Description                   : Inbound rule for Hyper-V Replica listener to accept HTTP connection for replication. [TCP]
DisplayGroup                  : Hyper-V Replica HTTP
Group                         : @%systemroot%\system32\vmms.exe,-251
Enabled                       : False
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
PolicyAppId                   : 
PackageFamilyName             : 
```

Ta reguła umożliwia nasłuch replikacji przez protokół HTTP. Włączamy ją na obu hostach. Jeśli używasz HTTPS (zalecane w produkcji), włącz regułę dla portu 443 i skonfiguruj certyfikat.

Zakończenie sesji zdalnej:
```powershell
[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession
```

### 4. Włączenie serwera replikacji Hyper-V
Na serwerze (lokalnie lub zdalnie) uruchomiono konfigurację `Set-VMReplicationServer`:

```powershell
PS C:\Windows\system32> Set-VMReplicationServer -ReplicationEnabled $true -AllowedAuthenticationType Kerberos -ReplicationAllowedFromAnyServer $true -DefaultStorageLocation 'C:\Replicas' -KerberosAuthenticationPort 80
```

Parametry:
- `ReplicationEnabled $true` — włącza funkcję replikacji.
- `AllowedAuthenticationType Kerberos` — ustawia Kerberos (Windows) jako metodę uwierzytelniania.
- `ReplicationAllowedFromAnyServer $true` — zezwala na przyjmowanie replik z dowolnego hosta (można doprecyzować listę).
- `DefaultStorageLocation` — domyślna ścieżka przechowywania replik.
- `KerberosAuthenticationPort` — port do autentykacji Kerberos (HTTP/80 w tym labie).

Sprawdzenie stanu:

```powershell
PS C:\Windows\system32> Get-VMReplicationServer

RepEnabled AuthType KerbAuthPort CertAuthPort AllowAnyServer
---------- -------- ------------ ------------ --------------
True       Kerb     80           443          True          
```

Wyjście pokazuje, czy replikacja jest włączona i typ autentykacji.

### 5. Włączenie replikacji dla konkretnej maszyny wirtualnej (na hoście źródłowym)
Na hoście źródłowym (np. HOST1) uruchomiono:

```powershell
PS C:\Windows\system32> Enable-VMReplication -VMName 'CORE1' -ReplicaServerName 'HOST2' -ReplicaServerPort 80 -AuthenticationType Kerberos -CompressionEnabled $true -RecoveryHistory 5
```

Parametry:
- `ReplicaServerName` — nazwa hosta docelowego.
- `ReplicaServerPort` — port (80 dla Kerberos w tym przykładzie).
- `AuthenticationType` — Kerberos.
- `CompressionEnabled` — włączenie kompresji replikowanych danych.
- `RecoveryHistory` — liczba punktów przywracania (np. 5).

Po uruchomieniu polecenia stan VM zmienia się na `ReadyForInitialReplication`.

### 6. Pomiar i rozpoczęcie początkowej replikacji
Sprawdzanie stanu i pomiar:

```powershell
PS C:\Windows\system32> Get-VMReplication

VMName State                      Health  Mode    FrequencySec PrimaryServer ReplicaServer ReplicaPort AuthType Relationship
------ -----                      ------  ----    ------------ ------------- ------------- ----------- -------- ------------
CORE1  ReadyForInitialReplication Warning Primary 300          HOST1         HOST2         80          Kerberos Simple      

PS C:\Windows\system32> Measure-VMReplication -ComputerName 'HOST1'

VMName State                      Health  LReplTime PReplSize(M) AvgLatency AvgReplSize(M) Relationship
------ -----                      ------  --------- ------------ ---------- -------------- ------------
CORE1  ReadyForInitialReplication Warning           6,468.00                0.00           Simple      
```

Start początkowej replikacji:

```powershell
PS C:\Windows\system32> Start-VMInitialReplication -VMName 'CORE1'

PS C:\Windows\system32> Measure-VMReplication -ComputerName 'HOST1'

VMName State                        Health LReplTime PReplSize(M) AvgLatency AvgReplSize(M) Relationship
------ -----                        ------ --------- ------------ ---------- -------------- ------------
CORE1  InitialReplicationInProgress Normal           6,472.00                0.00           Simple      

PS C:\Windows\system32> Get-VMReplication

VMName State       Health Mode    FrequencySec PrimaryServer ReplicaServer ReplicaPort AuthType Relationship
------ -----       ------ ----    ------------ ------------- ------------- ----------- -------- ------------
CORE1  Replicating Normal Primary 300          HOST1         HOST2         80          Kerberos Simple      
```

Po uruchomieniu początkowej replikacji status powinien przejść do `InitialReplicationInProgress`, a następnie `Replicating`.

Sprawdzamy czy na hoście HOST2 pojawiła się zreplikowana maszyna:
```powershell
PS C:\Windows\system32> Get-VM -ComputerName HOST2

Name  State CPUUsage(%) MemoryAssigned(M) Uptime   Status             Version
----  ----- ----------- ----------------- ------   ------             -------
CORE1 Off   0           0                 00:00:00 Operating normally 12.0   
```

### 7. Testowy failover (Test Failover)
Na hoście docelowym (HOST2) wykonano testowy failover (uruchamia kopię testową VM):

```powershell
PS C:\Windows\system32> Enter-PSSession -ComputerName HOST2
[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> $testVM = Start-VMFailover -AsTest -VMName 'CORE1' -Confirm:$false

[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-VM

Name         State CPUUsage(%) MemoryAssigned(M) Uptime   Status             Version
----         ----- ----------- ----------------- ------   ------             -------
CORE1        Off   0           0                 00:00:00 Operating normally 12.0   
CORE1 - Test Off   0           0                 00:00:00 Operating normally 12.0   

[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-VM $testVM

[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-VM

Name         State   CPUUsage(%) MemoryAssigned(M) Uptime           Status             Version
----         -----   ----------- ----------------- ------           ------             -------
CORE1        Off     0           0                 00:00:00         Operating normally 12.0   
CORE1 - Test Running 1           512               00:01:35.9730000 Operating normally 12.0   

# Po teście zatrzymaj i zakończ testowy failover
[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Stop-VMFailover -VMName 'CORE1'

[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Get-VM

Name  State CPUUsage(%) MemoryAssigned(M) Uptime   Status             Version
----  ----- ----------- ----------------- ------   ------             -------
CORE1 Off   0           0                 00:00:00 Operating normally 12.0   

[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Exit-PSSession
```

Testowy failover tworzy tymczasową, testową instancję (zwykle z dopiskiem "- Test") — nie wpływa na produkcyjną replikę.

### 8. Wykonanie właściwego failover i jego zatwierdzenie (failover production)
Scenariusz wykonywany gdy planujemy przełączenie do repliki (np. awaria źródła):

Na hoście źródłowym zatrzymujemy maszynę wirtualną symulując awarję:
```powershell
PS C:\Windows\system32> Stop-VM -VMName 'CORE1' -Force
```

Na hoście repliki:
```powershell
PS C:\Windows\system32> Enter-PSSession -ComputerName HOST2

[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-VMFailover -VMName 'CORE1' -Confirm:$false

# Po sprawdzeniu, jeżeli chcemy na stałe przełączyć:
[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Complete-VMFailover -VMName 'CORE1' -Confirm:$false

[HOST2]: PS C:\Users\Administrator.VIRTUALLAB\Documents> Start-VM -VMName 'CORE1'
```

`Complete-VMFailover` kończy proces failover i replika staje się nowym źródłem.

### 9. Przywrócenie (reverse replication)
Po zakończeniu failoveru możesz opcjonalnie skonfigurować replikację z powrotem na poprzedni host.
Polecenia zależą od scenariusza (możesz odwrócić rolę Primary/Replica lub ponownie skonfigurować Enable-VMReplication).

## Weryfikacja i monitorowanie
- `Get-VMReplication` — pokazuje status replikacji dla VM.
- `Measure-VMReplication` — podaje dodatkowe metryki, takie jak opóźnienia i rozmiary repliki.
- `Get-VM` na hoście docelowym — potwierdza stan maszyn po failover.

## Częste problemy i wskazówki
- Firewall: upewnij się, że reguły dla Hyper-V Replica są włączone na obu hostach (HTTP/HTTPS). Użytkownik z logów musiał ręcznie włączyć regułę "Hyper-V Replica HTTP Listener (TCP-In)".
- Autentykacja: Kerberos wymaga prawidłowego działania domeny i SPN. W środowiskach nie-domenowych rozważ użycie certyfikatów (HTTPS).
- Pozwolenia: konto wykonujące operacje musi mieć uprawnienia do zarządzania Hyper-V na obu hostach.
- Storage: upewnij się, że docelowy katalog (`C:\Replicas` w przykładzie) ma wystarczająco dużo miejsca i odpowiednie uprawnienia.
- Initial replication: może trwać długo w zależności od rozmiaru VM. Można użyć offline initial replication (eksport/import), jeśli sieć jest wolna.

## Przykładowe polecenia diagnostyczne
- Sprawdź czy reguły zapory są włączone:
```powershell
Get-NetFirewallRule -DisplayName "Hyper-V Replica HTTP Listener (TCP-In)" | Format-List Name,Enabled,DisplayName
```

- Sprawdź konfigurację serwera replikacji:
```powershell
Get-VMReplicationServer | Format-List *
```

- Sprawdź szczegóły replikacji konkretnej maszyny:
```powershell
Get-VMReplication -VMName 'CORE1' | Format-List *
Measure-VMReplication -ComputerName 'HOST1'
```

## Bezpieczeństwo i dobre praktyki
- W środowisku produkcyjnym preferuj HTTPS (Certyfikat) zamiast Kerberos over HTTP.
- Zdefiniuj listę dozwolonych hostów zamiast `ReplicationAllowedFromAnyServer = $true`.
- Regularnie weryfikuj kopie i przeprowadzaj testowe failovery.

