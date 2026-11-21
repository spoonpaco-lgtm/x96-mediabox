# Stap 1 + 2: rommel UITSCHAKELEN (niet verwijderen) en de box sneller maken.
# Alles is terug te draaien met 02-opruimen-terug.ps1.
. "$PSScriptRoot\_config.ps1"
Connect-Box

$pakketten = @(
    @{ id = "com.abupdate.fota_demo_iot";   wat = "Abupdate (Chinese OTA-updater)" },
    @{ id = "com.videostrong.factorytest";  wat = "WriteMac (fabriekstool)" },
    @{ id = "com.android.app.cus.aging";    wat = "Aging (fabriekstest)" },
    @{ id = "com.example.a";                wat = "ProductTest (fabriekstest)" },
    @{ id = "com.cetusplay.remoteservice";  wat = "CetusPlay (luistert op het netwerk)" },
    @{ id = "com.overseas.store.appstore";  wat = "Overseas appstore" },
    @{ id = "com.yxt.appstore";             wat = "YXT AppStore" },
    @{ id = "cm.aptoidetv.pt";              wat = "Aptoide TV" },
    @{ id = "com.android.camera2";          wat = "Camera (box heeft geen camera)" },
    @{ id = "com.droidlogic.exoplayer2.demo"; wat = "ExoPlayer-demo (testapp)" },
    @{ id = "org.chromium.webview_shell";   wat = "Browser2 (kale testbrowser)" },
    @{ id = "com.android.printspooler";     wat = "Afdrukken" },
    @{ id = "com.android.deskclock";        wat = "Klok" },
    @{ id = "com.google.android.partnersetup"; wat = "Google Partner Setup" },
    @{ id = "com.droidlogic.updater";       wat = "Droidlogic Updater (tweede OTA-updater)" },
    @{ id = "com.android.tv";               wat = "Live TV (geen tuner)" },
    @{ id = "com.android.se";               wat = "Secure Element (NFC, niet aanwezig)" },
    @{ id = "com.google.android.youtube";   wat = "YouTube-app (SmartTube blijft)" },
    @{ id = "com.google.android.googlequicksearchbox"; wat = "Google-app (~555 MB; spraakzoeken valt weg)" }
)

Write-Host "Deze apps worden UITGESCHAKELD (blijven op de box, kunnen terug):"
$pakketten | ForEach-Object { Write-Host "  - $($_.wat)  [$($_.id)]" }
Write-Host ""
Write-Host "Daarna: animaties naar 0,5x."
Confirm-Ja "Doorgaan?"

foreach ($p in $pakketten) {
    $r = Adb-Shell "pm disable-user --user 0 $($p.id)"
    Write-Host "$($p.wat): $r"
}

Adb-Shell "settings put global window_animation_scale 0.5"
Adb-Shell "settings put global transition_animation_scale 0.5"
Adb-Shell "settings put global animator_duration_scale 0.5"
Write-Host "Animaties: 0,5x" -ForegroundColor Green

Write-Host ""
Write-Host "Klaar. Terugdraaien: 02-opruimen-terug.ps1" -ForegroundColor Green
Read-Host "Enter om af te sluiten"
