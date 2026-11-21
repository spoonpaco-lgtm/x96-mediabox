# Installeert de X96 Launcher (Netflix-stijl) en maakt hem het startscherm.
# De oude Leanback-launcher blijft staan als reserve.
. "$PSScriptRoot\_config.ps1"
Connect-Box

$apk = Get-ChildItem $REPO_ROOT -Filter "x96-launcher-*.apk" -Recurse | Sort-Object LastWriteTime | Select-Object -Last 1
if (-not $apk) { Write-Host "Geen x96-launcher-*.apk gevonden. Download hem uit de GitHub-release." -ForegroundColor Red; Read-Host; exit 1 }

Write-Host "Installeren: $($apk.Name)"
& $ADB -s $BOX install -r $apk.FullName
Adb-Shell "cmd package set-home-activity nl.spoonpaco.x96launcher/.MainActivity"
Adb-Shell "input keyevent KEYCODE_HOME"
Write-Host ""
Write-Host "Klaar. Terug naar de oude launcher:" -ForegroundColor Green
Write-Host "  adb shell cmd package set-home-activity com.amlogic.android.leanbacklauncher/.MainActivity"
Read-Host "Enter om af te sluiten"
