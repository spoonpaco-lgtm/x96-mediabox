@echo off
title X96 Mediabox
cd /d "%~dp0"

:menu
cls
echo ==========================================================
echo   X96 Mediabox  -  kies een stap (doe ze in deze volgorde)
echo ==========================================================
echo.
echo   1. Backup van de huidige Kodi naar F:
echo   2. Opruimen: rommel uitschakelen, animaties sneller
echo   3. Kodi schoon installeren met de X96-instellingen
echo   4. X96 Launcher installeren (Kodi start dan bij opstarten)
echo      -- daarna: docs\KODI-HANDLEIDING.md op de projector --
echo   5. Root over wifi uit (als alles werkt)
echo.
echo   Terugdraaien:
echo   7. Opruimen terugdraaien (alle apps weer aan)
echo   8. Kodi-backup terugzetten
echo.
echo   0. Stoppen
echo.
set /p keuze="Keuze: "

if "%keuze%"=="1" call :run 01-backup-kodi.ps1
if "%keuze%"=="2" call :run 02-opruimen.ps1
if "%keuze%"=="3" call :run 03-kodi-schoon-installeren.ps1
if "%keuze%"=="4" call :run 04-launcher-installeren.ps1
if "%keuze%"=="5" call :run 05-root-uit.ps1
if "%keuze%"=="7" call :run 02-opruimen-terug.ps1
if "%keuze%"=="8" call :run 06-kodi-terugzetten.ps1
if "%keuze%"=="0" exit /b
goto menu

:run
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\%~1"
exit /b
