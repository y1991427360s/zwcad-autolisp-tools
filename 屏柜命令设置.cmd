@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\start-cabinet-panel.ps1"
if errorlevel 1 pause
