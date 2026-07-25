param(
  [string]$ZWCADDir = "D:\ZWCAD2026",
  [string]$OutputDir = $PSScriptRoot,
  [string]$OutputName = "AICADRibbonHostV6.dll"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$compiler = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
$frameworkDir = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319"
$wpfDir = Join-Path $frameworkDir "WPF"
$sourceFile = Join-Path $PSScriptRoot "AICADRibbon\AiRibbonPlugin.cs"
$outputPath = Join-Path $OutputDir $OutputName

$requiredFiles = @(
  $compiler,
  $sourceFile,
  (Join-Path $ZWCADDir "ZwManaged.dll"),
  (Join-Path $ZWCADDir "ZwDatabaseMgd.dll"),
  (Join-Path $ZWCADDir "ZdWindows.dll"),
  (Join-Path $frameworkDir "System.Drawing.dll"),
  (Join-Path $frameworkDir "System.Windows.Forms.dll"),
  (Join-Path $frameworkDir "System.Xaml.dll"),
  (Join-Path $wpfDir "PresentationCore.dll"),
  (Join-Path $wpfDir "PresentationFramework.dll"),
  (Join-Path $wpfDir "WindowsBase.dll")
)

foreach ($path in $requiredFiles) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required file: $path"
  }
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$references = @(
  (Join-Path $ZWCADDir "ZwManaged.dll"),
  (Join-Path $ZWCADDir "ZwDatabaseMgd.dll"),
  (Join-Path $ZWCADDir "ZdWindows.dll"),
  (Join-Path $frameworkDir "System.Drawing.dll"),
  (Join-Path $frameworkDir "System.Windows.Forms.dll"),
  (Join-Path $frameworkDir "System.Xaml.dll"),
  (Join-Path $wpfDir "PresentationCore.dll"),
  (Join-Path $wpfDir "PresentationFramework.dll"),
  (Join-Path $wpfDir "WindowsBase.dll")
) | ForEach-Object { "/reference:" + $_ }

$arguments = @(
  "/nologo"
  "/target:library"
  "/platform:x64"
  "/optimize+"
  "/out:" + $outputPath
  $sourceFile
) + $references

& $compiler @arguments

if ($LASTEXITCODE -ne 0) {
  throw "Build failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $outputPath)) {
  throw "Build failed. Output not found: $outputPath"
}

Write-Host "Built $outputPath"
