# PowerShell script to fix broken umlauts in specific files

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"

# Files with encoding issues
$problematicFiles = @(
    "Directions\option-b\directions.html",
    "Directions\option-b\index.html",
    "Time\option-a\clock.html",
    "Time\option-a\index.html",
    "Time\option-a\vocabulary.html",
    "Time\option-b\index.html",
    "Time\option-b\time.html"
)

Write-Host "=== FIXING BROKEN UMLAUTS ===" -ForegroundColor Green
Write-Host ""

$stats = @{
    'FilesFixed' = 0
    'ReplacementsMade' = 0
}

foreach ($relPath in $problematicFiles) {
    $filePath = Join-Path $baseDir $relPath

    if (-not (Test-Path $filePath)) {
        Write-Host "  [SKIP] File not found: $relPath" -ForegroundColor Yellow
        continue
    }

    Write-Host "  [PROCESSING] $relPath" -ForegroundColor Cyan

    # Read file as bytes to properly handle encoding
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $content = [System.Text.Encoding]::UTF8.GetString($bytes)

    $originalContent = $content
    $replacements = 0

    # Fix common broken umlaut patterns
    # These are the broken representations we need to fix
    $content = $content -replace '�', 'ü'  # Most common: � should be ü

    # Count how many times we replaced the character
    $tempCount = ($originalContent.ToCharArray() | Where-Object {$_ -eq '�'}).Count
    if ($tempCount -gt 0) {
        $replacements += $tempCount
        Write-Host "    Replaced $tempCount broken characters" -ForegroundColor Yellow
    }

    # Also check for other potential issues
    # Sometimes ö appears as different broken chars
    if ($content -match '[^\x00-\x7F\u00C0-\u017F\u0152-\u0153\u0160-\u0161\u0178\u017D-\u017E\u20AC]') {
        Write-Host "    WARNING: File may contain other non-standard characters" -ForegroundColor Yellow
    }

    if ($content -ne $originalContent) {
        # Save as UTF-8 without BOM
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)

        $stats['FilesFixed']++
        $stats['ReplacementsMade'] += $replacements
        Write-Host "  [FIXED] $relPath - Made $replacements replacements" -ForegroundColor Green
    } else {
        Write-Host "  [OK] $relPath - No broken characters found" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files fixed: $($stats['FilesFixed'])" -ForegroundColor Green
Write-Host "Total replacements: $($stats['ReplacementsMade'])" -ForegroundColor Green
Write-Host ""

if ($stats['FilesFixed'] -gt 0) {
    Write-Host "Umlauts have been repaired!" -ForegroundColor Green
    Write-Host "All affected files now use proper UTF-8 encoding" -ForegroundColor White
} else {
    Write-Host "No broken umlauts found" -ForegroundColor Green
}

Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
