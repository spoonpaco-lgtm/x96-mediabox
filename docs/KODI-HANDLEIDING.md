# Kodi inrichten op de projector

**Kodi is het startscherm.** Box aan en de Home-knop openen Kodi. Kodi afsluiten (menu → Afsluiten)
brengt je in de X96 Launcher: daar staan alle apps en de schakelaar "Kodi bij opstarten".

Na `tools/03-kodi-schoon-installeren.ps1` staat Kodi leeg, maar met de NAS, de buffer-instellingen,
de IPTV-lijsten en de repo-zips al klaar. Add-ons installeren kan alleen vanuit Kodi zelf (Kodi
vraagt dan zelf om afhankelijkheden), dus deze stappen doe je met de afstandsbediening. Reken op 15 minuten.

## 0. Kodi niet vanzelf laten bijwerken
Kodi komt uit de Play Store. Een grote update (bijv. naar Kodi 22) kan Elementum of de skin breken.
Play Store → zoek **Kodi** → open de app-pagina → menu (drie puntjes) → **Automatisch updaten uit**.
Bijwerken doe je later zelf, als je weet dat alles werkt.

## 1. Onbekende bronnen toestaan
Instellingen → Systeem → Add-ons → **Onbekende bronnen: aan** → Ja.

## 2. Repositories installeren
Add-ons → Installeren via zip-bestand → **X96 setup** →
1. `repository.elementumorg-*.zip`
2. `repository.jurialmunkey-*.zip`

Wacht telkens op de melding "Add-on geïnstalleerd".

## 3. Elementum + Burst
Add-ons → Installeren vanuit repository → **ElementumOrg repository**
1. Video-add-ons → **Elementum** → Installeren.
2. Kodi vraagt om Burst te installeren → **Ja**. Geen vraag? Programma-add-ons → **Elementum Burst** → Installeren.
3. Bij de eerste start: Instellingen → Services → Bediening → beide "Toepassingsbediening"-opties **aan**, Kodi herstarten.

## 4. Netflix-achtige skin
Add-ons → Installeren vanuit repository → **jurialmunkey** → Uiterlijk → Skin:
- **Arctic Fuse 2**: het meest Netflix: grote achtergrond, rijen per categorie, trailers.
- **Arctic Horizon 2**: rustiger en sneller.

Installeer allebei, kies er één bij Instellingen → Interface → Skin, en wissel gerust tot je weet wat beter
voelt op de projector. Beide installeren **TMDb Helper** mee; die vult de rijen.

## 4b. Beginscherm: alleen films en series, apps achter de knop "Apps"
Het beginscherm toont alleen posters van films en series. De apps (YouTube, Prime Video, VLC, Chrome,
Bestanden, Android-instellingen, X96 Launcher) staan klaar als Kodi-favorieten en komen achter één knop.

1. Instellingen → Skin-instellingen → **Beginscherm aanpassen** (Customise home).
2. **Rijen (widgets):** houd alleen rijen met films en series, bijvoorbeeld *Verder kijken*,
   *Recent toegevoegde films*, *Recent toegevoegde afleveringen* en je Trakt-*watchlist*.
   Haal rijen met add-ons, apps of favorieten weg.
3. **Menu:** voeg een menu-item toe (of hernoem een bestaand) naar **Apps** met als actie
   `ActivateWindow(favouritesbrowser)`. Die knop opent het lijstje met alle apps.
4. Haal menu-items weg die je niet gebruikt (bijv. Muziek, Afbeeldingen, Games) voor een rustiger menu.

De precieze namen van de menu's verschillen per skin; het staat onder de instellingen van
Arctic Fuse 2 / Arctic Horizon 2.

## 5. Trakt
Trakt houdt bij wat je kijkt en vult "Verder kijken" en je watchlist. Twee onderdelen houden bij,
elk hun eigen deel, zodat niets dubbel in je geschiedenis komt:
- **Elementum** houdt de Elementum-films en -series bij;
- de **Trakt-add-on** houdt alleen de NAS bij.

1. Add-ons → Installeren vanuit repository → **Kodi Add-on repository** → Programma-add-ons → **Trakt** → Installeren.
2. Open Trakt: er verschijnt een code. Ga op je telefoon naar **trakt.tv/activate** en voer de code in.
3. Trakt → Instellingen → **Uitsluitingen** → **Plug-in-bronnen uitsluiten: aan**. Zo meldt deze add-on
   Elementum niet nog een keer.
4. Elementum → Instellingen → **Tracking** → Trakt kiezen → autoriseren (zelfde manier met een code).
5. TMDb Helper → Instellingen → Trakt → autoriseren. Dan tonen de rijen op het beginscherm je Trakt-lijsten.

## 6. IPTV
Add-ons → Installeren vanuit repository → Kodi Add-on repository → PVR-clients → **PVR IPTV Simple Client** →
Installeren. Open de add-on daarna één keer (Configureren) en sluit hem weer, zodat Kodi zijn eigen
instellingenbestand aanmaakt. Zet dan de lijsten erin:
- **M3U-lijst 1:** `https://iptv-org.github.io/iptv/countries/nl.m3u`
- **M3U-lijst 2 (tweede instantie):** `https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8`

Typen met de afstandsbediening is lastig: laat het weten na het installeren, dan zet Claude de lijsten
in het bestand dat Kodi zelf heeft aangemaakt. (Vooraf klaarzetten liet Kodi crashen in versie 0.3.1.)

## 7. NAS-films en -series
De vier NAS-mappen staan al klaar onder Video's → Bestanden: **Films**, **Series**, **Kinderfilms**
en **Comedy shows**. Per map: (menu/lang indrukken) → **Inhoud wijzigen** →
- Films en Kinderfilms: **Films** → The Movie Database
- Series: **Tv-series** → The Movie Database
- Comedy shows: **Films** (of Tv-series als het afleveringen zijn)

→ OK → Ja (bibliotheek scannen). De eerste scan duurt even; de NAS (DS213) is niet de snelste.

Op de NAS staat per map een NFS-regel: alleen de box (192.168.178.167), alleen-lezen. Kodi kan dus
niets wissen of wijzigen op de NAS.

## 8. Beeld op de projector
Instellingen → Speler → Video's:
- **Verversingsfrequentie aanpassen: bij starten/stoppen** (geen haperend beeld bij 24 fps-films).
- Wachttijd bij wijzigen verversingsfrequentie: 1 seconde (tegen een zwart beeld bij het omschakelen).

Instellingen → Systeem → Audio: **Passthrough aan** als er een receiver of soundbar aan hangt.
