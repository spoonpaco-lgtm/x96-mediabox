# Herstel: geeft alle Kodi-bestanden terug aan Kodi zelf.
# Bestanden die via adb (als root) zijn neergezet, kan Kodi anders wel lezen maar niet aanpassen.
. "$PSScriptRoot\_config.ps1"
Connect-Box

$lower = "/data/media/0/Android/data/org.xbmc.kodi/files/.kodi"
Confirm-Ja "Rechten van de Kodi-bestanden herstellen?"

Adb-Shell "am force-stop org.xbmc.kodi"
# Eigenaar overnemen van de addons-map: die maakt Kodi zelf aan en wordt nooit via adb overschreven.
# (Niet van guisettings.xml: als die via adb is neergezet, is die zelf van root.)
$owner = (Adb-Shell "stat -c %u:%g $lower/addons" | Out-String).Trim()
Write-Host "Kodi-eigenaar: $owner"
if (-not $owner -or $owner -like "0:*" -or $owner -notmatch '^\d+:\d+$') {
    Write-Host "!!! Kon de Kodi-eigenaar niet bepalen ($owner). Er is niets veranderd." -ForegroundColor Red
    Read-Host "Enter"; exit 1
}
Adb-Shell "chown -R $owner $lower/userdata"
Adb-Shell "chmod -R ug+rw $lower/userdata"

$left = (Adb-Shell "find $lower/userdata -user root 2>/dev/null | head -5" | Out-String).Trim()
if ($left) { Write-Host "Nog van root:`n$left" -ForegroundColor Red } else { Write-Host "Alle Kodi-bestanden zijn weer van Kodi." -ForegroundColor Green }
Write-Host ""
Write-Host "Klaar. Start Kodi." -ForegroundColor Green
Read-Host "Enter om af te sluiten"
