# Herstel na de crash bij het opstarten van Kodi (versie 0.3.x):
#  - haalt de vooraf klaargezette IPTV-instellingen weg (die lieten Kodi crashen)
#  - maakt de door het script neergezette bestanden weer van Kodi zelf (ze waren van root)
. "$PSScriptRoot\_config.ps1"
Connect-Box

$lower = "/data/media/0/Android/data/org.xbmc.kodi/files/.kodi/userdata"
Confirm-Ja "IPTV-instellingen weghalen en de rechten van de Kodi-bestanden herstellen?"

Adb-Shell "am force-stop org.xbmc.kodi"
Adb-Shell "rm -f $KODI_DATA/userdata/addon_data/pvr.iptvsimple/instance-settings-1.xml $KODI_DATA/userdata/addon_data/pvr.iptvsimple/instance-settings-2.xml"

$owner = (Adb-Shell "stat -c %U:%G $lower/guisettings.xml" | Out-String).Trim()
Write-Host "Kodi-eigenaar: $owner"
foreach ($f in @("sources.xml", "advancedsettings.xml", "favourites.xml")) {
    Adb-Shell "chown $owner $lower/$f"
    Adb-Shell "chmod 660 $lower/$f"
}
Adb-Shell "chown -R $owner $lower/addon_data/pvr.iptvsimple"

Write-Host ""
Adb-Shell "ls -l $lower/sources.xml $lower/favourites.xml $lower/advancedsettings.xml"
Write-Host ""
Write-Host "Klaar. Start Kodi; hij zou nu gewoon moeten opstarten." -ForegroundColor Green
Read-Host "Enter om af te sluiten"
