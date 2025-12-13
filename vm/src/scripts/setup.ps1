# 🧠 Idaptik Setup Wizard – Bridge Edition (Part 1)

param (
    [string]$Mode = ""
)

Write-Host "`n🧠 Idaptik Setup Wizard – Bridge Edition" -ForegroundColor Cyan
Write-Host "------------------------------------------------"

function Get-Version {
    param($Cmd, $Arg = "--version")
    try { & $Cmd $Arg 2>&1 | Select-String -Pattern '\d+(\.\d+){1,3}' | Select-Object -First 1 } catch { return $null }
}

function Compare-Version($ver, $min) {
    try {
        [Version]$v1 = $ver -replace '[^\d.]', ''
        [Version]$v2 = $min -replace '[^\d.]', ''
        return [int]($v1.CompareTo($v2))
    } catch {
        return $null
    }
}

$tools = @(
    @{ Name = "Git"; Cmd = "git"; Arg = "--version"; Min = "2.30.0"; Hint = "winget install Git.Git" },
    @{ Name = "Node.js"; Cmd = "node"; Arg = "--version"; Min = "18.0.0"; Hint = "winget install OpenJS.NodeJS.LTS" },
    @{ Name = "Bun"; Cmd = "bun"; Arg = "--version"; Min = "1.0.0"; Hint = "irm https://bun.sh/install.ps1 | iex" },
    @{ Name = "Elixir"; Cmd = "elixir"; Arg = "--version"; Min = "1.14.0"; Hint = "winget install Elixir.Elixir" },
    @{ Name = "Erlang"; Cmd = "erl"; Arg = ""; Min = "0.0.0"; Hint = "winget install Erlang.ErlangOTP" },
    @{ Name = "TypeScript"; Cmd = "bun x tsc"; Arg = "--version"; Min = "5.0.0"; Hint = "bun add -d typescript" },
    @{ Name = "VS Code CLI"; Cmd = "code"; Arg = "--version"; Min = "0"; Hint = "Ctrl+Shift+P → Shell Command: Install 'code' in PATH" }
)

$results = @()
Write-Host "`n🧮 System Check:\n"

$table = @()
foreach ($t in $tools) {
    $v = Get-Version $t.Cmd $t.Arg
    if (-not $v) {
        $status = "❌ Missing"
        $row = @{ Tool = $t.Name; Version = ""; Target = $t.Min; Status = $status }
    } else {
        $cmp = Compare-Version $v $t.Min
        $status = if ($cmp -lt 0) { "⚠️ Outdated" } else { "✅ OK" }
        $row = @{ Tool = $t.Name; Version = $v.Line.Trim(); Target = $t.Min; Status = $status }
    }
    $table += New-Object PSObject -Property $row
    $results += @{ Name = $t.Name; Found = $v; Cmd = $t.Cmd; Status = $status; Hint = $t.Hint; Min = $t.Min }
}

$table | Format-Table Tool, Version, Target, Status -AutoSize
Write-Host ""

# Mode detection
$autoAll = $Mode -eq "--all"

if (-not $autoAll) {
    Write-Host "💡 Choose an action:"
    Write-Host "[A] Add missing"
    Write-Host "[U] Update outdated"
    Write-Host "[F] Fine-grain control"
    Write-Host "[S] Skip setup actions"

    $choice = Read-Host "`n👉 What would you like to do?"
    $action = $choice.ToUpper()
} else {
    Write-Host "🚀 Running in silent mode: --all (install + update everything)" -ForegroundColor Yellow
    $action = "ALL"
}
function Install-Tool($entry) {
    if ($entry.Status -eq "❌ Missing") {
        Write-Host "`n➕ Installing $($entry.Name)..." -ForegroundColor Cyan
        Invoke-Expression $entry.Hint
    } elseif ($entry.Status -eq "⚠️ Outdated") {
        Write-Host "`n⏫ Updating $($entry.Name)..." -ForegroundColor Yellow
        switch ($entry.Name) {
            "Bun" { bun upgrade }
            "Mix" { mix local.hex --force }
        }
    }
}

if ($action -eq "ALL" -or $action -eq "A" -or $action -eq "U") {
    foreach ($r in $results) {
        if (($action -eq "ALL") -or
            ($action -eq "A" -and $r.Status -eq "❌ Missing") -or
            ($action -eq "U" -and $r.Status -eq "⚠️ Outdated")) {
            Install-Tool $r
        }
    }
}

if ($action -eq "F") {
    foreach ($r in $results) {
        if ($r.Status -ne "✅ OK") {
            $do = Read-Host "`n🔧 $($r.Name) is $($r.Status). Fix now? [Y/n]"
            if ($do -match "^(Y|y|)$" -or $do -eq "") {
                Install-Tool $r
            }
        }
    }
}

# 🧩 VS Code Extensions
$codeCmd = $results | Where-Object { $_.Name -eq "VS Code CLI" -and $_.Status -eq "✅ OK" } | Select-Object -ExpandProperty Cmd
$exts = @(
    "elixir-lang.elixir",
    "phoenixframework.phoenix",
    "esbenp.prettier-vscode",
    "bun-team.bun-vscode",
    "github.copilot"
)
if ($codeCmd) {
    $existing = & $codeCmd --list-extensions
    foreach ($ext in $exts) {
        if (-not ($existing -contains $ext)) {
            if ($autoAll -or (Read-Host "📦 Install VS Code extension $ext? [Y/n]") -match "^(Y|y|)$" -or $_ -eq "") {
                & $codeCmd --install-extension $ext
            }
        }
    }
}

# 🪑 Seat warmer
if ($autoAll -or (Read-Host "`n🪑 Run seat warmer (open project + files)? [Y/n]") -match "^(Y|y|)$" -or $_ -eq "") {
    if (Test-Path "./scripts/warmup.ps1") {
        & "./scripts/warmup.ps1"
    } else {
        Write-Host "💡 warmup.ps1 not found. Skipping." -ForegroundColor DarkYellow
    }
}

# 📋 Summary
Write-Host "`n📋 Final Setup Status:" -ForegroundColor Cyan
foreach ($r in $results) {
    $c = $r.Status -match "OK" ? "Green" : ($r.Status -match "Outdated" ? "Yellow" : "Red")
    $s = $r.Status -match "OK" ? "✔" : ($r.Status -match "Outdated" ? "⚠" : "✘")
    Write-Host "$s $($r.Name) ($($r.Status))" -ForegroundColor $c
}

Write-Host "`n🎉 Setup complete. You are now on the Bridge." -ForegroundColor Green
