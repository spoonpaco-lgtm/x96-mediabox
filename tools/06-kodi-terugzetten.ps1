# Noodknop: zet een Kodi-backup (gemaakt met 01-backup-kodi.ps1) terug op de box.
. "$PSScriptRoot\_config.ps1"
Connect-Box

$backups = @(Get-ChildItem $BACKUP_ROOT -Directory -Filter "kodi-backup-*" -ErrorAction SilentlyContinue | Sort-Object Name)
if ($backups.Count -eq 0) { Write-Host "Geen Kodi-backup gevonden in $BACKUP_ROOT." -ForegroundColor Red; Read-Host "Enter"; exit 1 }

Write-Host "Beschikbare backups:"
for ($i = 0; $i -lt $backups.Count; $i++) { Write-Host "  [$($i + 1)] $($backups[$i].Name)" }
$keuze = Read-Host "Welk nummer? (Enter = de nieuwste)"
if ([string]::IsNullOrWhiteSpace($keuze)) { $keuze = $backups.Count }
if (-not ($keuze -as [int]) -or [int]$keuze -lt 1 -or [int]$keuze -gt $backups.Count) {
    Write-Host "Ongeldige keuze. Gestopt, er is niets veranderd."; Read-Host "Enter"; exit 1
}
$src = Join-Path $backups[[int]$keuze - 1].FullName ".kodi"
if (-not (Test-Path $src)) { Write-Host "In deze backup zit geen .kodi-map." -ForegroundColor Red; Read-Host "Enter"; exit 1 }

Write-Host ""
Write-Host "De huidige Kodi op de box wordt VERVANGEN door: $src" -ForegroundColor Yellow
Confirm-Ja "Terugzetten?"

Adb-Shell "am force-stop org.xbmc.kodi"
Adb-Shell "rm -rf $KODI_DATA"
Adb-Shell "mkdir -p /sdcard/Android/data/org.xbmc.kodi/files"
Write-Host "Kopieren naar de box (kan een paar minuten duren)..."
& $ADB -s $BOX push $src "/sdcard/Android/data/org.xbmc.kodi/files/"

Write-Host ""
Write-Host "Klaar. Start Kodi op de box; alles staat weer zoals in de backup." -ForegroundColor Green
Read-Host "Enter om af te sluiten"
