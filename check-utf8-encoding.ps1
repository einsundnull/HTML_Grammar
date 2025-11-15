# PowerShell script to check UTF-8 encoding in all HTML files

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse

Write-Host "=== CHECKING UTF-8 ENCODING ===" -ForegroundColor Green
Write-Host ""

$stats = @{
    'TotalFiles' = 0
    'UTF8_NoBOM' = 0
    'UTF8_WithBOM' = 0
    'HasMetaCharset' = 0
    'MissingMetaCharset' = 0
    'OtherEncoding' = 0
}

$issues = @()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")
    $stats['TotalFiles']++

    # Read file bytes to check BOM
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)

    # Check for BOM
    $hasBOM = $false
    $encoding = "Unknown"

    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $hasBOM = $true
        $encoding = "UTF-8 with BOM"
        $stats['UTF8_WithBOM']++
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        $encoding = "UTF-16 LE"
        $stats['OtherEncoding']++
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        $encoding = "UTF-16 BE"
        $stats['OtherEncoding']++
    } else {
        # No BOM, likely UTF-8 without BOM or ASCII
        $encoding = "UTF-8 without BOM"
        $stats['UTF8_NoBOM']++
    }

    # Check for meta charset in content
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $hasMetaCharset = $content -match '<meta\s+charset="UTF-8"' -or $content -match '<meta\s+[^>]*charset\s*=\s*"?UTF-8"?'

    if ($hasMetaCharset) {
        $stats['HasMetaCharset']++
    } else {
        $stats['MissingMetaCharset']++
    }

    # Report issues
    if ($hasBOM -or -not $hasMetaCharset -or $encoding -eq "Unknown" -or $stats['OtherEncoding'] -gt 0) {
        $problemList = @()
        if ($hasBOM) { $problemList += "Has BOM" }
        if (-not $hasMetaCharset) { $problemList += "Missing meta charset" }
        if ($encoding -match "UTF-16") { $problemList += "Wrong encoding" }

        if ($problemList.Count -gt 0) {
            $issues += [PSCustomObject]@{
                File = $relativePath
                Encoding = $encoding
                MetaCharset = if($hasMetaCharset){"✅"}else{"❌"}
                Problems = $problemList -join ", "
            }
        }
    }
}

Write-Host "=== STATISTICS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total files: $($stats['TotalFiles'])" -ForegroundColor White
Write-Host ""
Write-Host "Encoding:" -ForegroundColor Yellow
Write-Host "  UTF-8 without BOM (✅ GOOD): $($stats['UTF8_NoBOM'])" -ForegroundColor Green
Write-Host "  UTF-8 with BOM (⚠️  WARNING): $($stats['UTF8_WithBOM'])" -ForegroundColor $(if($stats['UTF8_WithBOM'] -gt 0){'Yellow'}else{'Green'})
Write-Host "  Other encoding (❌ BAD): $($stats['OtherEncoding'])" -ForegroundColor $(if($stats['OtherEncoding'] -gt 0){'Red'}else{'Green'})
Write-Host ""
Write-Host "Meta Charset Tag:" -ForegroundColor Yellow
Write-Host "  Has charset=\"UTF-8\": $($stats['HasMetaCharset'])" -ForegroundColor Green
Write-Host "  Missing charset: $($stats['MissingMetaCharset'])" -ForegroundColor $(if($stats['MissingMetaCharset'] -gt 0){'Red'}else{'Green'})
Write-Host ""

if ($issues.Count -gt 0) {
    Write-Host "=== FILES WITH ENCODING ISSUES ===" -ForegroundColor Red
    Write-Host ""
    $issues | Format-Table -AutoSize -Wrap
    Write-Host ""
    Write-Host "Recommended actions:" -ForegroundColor Yellow
    Write-Host "  1. Remove BOM from all files" -ForegroundColor White
    Write-Host "  2. Add <meta charset=`"UTF-8`"> to files missing it" -ForegroundColor White
    Write-Host "  3. Convert non-UTF-8 files to UTF-8 without BOM" -ForegroundColor White
} else {
    Write-Host "=== ✅ ALL FILES HAVE CORRECT UTF-8 ENCODING! ===" -ForegroundColor Green
}

Write-Host ""
Write-Host "Check complete!" -ForegroundColor Green
