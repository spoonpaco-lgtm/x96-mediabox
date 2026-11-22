# X96 Mediabox

Maakt van de X96 Max+ Ultra (Android 11, Amlogic S905X4) een veilige, snelle mediabox voor de projector:
Kodi met Elementum, Burst en Trakt, een Netflix-achtige skin, films van de NAS, gratis IPTV, VLC, YouTube,
en een eigen Netflix-stijl startscherm.

## Wat zit erin

| Map | Wat |
| --- | --- |
| `kodi/userdata` | Kodi-instellingen: NAS-bronnen, buffer voor 4K, twee IPTV-lijsten |
| `kodi/zips` | Repository-zips (Elementum, jurialmunkey-skins), gevuld door de GitHub-build |
| `launcher` | **X96 Launcher**: start Kodi bij opstarten en op de Home-knop; na Kodi afsluiten een Netflix-stijl appscherm als vangnet |
| `START.bat` | Menu dat alle stappen in de goede volgorde start |
| `tools` | De PowerShell-scripts achter het menu |
| `docs/KODI-HANDLEIDING.md` | De klikstappen in Kodi zelf (add-ons, skin, Trakt) |

## Gebruik

1. Download de nieuwste release (`x96-mediabox-<versie>.zip`) en pak hem uit, bijvoorbeeld in `F:\Project android TV\x96-mediabox`.
2. Dubbelklik **`START.bat`** en doe de stappen in de volgorde van het menu:

| Menu | Doet | Terug te draaien |
| --- | --- | --- |
| 1 | Backup van de huidige Kodi naar F: | n.v.t. |
| 2 | Rommel uitschakelen, animaties 0,5x | menu 7 |
| 3 | Kodi wissen + X96-configuratie | menu 8 (backup terugzetten) |
| 4 | X96 Launcher: Kodi start bij opstarten en op Home | Commando staat in het script |
| 5 | Root over wifi uit (als alles werkt) | `local.prop` opnieuw zetten |
| 6 | Automatisch verbinden + Kodi-rechten vanzelf herstellen (Windows-taak, elke 2 min) | menu 6 → `UIT` |
| 9 | Kodi-rechten handmatig herstellen (niet nodig als 6 aan staat) | n.v.t. |

3. Volg daarna `docs/KODI-HANDLEIDING.md` op de projector.

Elke stap die iets verandert, vraagt eerst om `JA`. Stap 4 pas na stap 3: anders opent de launcher de oude Kodi-build.

## Netwerk

| Apparaat | Adres |
| --- | --- |
| Box | 192.168.178.167 (ADB 5555), vast adres in de Ziggo-modem (wifi-MAC a4:6b:40:61:2d:4e) |
| NAS NasZonnehof (DS213, DSM 6.2) | 192.168.178.2; NFS alleen-lezen voor de box op films, series, kinderfilms, Comedy shows |

## Let op

- Firmware krijgt geen updates meer (securitypatch 2021-10). Opruimen helpt, maar de box blijft verouderd.
- Elementum streamt via torrents en uploadt dus ook. Downloaden uit illegale bron is in Nederland verboden.
- Casten: YouTube via tv-code in de YouTube-app. Echte Chromecast built-in kan niet op deze box.
