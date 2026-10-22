$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$pythonCommand = Get-Command python.exe -ErrorAction Stop
$pythonPath = & $pythonCommand.Source -c 'import sys; print(sys.executable)'
if ($LASTEXITCODE -ne 0) { throw 'Python is unavailable.' }
$pythonwPath = Join-Path (Split-Path -Parent $pythonPath.Trim()) 'pythonw.exe'
if (-not (Test-Path -LiteralPath $pythonwPath)) { throw 'pythonw.exe is unavailable. Install Python with Tk support.' }
$panelPath = Join-Path $PSScriptRoot 'alias_panel.py'
Start-Process -FilePath $pythonwPath -ArgumentList @('"' + $panelPath + '"') -WorkingDirectory $taskRoot -WindowStyle Hidden
