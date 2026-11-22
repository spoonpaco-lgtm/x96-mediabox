# Stap 3-5: Kodi SCHOON maken en de X96-configuratie erop zetten.
#  - wist de huidige Kodi-build (Diggz Chef 21, wizards, alle instellingen)
#  - zet sources (NAS, repo-zips), buffer-instellingen en IPTV-lijsten neer
# Eerst 01-backup-kodi.ps1 draaien!
. "$PSScriptRoot\_config.ps1"
Connect-Box

$cfg  = Join-Path $REPO_ROOT "kodi\userdata"
$zips = Join-Path $REPO_ROOT "kodi\zips"
if (-not (Test-Path $cfg)) { Write-Host "kodi\userdata niet gevonden naast deze map." -ForegroundColor Red; Read-Host; exit 1 }

$backups = Get-ChildItem $BACKUP_ROOT -Directory -Filter "kodi-backup-*" -ErrorAction SilentlyContinue
if (-not $backups) {
    Write-Host "Er is nog geen Kodi-backup gevonden in $BACKUP_ROOT. Draai eerst 01-backup-kodi.ps1." -ForegroundColor Red
    Read-Host "Enter"; exit 1
}

# --- NAS -----------------------------------------------------------------------
# Films, Series, Kinderfilms en Comedy shows staan vast in kodi\userdata\sources.xml (NFS, alleen-lezen).
$tmp = Join-Path $cfg "sources.xml"

# --- Bevestigen ---------------------------------------------------------------
Write-Host ""
Write-Host "Dit gaat er gebeuren:" -ForegroundColor Yellow
Write-Host "  1. Kodi wordt GEWIST (build, wizards, add-ons, instellingen, kijkgeschiedenis)"
Write-Host "  2. Kodi start 1x leeg op en wordt weer gesloten"
Write-Host "  3. Nieuwe instellingen, app-snelkoppelingen en repo-zips worden neergezet"
Write-Host "  Backup aanwezig: $($backups[-1].FullName)"
Confirm-Ja "Kodi schoon installeren?"

Adb-Shell "am force-stop org.xbmc.kodi"
Write-Host "Kodi wissen: $(Adb-Shell 'pm clear org.xbmc.kodi')"

# Controle: is de oude Kodi-map (met de Diggz-build) echt weg?
$left = (Adb-Shell "ls -d $KODI_DATA 2>/dev/null" | Out-String).Trim()
if ($left) {
    Write-Host "De oude Kodi-map staat er nog; die wordt nu verwijderd (backup staat op F:)."
    Adb-Shell "rm -rf $KODI_DATA"
}
$left = (Adb-Shell "ls -d $KODI_DATA 2>/dev/null" | Out-String).Trim()
if ($left) {
    Write-Host "!!! De oude Kodi-map kon niet worden verwijderd. Gestopt; er is nog niets nieuws neergezet." -ForegroundColor Red
    Read-Host "Enter"; exit 1
}
Write-Host "Oude Kodi-build is weg." -ForegroundColor Green

# Kodi 1x leeg opstarten en wachten tot hij echt klaar is:
# het logbestand moet 15 seconden niet meer groeien (maximaal 3 minuten wachten).
Write-Host -NoNewline "Kodi 1x opstarten en wachten tot hij klaar is"
Adb-Shell "monkey -p org.xbmc.kodi -c android.intent.category.LAUNCHER 1" | Out-Null
$log = "$KODI_DATA/temp/kodi.log"
$deadline = (Get-Date).AddSeconds(180)
$prev = -1; $stable = 0; $ready = $false
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 5
    Write-Host -NoNewline "."
    $size = (Adb-Shell "stat -c %s $log 2>/dev/null" | Out-String).Trim()
    if ($size -notmatch '^\d+$') { continue }
    if ([int64]$size -eq $prev) { $stable += 5 } else { $stable = 0; $prev = [int64]$size }
    if ($stable -ge 15) { $ready = $true; break }
}
Write-Host ""
if (-not $ready) {
    Write-Host "!!! Kodi was na 3 minuten nog niet klaar. Start Kodi zelf 1x, wacht op het beginscherm," -ForegroundColor Red
    Write-Host "    en draai dit script daarna opnieuw." -ForegroundColor Red
    Read-Host "Enter"; exit 1
}
Adb-Shell "am force-stop org.xbmc.kodi"
Write-Host "Kodi is klaar en weer gesloten." -ForegroundColor Green

$ud = "$KODI_DATA/userdata"
& $ADB -s $BOX push $tmp "$ud/sources.xml"
& $ADB -s $BOX push (Join-Path $cfg "advancedsettings.xml") "$ud/advancedsettings.xml"
& $ADB -s $BOX push (Join-Path $cfg "favourites.xml") "$ud/favourites.xml"
# TMDb Helper: player die titels via Elementum afspeelt (zonder dit gebeurt er niets bij afspelen)
Adb-Shell "mkdir -p $ud/addon_data/plugin.video.themoviedb.helper/players"
& $ADB -s $BOX push (Join-Path $cfg "addon_data\plugin.video.themoviedb.helper\players\elementum.json") "$ud/addon_data/plugin.video.themoviedb.helper/players/elementum.json"
# Bestanden aan Kodi zelf geven (adb draait als root, anders kan Kodi ze niet aanpassen)
$lower = "/data/media/0/Android/data/org.xbmc.kodi/files/.kodi/userdata"
$owner = (Adb-Shell "stat -c %U:%G $lower/guisettings.xml" | Out-String).Trim()
foreach ($f in @("sources.xml", "advancedsettings.xml", "favourites.xml")) {
    Adb-Shell "chown $owner $lower/$f"
    Adb-Shell "chmod 660 $lower/$f"
}

Adb-Shell "mkdir -p /sdcard/x96-setup"
if (Test-Path $zips) {
    Get-ChildItem $zips -Filter *.zip | ForEach-Object { & $ADB -s $BOX push $_.FullName "/sdcard/x96-setup/$($_.Name)" }
}

Write-Host ""
Write-Host "Klaar. Volg nu docs\KODI-HANDLEIDING.md vanaf stap 1 op de projector." -ForegroundColor Green
Read-Host "Enter om af te sluiten"
