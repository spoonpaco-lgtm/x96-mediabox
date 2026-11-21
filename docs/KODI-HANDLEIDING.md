# Kodi inrichten op de projector

**Kodi is het startscherm.** Box aan en de Home-knop openen Kodi. Kodi afsluiten (menu → Afsluiten)
brengt je in de X96 Launcher: daar staan alle apps en de schakelaar "Kodi bij opstarten".

Na `tools/03-kodi-schoon-installeren.ps1` staat Kodi leeg, maar met de NAS, de buffer-instellingen,
de IPTV-lijsten en de repo-zips al klaar. Add-ons installeren kan alleen vanuit Kodi zelf (Kodi
vraagt dan zelf om afhankelijkheden), dus deze stappen doe je met de afstandsbediening. Reken op 15 minuten.

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

## 4b. Rij met apps op het beginscherm
De apps staan al klaar als Kodi-favorieten (SmartTube, Prime Video, VLC, Chrome, Bestanden,
Android-instellingen, X96 Launcher). Zet ze als rij op het beginscherm:
Instellingen → Skin-instellingen → **Beginscherm aanpassen** (Customise home) → bij een menu-item of
widget-rij **Favorieten** kiezen. De precieze naam van het menu verschilt per skin; het staat onder de
instellingen van Arctic Fuse 2 / Arctic Horizon 2.

## 5. Trakt
Trakt houdt bij wat je kijkt en vult "Verder kijken" en je watchlist.
1. Add-ons → Installeren vanuit repository → **Kodi Add-on repository** → Programma-add-ons → **Trakt** → Installeren.
2. Open Trakt: er verschijnt een code. Ga op je telefoon naar **trakt.tv/activate** en voer de code in.
3. Elementum → Instellingen → **Tracking** → Trakt kiezen → autoriseren (zelfde manier).
4. TMDb Helper → Instellingen → Trakt → autoriseren. Dan tonen de skin-rijen je Trakt-lijsten.

## 6. IPTV
Add-ons → Installeren vanuit repository → Kodi Add-on repository → PVR-clients → **PVR IPTV Simple Client** →
Installeren. De twee lijsten (iptv-org NL en Free-TV) staan al klaar; Kodi laadt ze na een herstart.
Niets te zien? Open de add-on → Configureren: er moeten twee instanties staan.

## 7. NAS-films
Video's → Bestanden → **NAS Films** → (menu/lang indrukken) → **Inhoud wijzigen** → Films →
The Movie Database → OK → Ja (bibliotheek scannen). Herhaal met **NAS Series** → Tv-series.
Bij SMB vraagt Kodi eenmalig om gebruikersnaam en wachtwoord van de Kodi-gebruiker op de NAS.

## 8. Beeld op de projector
Instellingen → Speler → Video's:
- **Verversingsfrequentie aanpassen: bij starten/stoppen** (geen haperend beeld bij 24 fps-films).
- Wachttijd bij wijzigen verversingsfrequentie: 1 seconde (tegen een zwart beeld bij het omschakelen).

Instellingen → Systeem → Audio: **Passthrough aan** als er een receiver of soundbar aan hangt.
