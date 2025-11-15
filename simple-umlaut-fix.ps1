# Simple direct text replacement for broken umlauts

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"

$problematicFiles = @(
    "Directions\option-b\directions.html",
    "Directions\option-b\index.html",
    "Time\option-a\clock.html",
    "Time\option-a\index.html",
    "Time\option-a\vocabulary.html",
    "Time\option-b\index.html",
    "Time\option-b\time.html"
)

Write-Host "=== SIMPLE UMLAUT FIX ===" -ForegroundColor Green
Write-Host ""

$replacements = @{
    'f�nf' = 'fünf'
    'zw�lf' = 'zwölf'
    'drei�ig' = 'dreißig'
    'f�r' = 'für'
    '�ber' = 'über'
    'Uhrzeit' = 'Uhrzeit'
    'Geb�ude' = 'Gebäude'
    'M�rz' = 'März'
    '�ndern' = 'ändern'
}

foreach ($relPath in $problematicFiles) {
    $filePath = Join-Path $baseDir $relPath

    if (-not (Test-Path $filePath)) {
        Write-Host "  [SKIP] $relPath" -ForegroundColor Yellow
        continue
    }

    Write-Host "  [FIXING] $relPath" -ForegroundColor Cyan

    # Read content as string
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::Default)

    $fixed = 0
    foreach ($key in $replacements.Keys) {
        if ($content -match [regex]::Escape($key)) {
            $content = $content -replace [regex]::Escape($key), $replacements[$key]
            $fixed++
        }
    }

    # Save as UTF-8 without BOM
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)

    Write-Host "  [DONE] Made $fixed replacements" -ForegroundColor Green
}

Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
