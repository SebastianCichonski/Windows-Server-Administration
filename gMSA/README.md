# gMSA — konfiguracja konta grupowego Managed Service Account (gMSA)

Ten plik dokumentuje kroki użyte w skrypcie `gMSA.ps1` do utworzenia i zainstalowania grupowego konta zarządzanego (gMSA) w środowisku Active Directory. Znajdziesz tu cel, wymagania, kroki konfiguracji (z użytymi poleceniami PowerShell), oraz wskazówki dotyczące problemów, bezpieczeństwa i najlepszych praktyk.

## Cel
Utworzyć konto gMSA dla klastra/rol aplikacji (w przykładzie: SQLFarm) tak, aby wiele serwerów mogło używać jednego zarządzanego konta usługi bez konieczności ręcznego zarządzania hasłami.

## Wymagania
- Kontroler domeny z rolą Active Directory Domain Services.
- Konto użytkownika z uprawnieniami do tworzenia klucza KDS (np. Domain Admin) oraz do tworzenia obiektów w AD (grupy i konta usługi).
- Wszystkie hosty, które będą używać gMSA, powinny być w tej samej domenie i mieć poprawną synchronizację czasu (Kerberos jest czuły na różnice czasu).
- PowerShell z modułem ActiveDirectory dostępny na kontrolerze domeny i na serwerach docelowych (RSAT/AD PowerShell lub funkcja serwera).

## Kroki konfiguracji (polecenia z `gMSA.ps1`)
Poniżej lista kroków wykonanych w skrypcie. Uruchamiaj polecenia z uprawnieniami administracyjnymi (na kontrolerze domeny tam gdzie to potrzebne).

1. Generowanie (lub odświeżenie) KDS root key na kontrolerze domeny

```powershell
# Generowanie klucza głównego usługi KDS z pominięciem czasu propagacji (przykład: -10 godzin)
Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))

# Potwierdzenie: w dzienniku KdsSvc (event id 4004)
Get-WinEvent -LogName Microsoft-Windows-KdsSvc/Operational | Where-Object -Property id -EQ 4004
```

Wyjaśnienie: KDS root key jest używany do generowania haseł dla kont gMSA. Po utworzeniu klucz propaguje się w domenie (może to zająć czas). Parametr `-EffectiveTime` ustawiony wstecz pozwala natychmiast używać klucza (bez czekania na naturalną propagację), zalecane tylko w środowiskach testowych.

2. Utworzenie grupy komputerów, które będą miały prawo pobierać hasło gMSA

```powershell
# Tworzenie grupy bezpieczeństwa w AD
New-ADGroup -Name "SQLFarm" -SamAccountName "SQLFarm" -GroupCategory Security -GroupScope Global -Path "CN=Computers,DC=azseblab,DC=com"

# Sprawdzenie grupy
Get-ADGroup -Identity "SQLFarm"
```

3. Dodanie serwerów/komputerów do grupy

```powershell
# Dodaj wszystkie komputery pasujące do wzorca
Get-ADComputer -Filter 'Name -like "svr-sql*"' | Add-ADPrincipalGroupMembership -MemberOf SQLFarm

# Sprawdzenie członków grupy
Get-ADGroupMember -Identity SQLFarm | Select-Object -Property Name
```

4. Utworzenie konta gMSA w AD

```powershell
New-ADServiceAccount -Name SQLFarm_gMSA -DNSHostName SQLFarm_gSMA.azseblab.com -PrincipalsAllowedToRetrieveManagedPassword SQLFarm

# Weryfikacja konta
Get-ADServiceAccount -Identity SQLFarm_gMSA
```

Wyjaśnienie: parametr `-PrincipalsAllowedToRetrieveManagedPassword` przyjmuje grupę (lub listę komputerów), które są uprawnione do uzyskania zarządzanego hasła.

5. Przygotowanie i instalacja gMSA na serwerze docelowym

Na serwerze, który będzie używał gMSA wykonaj:

```powershell
# Zainstaluj RSAT/AD PowerShell (jeżeli brak)
Add-WindowsFeature rsat-ad-powershell
Import-Module ActiveDirectory

# Zainstaluj konto gMSA lokalnie (spowoduje, że system będzie mógł używać konta gMSA)
Install-ADServiceAccount -Identity SQLFarm_gMSA
```

Po instalacji możesz testować logowanie/usługę, konfigurując usługę Windows do logowania przy użyciu konta `DOMAIN\SQLFarm_gMSA$` (użyj formatu nazwy konta maszynowego i pustego hasła — system pobierze hasło automatycznie).

## Typowe problemy i wskazówki diagnostyczne
- Problem: "Nie można pobrać hasła gMSA" — możliwe przyczyny:
  - KDS root key nie został poprawnie utworzony lub nie miała czasu na propagację.
  - Serwer nie jest w tej samej domenie lub ma problemy z DNS.
  - Komputer nie jest członkiem grupy wskazanej w `-PrincipalsAllowedToRetrieveManagedPassword`.
  - Różnice czasu (synchronizacja czasu) powodują problemy Kerberos.

- Weryfikacja i debug:
  - Sprawdź wpisy w dzienniku operacyjnym KdsSvc (event id 4004) po `Add-KdsRootKey`.
  - Upewnij się, że `Get-ADServiceAccount -Identity SQLFarm_gMSA` zwraca obiekt.
  - Na hoście docelowym uruchom `Test-ADServiceAccount -Identity SQLFarm_gMSA` (PowerShell) aby sprawdzić, czy konto jest gotowe do użytku.
  - Sprawdź członkostwo w grupie: `Get-ADGroupMember -Identity SQLFarm`.

## Bezpieczeństwo i dobre praktyki
- Ogranicz liczbę komputerów uprawnionych do pobierania hasła gMSA — używaj grup z precyzyjnym zakresem.
- Używaj oddzielnych gMSA dla różnych ról (np. bazy danych, usług sieciowych) zamiast jednego globalnego konta dla wielu ról.
- KDS root key: generuj świadomie i dokumentuj jego utworzenie. Nie generuj root key częściej niż to konieczne.
- Audyt i monitoring: monitoruj logi KdsSvc i zdarzenia związane z ADServiceAccount.
- Uprawnienia: tworzenie/uprawnienia do gMSA powinny być nadawane tylko administratorom lub zautomatyzowanym procesom CI/CD z ograniczonym dostępem.
- Sieć i Kerberos: zapewnij stabilną synchronizację czasu (NTP), poprawną konfigurację DNS i dostęp do kontrolerów domeny.

## Dodatkowe uwagi
- Jeśli chcesz używać gMSA w środowiskach mieszanych (workgroup lub między lasami), wymagane są dodatkowe kroki (trusty, ACL, itp.).
- gMSA nie są przeznaczone do interaktywnego logowania — są przeznaczone dla usług i zadań systemowych.

