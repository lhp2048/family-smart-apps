param(
    [Parameter(Mandatory = $true)]
    [string[]]$Paths
)

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$files = @()

foreach ($pattern in $Paths) {
    if (Test-Path -LiteralPath $pattern -PathType Leaf) {
        $files += (Resolve-Path -LiteralPath $pattern).Path
        continue
    }
    $parent = Split-Path -Parent $pattern
    $leaf = Split-Path -Leaf $pattern
    if ([string]::IsNullOrWhiteSpace($parent)) {
        $parent = (Get-Location).Path
    }
    if (Test-Path -LiteralPath $parent) {
        $files += Get-ChildItem -LiteralPath $parent -Filter $leaf -File | ForEach-Object { $_.FullName }
    }
}

$files = $files | Select-Object -Unique

foreach ($path in $files) {
    $raw = [System.IO.File]::ReadAllText($path)
    $normalized = $raw -replace "`r`n", "`n" -replace "`r", "`n"
    if (-not $normalized.EndsWith("`n")) {
        $normalized += "`n"
    }
    [System.IO.File]::WriteAllText($path, $normalized, $utf8NoBom)
    Write-Output "LF: $path"
}
