# Stap 0: complete backup van de huidige Kodi (userdata + addons) naar F:.
# Verandert niets op de box.
. "$PSScriptRoot\_config.ps1"
Connect-Box

$stamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$dest  = Join-Path $BACKUP_ROOT "kodi-backup-$stamp"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

Write-Host "Kodi-map kopieren naar $dest (kan een paar minuten duren)..."
& $ADB -s $BOX pull "$KODI_DATA" "$dest"
Write-Host ""
Write-Host "Klaar: $dest" -ForegroundColor Green
Read-Host "Enter om af te sluiten"
