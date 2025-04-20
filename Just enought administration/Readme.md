# Just Enough Administration

Just Enough Administration (JEA) to technologia pozwalająca na delegację administracji, ograniczająca liczbę wymaganych kont uprzywilejowanych do administracji serwerami, w myśl zasady jak najmniejszych uprawnień mocno ograniczająca to co użytkownicy mogą zrobić. 

## Zasada działania

Za pomocą JEA tworzymy punkt końcowy na serwerach którymi trzeba zarządzać. Dokładnie określamy z jakich poleceń, z jakich parametrów tych poleceń, skryptów czy modułów może korzystać użytkownik połączony z punktem końcowym. Do połączenia z punktem końcowym i administrowania za jego pomocą nie są potrzebne uprawnienia administratora. Połączona sesja działa na koncie wirtualnym z uprawnieniami lokalnego administratora ograniczona do wykonywania poleceń zdefiniowanych w roli JEA.

## Konfiguracja

**Przykład**: chcemy umożliwić użytkownikom startowanie i restartowanie maszyn wirtualnych, pobieranie danych maszyn wirtualnych i zamykanie maszyn wirtualnych, ale tylko testowych, których nazwa zaczyna się od przedrostka **TEST-**

### 1. Komunikacja zdalna Powershell

Do poprawnego działania JEA wymagana jest włączona komunikacja zdalna Powershell, w systemach serwerowych jest domyślnie włączona. Jeżeli zostanie wyłączona możemy włączyć ją ponownie poleceniem:

```powershell
Enable-PSRemoting
```
### 2. Tworzenie pliku roli

Plik roli określa co ktoś może zrobić w sesji JEA. Szablon pliku konfiguracji roli tworzymy za pomocą polecenia:

