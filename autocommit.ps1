<#
    Auto-commit and push this repo.
    Commits any working-tree changes with a timestamped message, then pushes to origin.
    Does nothing (exit 0) when the tree is clean.
#>

$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$log  = Join-Path $repo 'autocommit.log'

function Write-Log($msg) {
    $line = "{0}  {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Add-Content -Path $log -Value $line -Encoding utf8
}

Set-Location $repo

try {
    # Anything to commit?
    $changes = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($changes)) {
        Write-Log 'clean - nothing to commit'
        exit 0
    }

    $branch = git rev-parse --abbrev-ref HEAD
    $stamp  = Get-Date -Format 'yyyy-MM-dd HH:mm'

    git add -A
    if ($LASTEXITCODE -ne 0) { throw "git add failed ($LASTEXITCODE)" }

    git commit -m "auto: $stamp"
    if ($LASTEXITCODE -ne 0) { throw "git commit failed ($LASTEXITCODE)" }

    $count = ($changes -split "`n" | Where-Object { $_.Trim() }).Count
    Write-Log "committed $count file(s) on $branch"

    git push origin $branch
    if ($LASTEXITCODE -ne 0) { throw "git push failed ($LASTEXITCODE) - commit is saved locally" }

    Write-Log "pushed to origin/$branch"
}
catch {
    Write-Log "ERROR: $_"
    exit 1
}
