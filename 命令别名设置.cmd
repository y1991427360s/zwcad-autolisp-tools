@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\start-alias-panel.ps1"
if errorlevel 1 pause
