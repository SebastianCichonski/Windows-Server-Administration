# Przenoszenie i przejmowanie ról FSMO


**Role FSMO** - Usługa katalogowa Active Directory opiera swoje działanie na pięciu odrębnych rolach, role te nie są przypisane do konkretnych kontrolerów domeny co daje możliwość przenoszenia lub przejmowania ról pomiędzy kontrolerami.

Na poziomie lasu wyróżniamy dwie role: **Schema Master** i **Domain Naming Master**, na poziomie domeny wyróżniamy trzy role: **RID Master**, **PDC Emulator** i **Infrastructure Master**.

**Shema Master** - jest odpowiedzialny za aktualizację schematu domeny, czyli bazy struktury wszystkich obiektów w lesie ich pól i właściwości.

**Domain Naming Master** - jest odpowiedzialny za wprowadzanie zmian w przestrzeni nazw lasu, może dodawać i usuwać domeny w lesie.

**RID Master** - jest odpowiedzialny za rozsyłanie pul identyfikatorów RID do kontrolerów w domenie a także za przenoszenie obiektów między domenami.
Identyfikatory RID są wykorzystywane przez kontrolery do budowy identyfikatorów SID które otrzymuje każdy obiekt w domenie.

**PDC Emulator** - spełnia kilka funkcji: 
  - synchronizacja czasu w domenie
  - synchronizacja haseł pomiędzy kontrolerami
  - weryfikacja aktualności wprowadzanych haseł
  - blokowanie kont po przekroczeniu limitu błędnych haseł

**Infrastructure Master** -  jest odpowiedzialny za aktualizowanie odwołań z obiektów w domenie do obiektów w innych domenach.

## I. Przenoszenie a przejmowanie roli FSMO
Przenoszenie roli powinno się odbywać w scenariuszu kiedy posiadacz roli jest sprawny ale jest planowane jego wyłączenie (np: upgrade, konserwacja itp.) Natomiast przejęcie jest wykonywane gdy posiadacz roli już nie działa i nie ma możliwości żeby przywrócić go do domeny.
## II. Przenoszenie - narzędzie: Powershell
### Krok 0. Sprawdzamy dostępne kontrolery domeny
```powershell
> Get-ADDomainController -Filter * | Select-Object -Property HostName

HostName
--------
NYC-DC1.azseblab.com
NYC-DC2.azseblab.com
BIR-RODC.azseblab.com
```
### Krok 1. Sprawdzamy na jakich kontrolerach są poszczególne role

Na poziomie lasu są dwie role:
```powershell
> Get-ADForest | Select-Object -Property SchemaMaster, DomainNamingMaster | fl

SchemaMaster       : NYC-DC1.azseblab.com
DomainNamingMaster : NYC-DC1.azseblab.com
```

Na poziomie domeny są trzy role:
```powershell
> Get-ADDomain | Select-Object -Property InfrastructureMaster, PDCEmulator, RIDMaster | fl


InfrastructureMaster : NYC-DC1.azseblab.com
PDCEmulator          : NYC-DC1.azseblab.com
RIDMaster            : NYC-DC1.azseblab.com
```
Wszystkie role są przypisane do jednego kontrolera domeny - **NYC-DC1.azseblab.com**

