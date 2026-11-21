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
| `tools` | PowerShell-scripts die je op de pc draait, stap voor stap |
| `docs/KODI-HANDLEIDING.md` | De klikstappen in Kodi zelf (add-ons, skin, Trakt) |

## Gebruik

1. Download de nieuwste release (`x96-mediabox-<versie>.zip`) en pak hem uit, bijvoorbeeld in `F:\Project android TV\x96-mediabox`.
2. Draai in die map, in deze volgorde (rechtermuisknop → *Uitvoeren met PowerShell*):

| Script | Doet | Terug te draaien |
| --- | --- | --- |
| `tools\01-backup-kodi.ps1` | Backup van de huidige Kodi naar F: | n.v.t. |
| `tools\02-opruimen.ps1` | Rommel uitschakelen, animaties 0,5x | `02-opruimen-terug.ps1` |
| `tools\03-kodi-schoon-installeren.ps1` | Kodi wissen + nieuwe configuratie | Backup terugzetten |
| `tools\04-launcher-installeren.ps1` | X96 Launcher als startscherm | Commando staat in het script |
| `tools\05-root-uit.ps1` | Root over wifi uit (als alles klaar is) | `local.prop` opnieuw zetten |

3. Volg daarna `docs/KODI-HANDLEIDING.md` op de projector.

Elk script vraagt eerst om `JA` voordat het iets verandert.

## Netwerk

| Apparaat | Adres |
| --- | --- |
| Box | 192.168.178.167 (ADB 5555) |
| NAS NasZonnehof | 192.168.178.2 |

## Let op

- Firmware krijgt geen updates meer (securitypatch 2021-10). Opruimen helpt, maar de box blijft verouderd.
- Elementum streamt via torrents en uploadt dus ook. Downloaden uit illegale bron is in Nederland verboden.
- Casten: YouTube via tv-code; andere apps via AirScreen. Echte Chromecast built-in kan niet op deze box.
