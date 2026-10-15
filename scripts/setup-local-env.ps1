$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$examplePath = Join-Path $repositoryRoot '.env.example'
$localEnvPath = Join-Path $repositoryRoot '.env'

if (-not (Test-Path -LiteralPath $examplePath -PathType Leaf)) {
    throw "Configuration template not found: $examplePath"
}

if (Test-Path -LiteralPath $localEnvPath) {
    throw "Local .env already exists and was not changed. Edit it manually if you intend to rotate the local secret."
}

$template = [System.IO.File]::ReadAllText($examplePath)
if (-not $template.Contains('__GENERATE_LOCAL_SECRET__')) {
    throw 'The .env.example template has no local secret placeholder.'
}

$secretBytes = [byte[]]::new(32)
$randomNumberGenerator = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $randomNumberGenerator.GetBytes($secretBytes)
}
finally {
    $randomNumberGenerator.Dispose()
}
$localSecret = [System.BitConverter]::ToString($secretBytes).Replace('-', '').ToLowerInvariant()
[System.Array]::Clear($secretBytes, 0, $secretBytes.Length)

$localConfiguration = $template.Replace('__GENERATE_LOCAL_SECRET__', $localSecret)
[System.IO.File]::WriteAllText(
    $localEnvPath,
    $localConfiguration,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Output 'Created an ignored local .env with a cryptographically random database password.'