### Krok 2. Przenoszenie ról
Przeniesienie PDC Emulatora:
```powershell
> Move-ADDirectoryServerOperationMasterRole -Identity "nyc-dc2" -OperationMasterRole PDCEmulator
Move Operation Master Role
Do you want to move role 'PDCEmulator' to server 'NYC-DC2.azseblab.com' ?
&Yes  Yes to &All  &No  No to A&ll  &Suspend
Y
```
Weryfikacja:
```powershell
> Get-ADDomain | Select-Object -Property InfrastructureMaster, PDCEmulator, RIDMaster | fl

InfrastructureMaster : NYC-DC1.azseblab.com
PDCEmulator          : NYC-DC2.azseblab.com
RIDMaster            : NYC-DC1.azseblab.com
```
Przeniesienie RID Master i Infrastructure Master:
```powershell
> Move-ADDirectoryServerOperationMasterRole -Identity "nyc-dc2" -OperationMasterRole InfrastructureMaster, RIDMaster
Move Operation Master Role
Do you want to move role 'InfrastructureMaster' to server 'NYC-DC2.azseblab.com' ?
&Yes  Yes to &All  &No  No to A&ll  &Suspend
A
```
Weryfikacja
```powershell
> Get-ADDomain | Select-Object -Property InfrastructureMaster, PDCEmulator, RIDMaster | fl


InfrastructureMaster : NYC-DC2.azseblab.com
PDCEmulator          : NYC-DC2.azseblab.com
RIDMaster            : NYC-DC2.azseblab.com
```
zamiast nazw ról, możemy użyć wartości numerycznych:

 0 - PDCEmulator\
 1 - RIDMaster \
 2 - InfrastructureMaster\
 3 - SchemaMaster\
 4 - DomainNamingMaster

Przeniesienie Schema Master i Domain Naming Master używając wartości numerycznych:
 ```powershell
 > Move-ADDirectoryServerOperationMasterRole -Identity "nyc-dc2" -OperationMasterRole 3, 4
Move Operation Master Role
Do you want to move role 'SchemaMaster' to server 'NYC-DC2.azseblab.com' ?
&Yes  Yes to &All  &No  No to A&ll  &Suspend
A
```
Weryfikacja:
 ```powershell
 > Get-ADForest | Select-Object -Property SchemaMaster, DomainNamingMaster | fl

SchemaMaster       : NYC-DC2.azseblab.com
DomainNamingMaster : NYC-DC2.azseblab.com
 ```
 Wszystkie role zostały przeniesione na serwer - **NYC-DC2.azseblab.com**

 Role zostaną przeniesione z powrotem na serwer **NYC-DC1** za pomocą narzędzia **NTDSUTI.EXE**

 ## III. Przenoszenie - narzędzie: Ntdsutil.exe
 ### Krok 0. Uruchamiamy ntdsutil.exe
 ```
 > ntdsutil.exe

ntdsutil.exe:
 ```
 Sprawdzamy dostępne opcje:
 ```
> ntdsutil.exe: ?

 ?                             - Show this help information
 Activate Instance %s          - Set "NTDS" or a specific AD LDS instance
                                 as the active instance.
 Authoritative restore         - Authoritatively restore the DIT database
 Change Service Account %s1 %s2 - Change AD DS/LDS Service Account to
                                 username %s1 and password %s2.
                                 Use "NULL" for blank password, * to
                                 enter password from the console.
 Configurable Settings         - Manage configurable settings
 DS Behavior                   - View and modify AD DS/LDS Behavior
 Files                         - Manage AD DS/LDS database files
 Group Membership Evaluation   - Evaluate SIDs in token for a given user or
                                 group
 Help                          - Show this help information
 IFM                           - IFM media creation
 LDAP policies                 - Manage LDAP protocol policies
 LDAP Port %d                  - Configure LDAP Port for an AD LDS Instance.
 List Instances                - List all AD LDS instances installed
                                 on this machine.
 Local Roles                   - Local RODC roles management
 Metadata cleanup              - Clean up objects of decommissioned servers
 Partition management          - Manage directory partitions
 Popups off                    - Disable popups
 Popups on                     - Enable popups
 Quit                          - Quit the utility
 Roles                         - Manage NTDS role owner tokens
 Security account management   - Manage Security Account Database - Duplicate
                                 SID Cleanup
 Semantic database analysis    - Semantic Checker
 Set DSRM Password             - Reset directory service restore mode
                                 administrator account password

 Snapshot                      - Snapshot management
 SSL Port %d                   - Configure SSL Port for an AD LDS Instance.
```
### Krok 1. Przechodzimy do zarządzanie rolami
```
> ntdsutil.exe: Roles

fsmo maintenance: 
```
 Sprawdzamy dostępne opcje:
 ```
 > fsmo maintenance: ?

 ?                             - Show this help information
 Connections                   - Connect to a specific AD DC/LDS instance
 Help                          - Show this help information
 Quit                          - Return to the prior menu
 Seize infrastructure master   - Overwrite infrastructure role on connected server
 Seize naming master           - Overwrite Naming Master role on connected server
 Seize PDC                     - Overwrite PDC role on connected server
 Seize RID master              - Overwrite RID role on connected server
 Seize schema master           - Overwrite schema role on connected server
 Select operation target       - Select sites, servers, domains, roles and
                                 naming contexts
 Transfer infrastructure master - Make connected server the infrastructure master
 Transfer naming master        - Make connected server the naming master
 Transfer PDC                  - Make connected server the PDC
 Transfer RID master           - Make connected server the RID master
 Transfer schema master        - Make connected server the schema master
 ```
 ### Krok 2. Wybieramy opcję połączenia
 ```
 > fsmo maintenance: connections

server connections: 
 ```
 Sprawdzamy dostępne opcje dot. połączeń:
 ```
> server connections: ?

 ?                             - Show this help information
 Clear creds                   - Clear prior connection credentials
 Connect to domain %s          - Connect to DNS domain name
 Connect to server %s          - Connect to server, DNS name[:port number]
 Help                          - Show this help information
 Info                          - Show connection information
 Quit                          - Return to the prior menu
 Set creds %s1 %s2 %s3         - Set connection creds as domain %s1, user %s2,
                                 pwd %s3.  Use "NULL" for null password,
                                 * to enter password from the console.
```
### Krok 3. Łączymy się z serwerem na który chcemy przenieść role
```
> server connections: connect to server nyc-dc1
Binding to nyc-dc1 ...
Connected to nyc-dc1 using credentials of locally logged on user.
```
 Po poprawnym nawiązaniu połączenia wychodzimy z menu połączeń:
 ``` 
> server connections: q
```
### Krok 4. Przeniesienie ról


