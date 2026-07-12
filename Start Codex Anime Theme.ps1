$ErrorActionPreference = "Stop"

$themeDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$imagePath = Join-Path $themeDir "codex-anime-background.png"
$injectorPath = Join-Path $themeDir "inject-theme.js"
$nodePath = Join-Path $env:LOCALAPPDATA "OpenAI\Codex\bin\node.exe"

if (Get-Process -Name "ChatGPT" -ErrorAction SilentlyContinue) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "Close Codex completely, then run this launcher again.",
        "Codex Anime Theme"
    ) | Out-Null
    exit 1
}

$package = Get-AppxPackage -Name "OpenAI.Codex"
if (-not $package.InstallLocation) {
    throw "The installed Codex app could not be found."
}

$codexExe = Join-Path $package.InstallLocation "app\ChatGPT.exe"
if (-not (Test-Path -LiteralPath $codexExe)) {
    throw "Codex.exe could not be found in the installed package."
}
if (-not (Test-Path -LiteralPath $nodePath)) {
    throw "Codex's bundled Node runtime could not be found."
}

Start-Process -FilePath $codexExe -ArgumentList @(
    "--remote-debugging-port=9223",
    "--remote-allow-origins=http://127.0.0.1:9223"
)

& $nodePath $injectorPath $imagePath 9223
if ($LASTEXITCODE -ne 0) {
    Read-Host "Press Enter to close"
    exit $LASTEXITCODE
}
