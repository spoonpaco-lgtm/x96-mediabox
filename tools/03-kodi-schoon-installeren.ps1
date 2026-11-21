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

# --- NAS-mappen invullen -----------------------------------------------------
Write-Host ""
Write-Host "NAS NasZonnehof (192.168.178.2)"
$films  = Read-Host "Naam van de gedeelde map met FILMS (bijv. video of Films)"
$series = Read-Host "Naam van de gedeelde map met SERIES (leeg laten als die er niet is)"
$proto  = Read-Host "Protocol: typ NFS (aanbevolen, moet aan staan op de NAS) of SMB"
$proto  = $proto.ToUpper()

$tmp = Join-Path $env:TEMP "x96-sources.xml"
$xml = Get-Content (Join-Path $cfg "sources.xml") -Raw
if ($proto -eq "SMB") {
    $xml = $xml -replace "nfs://192\.168\.178\.2/volume1/", "smb://192.168.178.2/"
}
$xml = $xml -replace "FILMS_MAP", $films
if ([string]::IsNullOrWhiteSpace($series)) {
    $xml = [regex]::Replace($xml, "(?s)\s*<source>\s*<name>NAS Series</name>.*?</source>", "")
} else {
    $xml = $xml -replace "SERIES_MAP", $series
}
Set-Content -Path $tmp -Value $xml -Encoding UTF8

# --- Bevestigen ---------------------------------------------------------------
Write-Host ""
Write-Host "Dit gaat er gebeuren:" -ForegroundColor Yellow
Write-Host "  1. Kodi wordt GEWIST (build, wizards, add-ons, instellingen, kijkgeschiedenis)"
Write-Host "  2. Kodi start 1x leeg op en wordt weer gesloten"
Write-Host "  3. Nieuwe instellingen, app-snelkoppelingen, IPTV-lijsten en repo-zips worden neergezet"
Write-Host "  Backup aanwezig: $($backups[-1].FullName)"
Confirm-Ja "Kodi schoon installeren?"

Adb-Shell "am force-stop org.xbmc.kodi"
Write-Host "Kodi wissen: $(Adb-Shell 'pm clear org.xbmc.kodi')"

Write-Host "Kodi 1x opstarten om de mappen aan te maken (40 s)..."
Adb-Shell "monkey -p org.xbmc.kodi -c android.intent.category.LAUNCHER 1" | Out-Null
Start-Sleep -Seconds 40
Adb-Shell "am force-stop org.xbmc.kodi"

$ud = "$KODI_DATA/userdata"
& $ADB -s $BOX push $tmp "$ud/sources.xml"
& $ADB -s $BOX push (Join-Path $cfg "advancedsettings.xml") "$ud/advancedsettings.xml"
& $ADB -s $BOX push (Join-Path $cfg "favourites.xml") "$ud/favourites.xml"
Adb-Shell "mkdir -p $ud/addon_data/pvr.iptvsimple"
& $ADB -s $BOX push (Join-Path $cfg "addon_data\pvr.iptvsimple\instance-settings-1.xml") "$ud/addon_data/pvr.iptvsimple/instance-settings-1.xml"
& $ADB -s $BOX push (Join-Path $cfg "addon_data\pvr.iptvsimple\instance-settings-2.xml") "$ud/addon_data/pvr.iptvsimple/instance-settings-2.xml"

Adb-Shell "mkdir -p /sdcard/x96-setup"
if (Test-Path $zips) {
    Get-ChildItem $zips -Filter *.zip | ForEach-Object { & $ADB -s $BOX push $_.FullName "/sdcard/x96-setup/$($_.Name)" }
}

Write-Host ""
Write-Host "Klaar. Volg nu docs\KODI-HANDLEIDING.md vanaf stap 1 op de projector." -ForegroundColor Green
Read-Host "Enter om af te sluiten"
