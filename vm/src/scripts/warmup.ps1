# 🪑 Copilot Seat Warmer – for Idaptik
Write-Host "`n🪑 Warming the seat for Copilot..." -ForegroundColor Cyan

# Define files to open if they exist
$paths = @(
    "..\README.md",
    "..\src\index.ts",
    "..\server\mix.exs"
) | Where-Object { Test-Path $_ }

# Try opening in VS Code
$codeCmd = if (Get-Command "code-insiders" -ErrorAction SilentlyContinue) {
    "code-insiders"
} elseif (Get-Command "code" -ErrorAction SilentlyContinue) {
    "code"
} else {
    $null
}

if ($codeCmd) {
    # Open project folder and key files
    & $codeCmd ".."
    foreach ($file in $paths) {
        & $codeCmd --reuse-window $file
    }
    Write-Host "`n👋 Copilot’s ready. Happy hacking!" -ForegroundColor Green
} else {
    Write-Host "⚠️ VS Code CLI not found. Manually open project in Code." -ForegroundColor Yellow
}
