# Draait elke 2 minuten onzichtbaar via de Windows-taak "X96 box verbinden" (zie 08-automatisch-verbinden.ps1).
# 1. Verbindt adb opnieuw met de box als de verbinding weg is.
# 2. Geeft Kodi-bestanden die via adb (als root) zijn neergezet automatisch terug aan Kodi,
#    zodat START.bat -> 9 niet meer nodig is.
$adb = "__ADB__"
$box = "__BOX__"
$log = "__LOG__"
$lower = "/data/media/0/Android/data/org.xbmc.kodi/files/.kodi"

function Write-Log([string]$msg) {
    Add-Content -Path $log -Value ("{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg)
    if ((Get-Item $log).Length -gt 200KB) { Get-Content $log -Tail 200 | Set-Content $log }
}

if (-not (Test-Path $adb)) { exit 0 }

# 1. Verbinding
$state = (& $adb -s $box get-state 2>$null)
if ($state -ne "device") {
    & $adb disconnect $box 2>$null | Out-Null
    Write-Log ((& $adb connect $box 2>&1) -join " ")
    $state = (& $adb -s $box get-state 2>$null)
    if ($state -ne "device") { exit 0 }
}

# 2. Rechten: alleen iets doen als er in userdata een bestand van root staat.
$rootFile = (& $adb -s $box shell "find $lower/userdata -user root -print 2>/dev/null | head -n 1" 2>$null | Out-String).Trim()
if (-not $rootFile) { exit 0 }

# Eigenaar van de addons-map: die maakt Kodi zelf aan en wordt nooit via adb overschreven.
$owner = (& $adb -s $box shell "stat -c %u:%g $lower/addons" 2>$null | Out-String).Trim()
if ($owner -notmatch '^\d+:\d+$' -or $owner -like '0:*') {
    Write-Log "Rechten NIET hersteld: Kodi-eigenaar onbekend ($owner)"
    exit 0
}
& $adb -s $box shell "chown -R $owner $lower/userdata; chmod -R ug+rw $lower/userdata" 2>$null | Out-Null
Write-Log "Rechten hersteld naar $owner (o.a. $rootFile)"
