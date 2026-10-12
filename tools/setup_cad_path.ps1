#Requires -Version 5.1
<#
.SYNOPSIS
  中望CAD 2026 插件迁移环境一键配置脚本
.DESCRIPTION
  当 ZW-auto_lisp 插件文件夹被移动到新路径或新电脑时，执行本脚本可自动完成：
  1. 更新 Windows 用户环境变量 AICADAA_BASEDIR
  2. 更新中望CAD 2026 所有配置文件（Default、中望CAD 2026-Default 等）的注册表：
     - 支持文件搜索路径 (ZWCADSEARCHPATH)
     - 受信任路径 (TRUSTEDPATHS)
     - 基础目录变量 (AICADAA_BASEDIR)
     - 启动组 (Appload Startup Suite)
  3. 更新中望CAD漫游支持目录中的 acaddoc.lsp 自动加载器
  4. 更新 LISP 源码中硬编码的项目基准路径（带自动备份）
#>

param(
  [string]$TargetDir = ""
)

$ErrorActionPreference = "Stop"

if (-not $TargetDir) {
  $TargetDir = (Resolve-Path "$PSScriptRoot\..").Path
} else {
  $TargetDir = (Resolve-Path $TargetDir).Path
}

$v6Dir = Join-Path $TargetDir "V6"
$targetDirForward = $TargetDir.Replace('\', '/')
$v6DirForward = $v6Dir.Replace('\', '/')

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  中望CAD 2026 插件环境配置与迁移工具" -ForegroundColor Cyan
Write-Host "  目标根目录: $TargetDir" -ForegroundColor Yellow
Write-Host "  V6目录:     $v6Dir" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

# 1. 设置 Windows 用户环境变量
Write-Host "`n[1/4] 更新 Windows 用户环境变量..." -ForegroundColor Green
[Environment]::SetEnvironmentVariable("AICADAA_BASEDIR", $v6Dir, "User")
$env:AICADAA_BASEDIR = $v6Dir
Write-Host "  ✓ AICADAA_BASEDIR = $v6Dir"

# 2. 更新中望CAD 2026 注册表配置
Write-Host "`n[2/4] 更新中望CAD 2026 注册表配置..." -ForegroundColor Green
$regBase = "HKCU:\Software\ZWSoft\ZWCAD\2026\zh-CN\Profiles"

if (Test-Path $regBase) {
  $profiles = Get-ChildItem $regBase
  foreach ($p in $profiles) {
    $pName = $p.PSChildName
    Write-Host "  -> 处理 Profile: $pName" -ForegroundColor Gray
    
    # Config
    $configPath = "$($p.PSPath)\Config"
    if (Test-Path $configPath) {
      # AICADAA_BASEDIR
      Set-ItemProperty -Path $configPath -Name "AICADAA_BASEDIR" -Value $v6Dir
      
      # TRUSTEDPATHS
      $curTrusted = (Get-ItemProperty -Path $configPath -ErrorAction SilentlyContinue).TRUSTEDPATHS
      if ($null -eq $curTrusted) { $curTrusted = "" }
      $trustedParts = @($curTrusted -split ';' | Where-Object { $_ -and -not (Test-Path $_) })
      $trustedParts = @($curTrusted -split ';' | Where-Object { $_ -and $_ -notmatch "ZW-auto_lisp" })
      if ($trustedParts -notcontains $TargetDir) { $trustedParts += $TargetDir }
      if ($trustedParts -notcontains $v6Dir) { $trustedParts += $v6Dir }
      $newTrusted = ($trustedParts -join ';') + ';'
      Set-ItemProperty -Path $configPath -Name "TRUSTEDPATHS" -Value $newTrusted
      
      # ZWCADSEARCHPATH
      $curSearch = (Get-ItemProperty -Path $configPath -ErrorAction SilentlyContinue).ZWCADSEARCHPATH
      if ($null -eq $curSearch) { $curSearch = "" }
      $searchParts = @($curSearch -split ';' | Where-Object { $_ -and $_ -notmatch "ZW-auto_lisp" })
      if ($searchParts -notcontains $TargetDir) { $searchParts += $TargetDir }
      if ($searchParts -notcontains $v6Dir) { $searchParts += $v6Dir }
      $newSearch = ($searchParts -join ';') + ';'
      Set-ItemProperty -Path $configPath -Name "ZWCADSEARCHPATH" -Value $newSearch
    }
    
    # Appload Startup
    $startupPath = "$($p.PSPath)\Dialogs\Appload\Startup"
    if (-not (Test-Path $startupPath)) {
      New-Item -Path $startupPath -Force | Out-Null
    }
    Set-ItemProperty -Path $startupPath -Name "NumStartup" -Value 2
    Set-ItemProperty -Path $startupPath -Name "1Startup" -Value (Join-Path $TargetDir "AA整合版本.lsp")
    Set-ItemProperty -Path $startupPath -Name "2Startup" -Value (Join-Path $v6Dir "aicad_aa_loader.lsp")
  }
  Write-Host "  ✓ 注册表 Profile 配置更新完成"
} else {
  Write-Host "  ! 未检测到 ZWCAD 2026 注册表路径，跳过注册表更新" -ForegroundColor Yellow
}

# 3. 更新 acaddoc.lsp
Write-Host "`n[3/4] 更新中望CAD支持目录 acaddoc.lsp..." -ForegroundColor Green
$roamingSupport = "C:\Users\$env:USERNAME\AppData\Roaming\ZWSOFT\ZWCAD\2026\zh-CN\Support"
if (Test-Path $roamingSupport) {
  $acaddocPath = Join-Path $roamingSupport "acaddoc.lsp"
  $loaderPathForward = "$v6DirForward/aicad_aa_loader.lsp"
  $content = @(
    ";;; ZWCAD 2026 clean document startup."
    ";;; Keep AICAD floating panels available without listing helper loaders in APPLOAD Startup."
    ""
    "(vl-load-com)"
    ""
    "(defun zw-clean-load-aicad (/ loader)"
    "  (if (not *zw-clean-aicad-loaded*)"
    "    (progn"
    "      (setq *zw-clean-aicad-loaded* T)"
    "      (setq loader ""$loaderPathForward"")"
    "      (if (findfile loader)"
    "        (load loader nil)"
    "        (prompt ""\nAICAD loader not found."")"
    "      )"
    "    )"
    "  )"
    "  (princ)"
    ")"
    ""
    "(zw-clean-load-aicad)"
    "(princ)"
    ""
  ) -join "`r`n"
  
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($acaddocPath, $content, $utf8NoBom)
  Write-Host "  ✓ acaddoc.lsp 更新完成: $acaddocPath"
} else {
  Write-Host "  ! 未检测到漫游 Support 目录: $roamingSupport" -ForegroundColor Yellow
}

# 4. 同步更新 LISP 源码路径变量（带备份）
Write-Host "`n[4/4] 检查并更新 LISP 源码路径..." -ForegroundColor Green
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupsDir = Join-Path $TargetDir "backups"
if (-not (Test-Path $backupsDir)) { New-Item -ItemType Directory -Path $backupsDir | Out-Null }

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# 4.1 AA整合版本.lsp
$aaPath = Join-Path $TargetDir "AA整合版本.lsp"
if (Test-Path $aaPath) {
  $aaText = [System.IO.File]::ReadAllText($aaPath, [System.Text.Encoding]::UTF8)
  $newPattern = "(setq *ztf-project-dir* ""$targetDirForward"")"
  $updatedText = [System.Text.RegularExpressions.Regex]::Replace($aaText, '\(setq \*ztf-project-dir\* ".*?"\)', $newPattern)
  if ($updatedText -ne $aaText) {
    Copy-Item $aaPath (Join-Path $backupsDir "AA整合版本.lsp.bak-$timestamp-setup")
    $normalized = $updatedText -replace "`r?`n", "`r`n"
    [System.IO.File]::WriteAllText($aaPath, $normalized, $utf8NoBom)
    Write-Host "  ✓ AA整合版本.lsp *ztf-project-dir* 已更新"
  } else {
    Write-Host "  ✓ AA整合版本.lsp 路径已是最优"
  }
}

# 4.2 aicad_aa_loader.lsp
$loaderPath = Join-Path $v6Dir "aicad_aa_loader.lsp"
if (Test-Path $loaderPath) {
  $lText = [System.IO.File]::ReadAllText($loaderPath, [System.Text.Encoding]::UTF8)
  $escapedV6 = $v6Dir.Replace('\', '\\')
  $newPattern = "(setq *AICADAA_DefaultInstallDirectory* ""$escapedV6"")"
  $updatedText = [System.Text.RegularExpressions.Regex]::Replace($lText, '\(setq \*AICADAA_DefaultInstallDirectory\* ".*?"\)', $newPattern)
  if ($updatedText -ne $lText) {
    $normalized = $updatedText -replace "`r?`n", "`r`n"
    [System.IO.File]::WriteAllText($loaderPath, $normalized, $utf8NoBom)
    Write-Host "  ✓ aicad_aa_loader.lsp 默认安装目录已更新"
  } else {
    Write-Host "  ✓ aicad_aa_loader.lsp 路径已是最优"
  }
}

# 4.3 aicad_extension.lsp
$extPath = Join-Path $v6Dir "aicad_extension.lsp"
if (Test-Path $extPath) {
  $eText = [System.IO.File]::ReadAllText($extPath, [System.Text.Encoding]::UTF8)
  $escapedV6 = $v6Dir.Replace('\', '\\')
  $newPattern = "(setq *AICAD_DefaultInstallDirectory* ""$escapedV6"")"
  $updatedText = [System.Text.RegularExpressions.Regex]::Replace($eText, '\(setq \*AICAD_DefaultInstallDirectory\* ".*?"\)', $newPattern)
  if ($updatedText -ne $eText) {
    $normalized = $updatedText -replace "`r?`n", "`r`n"
    [System.IO.File]::WriteAllText($extPath, $normalized, $utf8NoBom)
    Write-Host "  ✓ aicad_extension.lsp 默认安装目录已更新"
  } else {
    Write-Host "  ✓ aicad_extension.lsp 路径已是最优"
  }
}

Write-Host "`n配置迁移完成！请启动中望CAD 2026 进行验证。" -ForegroundColor Cyan
