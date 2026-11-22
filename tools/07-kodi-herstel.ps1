# Herstel: geeft alle Kodi-bestanden terug aan Kodi zelf.
# Bestanden die via adb (als root) zijn neergezet, kan Kodi anders wel lezen maar niet aanpassen.
# Haalt ook nog door root neergezette IPTV-instellingen weg (die lieten Kodi 0.3.1 crashen).
. "$PSScriptRoot\_config.ps1"
Connect-Box

$lower = "/data/media/0/Android/data/org.xbmc.kodi/files/.kodi"
Confirm-Ja "Rechten van de Kodi-bestanden herstellen?"

Adb-Shell "am force-stop org.xbmc.kodi"
$owner = (Adb-Shell "stat -c %U:%G $lower/userdata/guisettings.xml" | Out-String).Trim()
Write-Host "Kodi-eigenaar: $owner"
Adb-Shell "chown -R $owner $lower/userdata"
Adb-Shell "chmod -R ug+rw $lower/userdata"

$left = (Adb-Shell "find $lower/userdata -user root 2>/dev/null | head -5" | Out-String).Trim()
if ($left) { Write-Host "Nog van root:`n$left" -ForegroundColor Red } else { Write-Host "Alle Kodi-bestanden zijn weer van Kodi." -ForegroundColor Green }
Write-Host ""
Write-Host "Klaar. Start Kodi." -ForegroundColor Green
Read-Host "Enter om af te sluiten"
