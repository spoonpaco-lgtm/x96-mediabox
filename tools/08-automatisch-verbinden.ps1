# Zet "automatisch verbinden met de box" aan of uit.
# Aan: Windows draait elke 2 minuten onzichtbaar tools\helper\verbind-box.ps1:
#      - verbindt adb opnieuw met de box als de verbinding weg is;
#      - geeft Kodi-bestanden die via adb (als root) zijn neergezet terug aan Kodi
#        (START.bat -> 9 is dan niet meer nodig).
#      Het hulpscript wordt naar %LOCALAPPDATA%\X96 gekopieerd, dus het werkt ook zonder F:.
# Staat het al aan, dan wordt het hulpscript bijgewerkt naar de nieuwste versie.
# Uit: de taak en de hulpbestanden worden weer verwijderd.
. "$PSScriptRoot\_config.ps1"

$TaskName = "X96 box verbinden"
$Dir      = Join-Path $env:LOCALAPPDATA "X96"
$Ps1      = Join-Path $Dir "verbind-box.ps1"
$Vbs      = Join-Path $Dir "verbind-box.vbs"
$Log      = Join-Path $Dir "verbind-box.log"

function Write-Helper {
    New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    $src = Join-Path $PSScriptRoot "helper\verbind-box.ps1"
    (Get-Content $src -Raw).Replace("__ADB__", $ADB).Replace("__BOX__", $BOX).Replace("__LOG__", $Log) |
        Set-Content -Path $Ps1 -Encoding UTF8
    # VBS-wrapper zodat er geen PowerShell-venster opflitst.
    "CreateObject(""WScript.Shell"").Run ""powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """"$Ps1"""""", 0, False" |
        Set-Content -Path $Vbs -Encoding ASCII
}

$bestaat = $null -ne (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)

Write-Host ""
if ($bestaat) {
    Write-Helper
    Write-Host "Automatisch verbinden staat AAN (hulpscript bijgewerkt naar de nieuwste versie)." -ForegroundColor Green
    $a = Read-Host "Uitzetten? Typ UIT (of Enter om het zo te laten)"
    if ($a -eq "UIT") {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Remove-Item -Recurse -Force $Dir -ErrorAction SilentlyContinue
        Write-Host "Uitgezet en opgeruimd." -ForegroundColor Yellow
    }
    Read-Host "Enter"
    exit 0
}

Write-Host "Automatisch verbinden staat UIT."
Write-Host "Aanzetten laat Windows elke 2 minuten controleren of de box ($BOX) verbonden is,"
Write-Host "en zo niet, opnieuw verbinden. Ook zet het de rechten van Kodi-bestanden vanzelf goed."
Write-Host "Er verschijnt geen venster."
$a = Read-Host "Aanzetten? Typ AAN"
if ($a -ne "AAN") { Write-Host "Niets veranderd."; Read-Host "Enter"; exit 0 }

Write-Helper

$action   = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$Vbs`""
$elke2min = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 2)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 1)
try {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $elke2min `
        -Settings $settings -Description "Verbindt adb elke 2 minuten opnieuw met de X96-box ($BOX)." -ErrorAction Stop | Out-Null
} catch {
    Write-Host "!!! Taak aanmaken mislukt: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Enter"; exit 1
}

# Meteen een keer verbinden.
& $ADB connect $BOX | Out-Host
Write-Host ""
Write-Host "Aangezet. Logboek van herverbindingen: $Log" -ForegroundColor Green
Read-Host "Enter"
