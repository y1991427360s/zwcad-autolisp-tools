param(
    [ValidateSet('Develop', 'Update', 'Status')]
    [string]$Action = 'Status'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$branch = 'optimize/robustness-and-cleanup'
Set-Location -LiteralPath $root
function Git-Run {
    param([string[]]$GitArgs)
    $result = & git @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "Git failed: $($GitArgs -join ' ')" }
    return $result
}
if ($Action -eq 'Develop') {
    & ssh -t sen3-via-sen5 'cd /home/ubuntu/projects/zwcad-autolisp-tools && tmux new-session -A -s cad-lisp codex'
    exit $LASTEXITCODE
}
if ($Action -eq 'Status') {
    Git-Run @('status', '--short', '--branch')
    Git-Run @('log', '-1', '--oneline')
    exit 0
}
if ((Git-Run @('branch', '--show-current')) -ne $branch) { throw "Switch to $branch before updating." }
$dirty = @(Git-Run @('status', '--porcelain'))
if ($dirty.Count) { throw 'Local changes found. Commit or preserve them before updating.' }
Git-Run @('fetch', 'origin', $branch)
$old = Git-Run @('rev-parse', 'HEAD')
$target = Git-Run @('rev-parse', "origin/$branch")
if ($old -eq $target) { Write-Host "Already current: $old"; exit 0 }
& git merge-base --is-ancestor $old $target
if ($LASTEXITCODE -ne 0) { throw 'Branches diverged. Update stopped; no files replaced.' }
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$backup = Join-Path $root "backups/remote-update-$stamp"
New-Item -ItemType Directory -Path $backup | Out-Null
Git-Run @('archive', '--format=zip', "--output=$backup/before.zip", 'HEAD')
Git-Run @('archive', '--format=zip', "--output=$backup/incoming.zip", $target)
Expand-Archive -LiteralPath "$backup/incoming.zip" -DestinationPath "$backup/incoming"
$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$extensions = @('.lsp', '.dcl', '.scr', '.mnl', '.lin', '.pat')
foreach ($file in Get-ChildItem -LiteralPath "$backup/incoming" -Recurse -File) {
    if ($extensions -notcontains $file.Extension.ToLowerInvariant()) { continue }
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) { throw "UTF-8 BOM found: $($file.Name)" }
    $text = $utf8.GetString($bytes)
    if ($text.Contains([string][char]0xfffd)) { throw "Replacement character found: $($file.Name)" }
    # Git archives contain canonical LF; checkout applies .gitattributes CRLF.
}
Git-Run @('merge', '--ff-only', $target)
foreach ($name in Git-Run @('ls-files')) {
    if ($extensions -notcontains [IO.Path]::GetExtension($name).ToLowerInvariant()) { continue }
    $text = $utf8.GetString([IO.File]::ReadAllBytes((Join-Path $root $name)))
    if ($text -match '(?<!\r)\n|\r(?!\n)') { throw "Unexpected line endings after checkout: $name. Backup: $backup" }
}
Write-Host "Updated: $target"
Write-Host "Backup: $backup"
Write-Host 'Reload AA LISP in ZWCAD to activate changes. CAD runtime testing is still required.'
