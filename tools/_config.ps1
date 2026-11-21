# Gedeelde instellingen voor alle X96-scripts.
$ADB   = "C:\Users\dyrth\platform-tools\adb.exe"
$BOX   = "192.168.178.167:5555"
$BACKUP_ROOT = "F:\Project android TV"
$KODI_DATA   = "/sdcard/Android/data/org.xbmc.kodi/files/.kodi"
$REPO_ROOT   = Split-Path -Parent $PSScriptRoot

function Connect-Box {
    & $ADB connect $BOX | Out-Host
    $state = (& $ADB -s $BOX get-state 2>$null)
    if ($state -ne "device") {
        Write-Host "!!! Box niet bereikbaar op $BOX. Staat hij aan en op wifi?" -ForegroundColor Red
        Read-Host "Druk Enter om te stoppen"
        exit 1
    }
    Write-Host "Verbonden met $BOX" -ForegroundColor Green
}

function Adb-Shell([string]$cmd) {
    & $ADB -s $BOX shell $cmd
}

function Confirm-Ja([string]$vraag) {
    $a = Read-Host "$vraag  Typ JA om door te gaan"
    if ($a -ne "JA") { Write-Host "Gestopt, er is niets veranderd."; Read-Host "Enter"; exit 0 }
}
