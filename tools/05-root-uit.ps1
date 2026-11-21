# Stap 8: root over wifi weer uit. Na een herstart draait ADB weer als gewone gebruiker.
. "$PSScriptRoot\_config.ps1"
Connect-Box
Confirm-Ja "Root-instelling (/data/local.prop) verwijderen en de box herstarten?"
Adb-Shell "rm /data/local.prop"
& $ADB -s $BOX reboot
Write-Host "Box herstart. Root staat uit; ADB over wifi blijft werken." -ForegroundColor Green
Read-Host "Enter om af te sluiten"
