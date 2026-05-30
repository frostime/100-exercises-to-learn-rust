param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

# Walk up from the .rs file to find the nearest Cargo.toml
$dir = Split-Path -Parent $FilePath
while ($dir) {
    $cargoToml = Join-Path $dir 'Cargo.toml'
    if (Test-Path $cargoToml) {
        $content = Get-Content $cargoToml -Raw
        # Extract [package] name = "..."
        if ($content -match '\[package\][\s\S]*?name\s*=\s*"([^"]+)"') {
            $packageName = $Matches[1]
            Write-Host "━━━ cargo test -p $packageName ━━━" -ForegroundColor Cyan
            $args = @('test', '-p', $packageName)
            if ($ExtraArgs) { $args += $ExtraArgs }
            & cargo $args
            exit $LASTEXITCODE
        }
        Write-Warning "Found $cargoToml but no [package] name field"
    }
    $dir = Split-Path -Parent $dir
}

Write-Error "Could not find a Cargo.toml with [package] name for: $FilePath"
exit 1
