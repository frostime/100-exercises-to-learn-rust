param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

$wsFolder = $env:WORKSPACE_FOLDER
if (-not $wsFolder) {
    $wsFolder = (Get-Location).Path
}

# Compute relative path from workspace root
$relPath = [System.IO.Path]::GetRelativePath($wsFolder, $FilePath).Replace('\', '/')

Write-Host "━━━ Solution for: $relPath ━━━" -ForegroundColor Cyan

# Get solution content from origin/solutions branch
$content = & git show "origin/solutions:$relPath" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to read '$relPath' from origin/solutions branch."
    Write-Host "Does this file exist on that branch?" -ForegroundColor Yellow
    exit 1
}

# Write to temp file with same extension for syntax highlighting
$ext = [System.IO.Path]::GetExtension($FilePath)
if (-not $ext) { $ext = ".txt" }
$tmpFile = [System.IO.Path]::Combine(
    [System.IO.Path]::GetTempPath(),
    "solution_$([System.IO.Path]::GetFileNameWithoutExtension($FilePath))_$PID$ext"
)
[System.IO.File]::WriteAllText($tmpFile, ($content -join "`n"))

Write-Host ""
Write-Host "Solution saved to:" -ForegroundColor Green
Write-Host "  $tmpFile" -ForegroundColor Yellow
Write-Host ""
Write-Host "Click the path above to open it in a read-only tab." -ForegroundColor DarkGray