```powershell
New-PSRoleCapabilityFile -Path 'C:\Program Files\WindowsPowerShell\Modules\vmrole\RoleCapabilities\VMrole.psrc'
```
podając miejsce w którym ma być zapisany plik roli. Plik roli powiniem znajdować się w katalogu **RoleCapabilities** wewnątrz pliku z modułami. 
Po utworzeniu plik edytujemy i wprowadzamy odpowiednie zmiany:
```powershell
@{
    # ID used to uniquely identify this document
    GUID = 'b98b6f36-3229-4a42-bedf-1ed5b37edb91'
    
    # Author of this document
    Author = 'SC'
    
    # Description of the functionality provided by these settings
     Description = 'This role enables users to restart any VMs nad stop any test VMs'
    
    # Company associated with this document
    CompanyName = 'AZsebLAB'
    
    # Copyright statement for this document
    Copyright = '(c) 2024 SC. All rights reserved.'
    
    # Modules to import when applied to a session
    # ModulesToImport = 'MyCustomModule', @{ ModuleName = 'MyCustomModule'; ModuleVersion = '1.0.0.0'; GUID = '4d30d5f0-cb16-4898-812d-f20a6c596bdf' }
    
    # Aliases to make visible when applied to a session
    # VisibleAliases = 'Item1', 'Item2'
    
    # Cmdlets to make visible when applied to a session
    # VisibleCmdlets = 'Invoke-Cmdlet1', @{ Name = 'Invoke-Cmdlet2'; Parameters = @{ Name = 'Parameter1'; ValidateSet = 'Item1', 'Item2' }, @{ Name = 'Parameter2'; ValidatePattern = 'L*' } }
    
    VisibleCmdlets = 'Restart-VM', 'Get-VM','Start-VM', @{
        Name = 'Stop-VM'
        Parameters = @{ Name = 'Name'; ValidatePattern = 'TEST-[a-zA-Z0-9_\-]*'}
        }
    
    # Functions to make visible when applied to a session
    # VisibleFunctions = 'Invoke-Function1', @{ Name = 'Invoke-Function2'; Parameters = @{ Name = 'Parameter1'; ValidateSet = 'Item1', 'Item2' }, @{ Name = 'Parameter2'; ValidatePattern = 'L*' } }
    
    # External commands (scripts and applications) to make visible when applied to a session
    # VisibleExternalCommands = 'Item1', 'Item2'
    
    VisibleExternalCommands = 'c:\windows\system32\whoami.exe'
    
    # Providers to make visible when applied to a session
    # VisibleProviders = 'Item1', 'Item2'
    
    # Scripts to run when applied to a session
    # ScriptsToProcess = 'C:\ConfigData\InitScript1.ps1', 'C:\ConfigData\InitScript2.ps1'
    
    # Aliases to be defined when applied to a session
    # AliasDefinitions = @{ Name = 'Alias1'; Value = 'Invoke-Alias1'}, @{ Name = 'Alias2'; Value = 'Invoke-Alias2'}
    
    # Functions to define when applied to a session
    # FunctionDefinitions = @{ Name = 'MyFunction'; ScriptBlock = { param($MyInput) $MyInput } }
    
    # Variables to define when applied to a session
    # VariableDefinitions = @{ Name = 'Variable1'; Value = { 'Dynamic' + 'InitialValue' } }, @{ Name = 'Variable2'; Value = 'StaticInitialValue' }
    
    # Environment variables to define when applied to a session
    # EnvironmentVariables = @{ Variable1 = 'Value1'; Variable2 = 'Value2' }
    
    # Type files (.ps1xml) to load when applied to a session
    # TypesToProcess = 'C:\ConfigData\MyTypes.ps1xml', 'C:\ConfigData\OtherTypes.ps1xml'
    
    # Format files (.ps1xml) to load when applied to a session
    # FormatsToProcess = 'C:\ConfigData\MyFormats.ps1xml', 'C:\ConfigData\OtherFormats.ps1xml'
    
    # Assemblies to load when applied to a session
    # AssembliesToLoad = 'System.Web', 'System.OtherAssembly, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
    }
```
>Opis poszczególnych wartości używanych w pliku można znaleźć w tym miejscu: [link](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/jea/role-capabilities?view=powershell-7.4#create-a-role-capability-file)

Za pomocą wpisu:
```powershell
 VisibleCmdlets = 'Restart-VM', 'Get-VM','Start-VM', @{
        Name = 'Stop-VM'
        Parameters = @{ Name = 'Name'; ValidatePattern = 'TEST-[a-zA-Z0-9_\-]*'}
        }
```
określiliśmy komendy z jakich można korzystać podczas sesji, dodatkowo przy poleceniu **Stop-VM** przy użyciu wyrażeń regularnych określiliśmy jaką wartość może mieć parametr **Name**. Dodatkowo pozwalamy na użycie komendy zewnętrznej nie powershellowej **whoami.exe** żeby pokazać na jakim koncie pracujemy podczas sesji.

### 3. Tworzenie pliku sesji

Plik sesji określa sposób skonfigurowania punktu końcowego, między innymi kto ma dostęp do punktu końcowego, jakiem mam przypisane role, jaką nazwę ma endpoint.

Szablon pliku sesji tworzymy poleceniem:
```powershell
New-PSSessionConfigurationFile -Path 'c:\JEAEndpoint\VM_JEAEndpoint.pssc'
```
podająć ścieżkę docelową. Utworzony plik edytujemy żeby skonfigurować endpoint.
```powershell
@{
    # Version number of the schema used for this document
    SchemaVersion = '2.0.0.0'
    
    # ID used to uniquely identify this document
    GUID = '7d1cd470-fec6-4bde-9e79-5778a16de5c3'
    
    # Author of this document
    Author = 'SC'
    
    # Description of the functionality provided by these settings
    # Description = ''
    
    # Session type defaults to apply for this session configuration. Can be 'RestrictedRemoteServer' (recommended), 'Empty', or 'Default'
    SessionType = 'RestrictedRemoteServer'
    
    # Directory to place session transcripts for this session configuration
    TranscriptDirectory = 'C:\Transcripts\'
    
    # Whether to run this session configuration as the machine's (virtual) administrator account
    RunAsVirtualAccount = $true
    
    # Scripts to run when applied to a session
    # ScriptsToProcess = 'C:\ConfigData\InitScript1.ps1', 'C:\ConfigData\InitScript2.ps1'
    
    # User roles (security groups), and the role capabilities that should be applied to them when applied to a session
    # RoleDefinitions = @{ 'azseblab\administrator' = @{ RoleCapabilities = 'SqlAdministration' }; 'CONTOSO\SqlManaged' = @{ RoleCapabilityFiles = 'C:\RoleCapability\SqlManaged.psrc' }; 'CONTOSO\ServerMonitors' = @{ VisibleCmdlets = 'Get-Process' } } 
    RoleDefinitions = @{ 'azseblab\administrator' = @{ RoleCapabilities = 'VMrole' }}
    }
```
>Opis poszczególnych wartości używanych w pliku można znaleźć tu: [link](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/jea/session-configurations?view=powershell-7.4)

W pliku określamy że sesja będzie w trybie bezpiecznego zarządzania (**SessionType**), że będzie rejestrowana transkrypcja z sesji (**TranscriptDirectory**), używamy konta wirtualnego (**RunAsVirtualAccount**) innym możliwym wyborem jest konto usługi zarządzane przez grupę (GMSA) używane w przypadku gdy potrzebujemy podczas sesji tożsamości domeny np: przy dostępie do udziałów sieciowych, na koniec przypisujemy użytkownikom lub grupom odpowiednie zdefiniowane role (**RoleDefinitions**).

Tak utworzony plik testujemy za pomocą polecenia:
```powershell
Test-PSSessionConfigurationFile -Path 'c:\JEAEndpoint\VM_JEAEndpoint.pssc'
```
Testowanie zapewnia że plik ma odpowiednią składnię i można go zarejestrować w systemie.

### 4. Rejestracja endpointu

Rejestrację pliku konfiguracji sesji wykonujemy przy użyciu polecenia cmdlet:
```powershell
Register-PSSessionConfiguration -Name VMadmin -Path 'C:\JEAEndpoint\VM_JEAEndpoint.pssc'
```
Po rejestracji endpointu zalecany jest jeszcze restart usługi WinRm:
```powershell
Restart-Service winrm
```
Poleceniem:
```powershell
Get-PSSessionConfiguration | Select-Object Name
```
sprawdzamy listę zarejestrowanych punktów końcowych w systemie.

### 5. Test 
Łączymy się z endpointem:
```powershell
PS C:\Users\Administrator> Enter-PSSession -ComputerName sea-svr1 -ConfigurationName VMadmin -Credential (Get-Credential)
cmdlet Get-Credential at command pipeline position 1
Supply values for the following parameters:

[sea-svr1]: PS>
```
Sprawdzamy na jakie konto jesteśmy zalogowani:

```powershell
[sea-svr1]: PS> whoami.exe
winrm virtual users\winrm va_1_azseblab_administrator
```
Jak widać jest to konto wirtualne.
Sprawdzamy czy możemy wywołać inne zewnętrzne komendy:
```powershell
[sea-svr1]: PS> ipconfig
The term 'ipconfig.exe' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify 
that the path is correct and try again.
    + CategoryInfo          : ObjectNotFound: (ipconfig.exe:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException
```
Sprawdzamy jakie polecenia cmdlet mamy dostępne:
```powershell
[sea-svr1]: PS> Get-Command

CommandType     Name                                               Version    Source                                                                                                 
-----------     ----                                               -------    ------                                                                                                 
Function        Clear-Host                                                                                                                                                           
Function        Exit-PSSession                                                                                                                                                       
Function        Get-Command                                                                                                                                                          
Function        Get-FormatData                                                                                                                                                       
Function        Get-Help                                                                                                                                                             
Function        Measure-Object                                                                                                                                                       
Function        Out-Default                                                                                                                                                          
Function        Select-Object                                                                                                                                                        
Function        Stop-VM                                                                                                                                                              
Cmdlet          Get-VM                                             2.0.0.0    Hyper-V                                                                                                
Cmdlet          Restart-VM                                         2.0.0.0    Hyper-V                                                                                                
Cmdlet          Start-VM                                           2.0.0.0    Hyper-V                                                                                                
```
Oprócz domyślnych poleceń dla sesji mamy jeszcze polecenia zdefiniowane w pliku roli.

Sprawdźmy jakie mamy maszyny wirtualne:
```powershell
[sea-svr1]: PS> Get-VM

Name     State CPUUsage(%) MemoryAssigned(M) Uptime   Status             Version
----     ----- ----------- ----------------- ------   ------             -------
TEST-VM1 Off   0           0                 00:00:00 Operating normally 10.0   
VM1      Off   0           0                 00:00:00 Operating normally 10.0   
```
Uruchamiamy TEST-VM1:
```powershell
[sea-svr1]: PS> Start-VM -Name TEST-VM1

[sea-svr1]: PS> Get-VM

Name     State   CPUUsage(%) MemoryAssigned(M) Uptime           Status             Version
----     -----   ----------- ----------------- ------           ------             -------
TEST-VM1 Running 0           1024              00:00:12.9810000 Operating normally 10.0   
VM1      Off     0           0                 00:00:00         Operating normally 10.0   
```
Stopujemy TEST-VM1:
```POWERSHELL
[sea-svr1]: PS> Stop-VM -Name TEST-VM1

[sea-svr1]: PS> Get-VM

Name     State CPUUsage(%) MemoryAssigned(M) Uptime   Status             Version
----     ----- ----------- ----------------- ------   ------             -------
TEST-VM1 Off   0           0                 00:00:00 Operating normally 10.0   
VM1      Off   0           0                 00:00:00 Operating normally 10.0   
```
Startujemy VM1:
```powershell
[sea-svr1]: PS> Start-VM -Name VM1

[sea-svr1]: PS> Get-VM

Name     State   CPUUsage(%) MemoryAssigned(M) Uptime           Status             Version
----     -----   ----------- ----------------- ------           ------             -------
TEST-VM1 Off     0           0                 00:00:00         Operating normally 10.0   
VM1      Running 50          1024              00:00:06.4100000 Operating normally 10.0   
```
Stopujemy VM1:
```powershell
[sea-svr1]: PS> Stop-VM -Name VM1
Cannot validate argument on parameter 'Name'. The argument "VM1" does not match the "^(TEST-[a-zA-Z0-9_\-]*)$" pattern. Supply an argument that matches "^(TEST-[a-zA-Z0-9_\-]*)$" 
and try the command again.
    + CategoryInfo          : InvalidData: (:) [Stop-VM], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Stop-VM
```
Jak widać nie możemy zatrzymać maszyny której nazwa nie pasuje do podanego wzorca.

Sprawdzamy czy możemy wykonać inne nie zdefiniowane polecenie cmdlet:
```powershell
[sea-svr1]: PS> Get-Process
The term 'Get-Process' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that 
the path is correct and try again.
    + CategoryInfo          : ObjectNotFound: (Get-Process:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException
```
Zamykamy sesje:
```powershell
[sea-svr1]: PS> Exit-PSSession

PS C:\Users\Administrator> 
```
