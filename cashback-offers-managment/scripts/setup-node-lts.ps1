$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$version = '24.22.0'
$archiveName = "node-v$version-win-x64.zip"
$archiveUrl = "https://nodejs.org/dist/v$version/$archiveName"
$expectedSha256 = 'f9683a19877e12a9b167305c8db71040d812876359de21f0d2e97c3f321f80c3'
$toolRoot = Join-Path $env:LOCALAPPDATA 'cashback-offers-toolchains'
$installRoot = Join-Path $toolRoot "node-v$version-win-x64"

if (Test-Path -LiteralPath $installRoot) {
    $installedNode = Join-Path $installRoot 'node.exe'
    if (-not (Test-Path -LiteralPath $installedNode -PathType Leaf)) {
        throw "Target directory exists but does not contain node.exe; refusing to overwrite it: $installRoot"
    }

    $installedVersion = (& $installedNode --version).Trim()
    if ($installedVersion -ne "v$version") {
        throw "Unexpected Node.js version at $installedNode (found $installedVersion)."
    }

    Write-Output "Node.js $version is already installed at $installRoot"
    Write-Output "For this PowerShell session run: `$env:PATH = `"$installRoot;`$env:PATH`""
    exit 0
}

$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
$archivePath = Join-Path $temporaryRoot $archiveName

try {
    New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null
    Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath

    $actualSha256 = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualSha256 -ne $expectedSha256) {
        throw "Node.js archive SHA-256 mismatch. Expected $expectedSha256, got $actualSha256."
    }

    $stagingRoot = Join-Path $temporaryRoot 'extracted'
    Expand-Archive -LiteralPath $archivePath -DestinationPath $stagingRoot
    $extractedRoot = Join-Path $stagingRoot "node-v$version-win-x64"
    if (-not (Test-Path -LiteralPath (Join-Path $extractedRoot 'node.exe') -PathType Leaf)) {
        throw 'The verified Node.js archive did not contain node.exe at the expected path.'
    }

    New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null
    Move-Item -LiteralPath $extractedRoot -Destination $installRoot

    $nodePath = Join-Path $installRoot 'node.exe'
    $npmPath = Join-Path $installRoot 'npm.cmd'
    if ((& $nodePath --version).Trim() -ne "v$version") {
        throw 'Installed Node.js version did not match the pinned version.'
    }
    if (-not (Test-Path -LiteralPath $npmPath -PathType Leaf)) {
        throw 'The Node.js distribution does not contain npm.cmd.'
    }

    Write-Output "Installed Node.js $version after verifying the official archive SHA-256."
    Write-Output "For this PowerShell session run: `$env:PATH = `"$installRoot;`$env:PATH`""
    Write-Output 'Then verify with: node --version; npm --version'
}
finally {
    Remove-Item -LiteralPath $temporaryRoot -Recurse -Force -ErrorAction SilentlyContinue
}