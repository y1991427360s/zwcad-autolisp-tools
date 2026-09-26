param(
  [string]$ZWCADDir = "D:\ZWCAD2026",
  [string]$OutputDir = $PSScriptRoot,
  [string]$OutputName = "AICADRibbonHostV6.dll"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$buildStarted = Get-Date

$compiler = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
$frameworkDir = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319"
$wpfDir = Join-Path $frameworkDir "WPF"
$sourceFile = Join-Path $PSScriptRoot "AICADRibbon\AiRibbonPlugin.cs"
$outputPath = Join-Path $OutputDir $OutputName
$managerPath = Join-Path $OutputDir "DwgWindowManager.exe"
$protocolSource = Join-Path $PSScriptRoot "WindowManager\Protocol.cs"
$agentSource = Join-Path $PSScriptRoot "AICADRibbon\WindowAgent.cs"
$managerSources = @(Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot "WindowManager") -Filter *.cs | ForEach-Object { $_.FullName })

$requiredFiles = @(
  $compiler,
  $sourceFile,
  $protocolSource,
  $agentSource,
  (Join-Path $ZWCADDir "ZwManaged.dll"),
  (Join-Path $ZWCADDir "ZwDatabaseMgd.dll"),
  (Join-Path $ZWCADDir "ZdWindows.dll"),
  (Join-Path $frameworkDir "System.Drawing.dll"),
  (Join-Path $frameworkDir "System.Windows.Forms.dll"),
  (Join-Path $frameworkDir "System.Runtime.Serialization.dll"),
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

function Prepare-TargetOutput([string]$targetPath) {
  if (Test-Path -LiteralPath $targetPath) {
    try {
      $stream = [System.IO.File]::OpenWrite($targetPath)
      $stream.Close()
    } catch {
      $oldPath = "$targetPath.old"
      if (Test-Path -LiteralPath $oldPath) {
        try { Remove-Item -LiteralPath $oldPath -Force -ErrorAction SilentlyContinue } catch { }
      }
      if (Test-Path -LiteralPath $oldPath) {
        $oldPath = "$targetPath.old." + [System.IO.Path]::GetRandomFileName()
      }
      Rename-Item -LiteralPath $targetPath -NewName (Split-Path -Leaf $oldPath) -Force
      Write-Host "Target $targetPath is locked by a running process; renamed to $oldPath for new build."
    }
  }
}

$references = @(
  (Join-Path $ZWCADDir "ZwManaged.dll"),
  (Join-Path $ZWCADDir "ZwDatabaseMgd.dll"),
  (Join-Path $ZWCADDir "ZdWindows.dll"),
  (Join-Path $frameworkDir "System.Drawing.dll"),
  (Join-Path $frameworkDir "System.Windows.Forms.dll"),
  (Join-Path $frameworkDir "System.Runtime.Serialization.dll"),
  (Join-Path $frameworkDir "System.Xaml.dll"),
  (Join-Path $wpfDir "PresentationCore.dll"),
  (Join-Path $wpfDir "PresentationFramework.dll"),
  (Join-Path $wpfDir "WindowsBase.dll")
) | ForEach-Object { "/reference:" + $_ }

Prepare-TargetOutput $outputPath

$arguments = @(
  "/nologo"
  "/target:library"
  "/platform:x64"
  "/optimize+"
  "/out:" + $outputPath
  $sourceFile
  $agentSource
  $protocolSource
) + $references

& $compiler @arguments

if ($LASTEXITCODE -ne 0) {
  throw "Build failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $outputPath)) {
  throw "Build failed. Output not found: $outputPath"
}

Prepare-TargetOutput $managerPath

$managerArguments = @(
  "/nologo", "/target:winexe", "/platform:x64", "/optimize+",
  ("/out:" + $managerPath),
  "/reference:System.dll", "/reference:System.Core.dll",
  "/reference:System.Drawing.dll", "/reference:System.Windows.Forms.dll",
  "/reference:System.Runtime.Serialization.dll"
) + $managerSources
& $compiler @managerArguments
if ($LASTEXITCODE -ne 0) { throw "Manager build failed with exit code $LASTEXITCODE" }
foreach ($artifactPath in @($outputPath, $managerPath)) {
  $artifact = Get-Item -LiteralPath $artifactPath
  if ($artifact.LastWriteTime -lt $buildStarted -or $artifact.Length -eq 0) {
    throw "Artifact was not updated: $artifactPath"
  }
  $artifact | Select-Object FullName, LastWriteTime, Length
}
Write-Host "Build started: $($buildStarted.ToString('o'))"
