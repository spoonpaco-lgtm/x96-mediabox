# Draait 02-opruimen.ps1 terug: alle apps weer aan, animaties weer normaal.
. "$PSScriptRoot\_config.ps1"
Connect-Box

$ids = @(
    "com.abupdate.fota_demo_iot", "com.videostrong.factorytest", "com.android.app.cus.aging",
    "com.example.a", "com.cetusplay.remoteservice", "com.overseas.store.appstore",
    "com.yxt.appstore", "cm.aptoidetv.pt", "com.android.camera2", "com.droidlogic.exoplayer2.demo",
    "org.chromium.webview_shell", "com.android.printspooler", "com.android.deskclock",
    "com.google.android.partnersetup", "com.droidlogic.updater", "com.android.tv", "com.android.se",
    "com.google.android.youtube", "com.google.android.googlequicksearchbox"
)
foreach ($id in $ids) { Write-Host "$id : $(Adb-Shell "pm enable $id")" }

Adb-Shell "settings put global window_animation_scale 1"
Adb-Shell "settings put global transition_animation_scale 1"
Adb-Shell "settings put global animator_duration_scale 1"
Write-Host "Alles teruggezet." -ForegroundColor Green
Read-Host "Enter om af te sluiten"
