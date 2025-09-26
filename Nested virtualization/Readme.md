## Wirtualizacja zagnieżdżona — instrukcja konfiguracji

Ten README został przygotowany na podstawie skryptu `Nested_virtualization.ps1` i zawiera: cel, wymagania, kroki konfiguracji, najczęstsze problemy i wskazówki oraz bezpieczeństwo i dobre praktyki.

## Cel
Włączyć i skonfigurować wirtualizację zagnieżdżoną (nested virtualization) tak, aby w maszynie wirtualnej działającej na hoście Hyper‑V można było uruchomić kolejną warstwę Hyper‑V i tworzyć „maszyny zagnieżdżone”.

## Wymagania
- Host Hyper‑V z systemem Windows Server 2016 lub nowszym (Windows Server) albo Windows 10/11 dla środowisk klienckich.
- Maszyna wirtualna (VM) musi być wyłączona przed zmianą ustawień procesora.
- Procesor fizyczny z obsługą wirtualizacji (Intel VT‑x z EPT lub AMD SVM/NP with RVI/Swift Page/SLAT equivalents). Dla AMD zalecane nowsze modele EPYC/Ryzen.
- Dla pełnej funkcjonalności sieciowej zalecane odpowiednio skonfigurowane przełączniki wirtualne oraz wsparcie dla MacAddress spoofing / alternatywnie translacja adresów sieciowych.
- Wersja konfiguracji maszyny wirtualnej odpowiednia dla funkcji (np. 8.0+ dla niektórych funkcji Intela; sprawdź dokumentację Microsoft dla konkretnej wersji Hyper‑V i systemu).

## Kroki konfiguracji
Poniżej znajdziesz minimalny zestaw poleceń, które wykonuje `Nested_virtualization.ps1`. Zakładają, że nazwa maszyny wirtualnej to `SEA-SVR2` — zamień ją na swoją.

1) Sprawdź status maszyny wirtualnej (maszyna powinna być wyłączona):

```powershell
Get-VM -Name SEA-SVR2
```

Przykładowe wyjście:

```text
Name     State CPUUsage(%) MemoryAssigned(M) Uptime   Status           Version
----     ----- ----------- ----------------- ------   ------           -------
SEA-SVR2 Off   0           0                 00:00:00 Działa normalnie 11.0
```

2) Włącz wystawianie rozszerzeń wirtualizacyjnych na procesorze VM (Expose virtualization extensions):

```powershell
Set-VMProcessor -VMName SEA-SVR2 -ExposeVirtualizationExtensions $true

# Sprawdzenie
Get-VMProcessor -VMName SEA-SVR2 | Select-Object -Property ExposeVirtualizationExtensions
```

Przykładowe potwierdzenie:

```text
ExposeVirtualizationExtensions
------------------------------
                                                    True
```

3) Skonfiguruj adapter sieciowy VM, aby umożliwić zagnieżdżonym VM komunikację sieciową (przykład: włączenie MacAddressSpoofing):

```powershell
Get-VMNetworkAdapter -VMName SEA-SVR2 | Set-VMNetworkAdapter -MacAddressSpoofing On

# Sprawdzenie
Get-VMNetworkAdapter -VMName SEA-SVR2 | Select-Object -Property MacAddressSpoofing
```

Przykładowe wyjście:

```text
MacAddressSpoofing
------------------
                                On
```

Uwaga: alternatywnie można zastosować translację adresów sieciowych (NAT) lub inny sposób udostępnienia sieci zagnieżdżonym VM w zależności od topologii.

4) Uruchom VM i w jej wnętrzu zainstaluj rolę Hyper‑V (jeśli to ma być host dla kolejnej warstwy VM). Po stronie gościa sprawdź, czy przypisane są rozszerzenia wirtualizacyjne i czy można tworzyć maszyny wirtualne.

## Najczęstsze problemy i wskazówki
- Maszyna nie uruchamia zagnieżdżonego Hyper‑V:
    - Upewnij się, że VM była wyłączona przed zastosowaniem `Set-VMProcessor`.
    - Sprawdź, czy CPU hosta obsługuje wymagane funkcje wirtualizacji (VT‑x/EPT lub AMD‑equivalent).
    - Sprawdź wersję konfiguracji VM i zgodność z funkcjonalnościami Hyper‑V.

- Brak łączności sieciowej z zagnieżdżonymi VM:
    - Jeśli używasz standardowych wirtualnych przełączników, pamiętaj o odpowiednim przepuszczaniu ruchu (np. włączenie MacAddressSpoofing lub zastosowanie NAT/bridge za pomocą dwóch przełączników).
    - Sprawdź reguły bezpieczeństwa/ACL na hoście, VLANy i zasady sieciowe w virtual switch.

- Problemy ze zgodnością sterowników/feature'ów:
    - Nie wszystkie funkcje sprzętowe są automatycznie widoczne wewnątrz zagnieżdżonego środowiska (np. SR‑IOV może wymagać dodatkowej konfiguracji).

- Wydajność:
    - Zagnieżdżona wirtualizacja zwiększa narzut CPU i pamięci. Przydzielając zasoby VM, uwzględnij potrzebę dodatkowych zasobów dla drugiej warstwy.
    - Monitoruj użycie CPU, pamięci i I/O. Testuj obciążenie przed uruchomieniem produkcyjnych usług.

## Bezpieczeństwo i dobre praktyki
- Testuj zagnieżdżoną konfigurację w środowisku testowym przed wdrożeniem na produkcję.
- Ogranicz dostęp do hostów i maszyn zagnieżdżonych odpowiednimi regułami RBAC i politykami sieciowymi.
- Zadbaj o aktualizacje systemu i hypervisorów zarówno na hoście, jak i w VM‑ach.
- Nie przypisuj niepotrzebnych uprawnień administracyjnych zagnieżdżonym VM; stosuj zasadę najmniejszych przywilejów.
- Jeśli planujesz uruchamiać intensywne obciążenia, rozważ uruchomienie bezpośrednio na hoście zamiast zagnieżdżonej warstwy — zagnieżdżenie zwykle ma gorszą wydajność.

## Dodatkowe uwagi i porady
- Sprawdź dokumentację Microsoft dotyczącą wersji konfiguracji maszyn wirtualnych i zgodności CPU dla konkretnej wersji Windows Server/Hyper‑V.
- Dla automatów i powtarzalnych konfiguracji rozważ użycie skryptów (PowerShell DSC/Desired State Configuration, ARM/Bicep, czy Terraform z Hyper‑V providerami) do skonfigurowania i testów.
---