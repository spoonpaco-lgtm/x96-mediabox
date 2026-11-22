# Zet "automatisch verbinden met de box" aan of uit.
# Aan: Windows probeert elke 2 minuten de box via adb te verbinden,
#      onzichtbaar op de achtergrond. Werkt ook als de F:-schijf er niet in zit.
# Uit: de taak en de hulpbestanden worden weer verwijderd.
. "$PSScriptRoot\_config.ps1"

$TaskName = "X96 box verbinden"
$Dir      = Join-Path $env:LOCALAPPDATA "X96"
$Ps1      = Join-Path $Dir "verbind-box.ps1"
$Vbs      = Join-Path $Dir "verbind-box.vbs"
$Log      = Join-Path $Dir "verbind-box.log"

$bestaat = $null -ne (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)

Write-Host ""
if ($bestaat) {
    Write-Host "Automatisch verbinden staat AAN." -ForegroundColor Green
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
Write-Host "en zo niet, opnieuw verbinden. Er verschijnt geen venster."
$a = Read-Host "Aanzetten? Typ AAN"
if ($a -ne "AAN") { Write-Host "Niets veranderd."; Read-Host "Enter"; exit 0 }

New-Item -ItemType Directory -Force -Path $Dir | Out-Null

# Het eigenlijke verbindscript (los van F:, met vaste paden).
@"
`$adb = "$ADB"
`$box = "$BOX"
`$log = "$Log"
if (-not (Test-Path `$adb)) { exit 0 }
`$state = (& `$adb -s `$box get-state 2>`$null)
if (`$state -ne "device") {
    & `$adb disconnect `$box 2>`$null | Out-Null
    `$out = (& `$adb connect `$box 2>&1) -join " "
    Add-Content -Path `$log -Value ("{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), `$out)
    if ((Get-Item `$log).Length -gt 200KB) { Get-Content `$log -Tail 200 | Set-Content `$log }
}
"@ | Set-Content -Path $Ps1 -Encoding UTF8

# VBS-wrapper zodat er geen PowerShell-venster opflitst.
@"
CreateObject("WScript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""$Ps1""", 0, False
"@ | Set-Content -Path $Vbs -Encoding ASCII

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
