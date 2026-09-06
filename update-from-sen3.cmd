@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\remote-cad.ps1" -Action Update
pause