PDC Emulator
```
> fsmo maintenance: transfer PDC

Server "nyc-dc1" knows about 5 roles
Schema - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Naming Master - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
PDC - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
RID - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Infrastructure - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
```
Infrastructure Master
```
> fsmo maintenance: transfer infrastructure master

Server "nyc-dc1" knows about 5 roles
Schema - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Naming Master - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
PDC - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
RID - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Infrastructure - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
```

Domain Naming Master
```
> fsmo maintenance: transfer naming master

Server "nyc-dc1" knows about 5 roles
Schema - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Naming Master - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
PDC - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
RID - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Infrastructure - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
```
 RID Master
 ```
> fsmo maintenance: transfer rid master

Server "nyc-dc1" knows about 5 roles
Schema - CN=NTDS Settings,CN=NYC-DC2,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Naming Master - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
PDC - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
RID - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Infrastructure - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
```
Schema Master
```
> fsmo maintenance: transfer schema master

Server "nyc-dc1" knows about 5 roles
Schema - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Naming Master - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
PDC - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
RID - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
Infrastructure - CN=NTDS Settings,CN=NYC-DC1,CN=Servers,CN=Site1,CN=Sites,CN=Configuration,DC=azseblab,DC=com
```
Wszystkie role zostały przeniesione z powrotem na serwer **NYC-DC1**

Zamknięcie narzędzia ntdsutil.exe:

```
fsmo maintenance: q
ntdsutil.exe: q
```

## IV. Przejmowanie ról
W przypadku użycia Powershell do przejmowania roli, komenda jest ta sama co w przypadku przenoszenia roli z dodatkowym parametrem **-Force**

Przykład:
```powershell
> Move-ADDirectoryServerOperationMasterRole -Identity "nyc-dc2" -OperationMasterRole PDCEmulator -Force
```
W przypadku użycia ntdsutil.exe będąc w menu **fsmo maintenance:** wybieramy opcję **Seize ...** zamiast **Transfer ...**.
