# Final Verification Script for all Grammar files

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse

Write-Host "=== FINAL VERIFICATION ===" -ForegroundColor Green
Write-Host ""

$results = @{
    'TotalFiles' = $allFiles.Count
    'UTF8_OK' = 0
    'UTF8_BOM' = 0
    'HasGlobalNav' = 0
    'MissingGlobalNav' = 0
    'HasPrintCSS' = 0
    'MissingPrintCSS' = 0
    'HasPageBreakPrevention' = 0
    'MissingPageBreakPrevention' = 0
}

$issues = @()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    # Check 1: UTF-8 without BOM
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $hasBOM = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

    if ($hasBOM) {
        $results['UTF8_BOM']++
        $issues += "❌ UTF-8 BOM: $relativePath"
    } else {
        $results['UTF8_OK']++
    }

    # Check 2: Global Navigation Header (skip main index.html)
    $isMainIndex = ($file.Name -eq "index.html" -and $file.Directory.Name -eq "Grammar")

    if (-not $isMainIndex) {
        if ($content -match '<div class="global-nav">') {
            $results['HasGlobalNav']++
        } else {
            $results['MissingGlobalNav']++
            $issues += "❌ Missing global-nav: $relativePath"
        }
    }

    # Check 3: Print CSS exists
    if ($content -match '@media print') {
        $results['HasPrintCSS']++

        # Check 4: Page break prevention
        if ($content -match 'page-break-inside:\s*avoid' -or $content -match 'break-inside:\s*avoid') {
            $results['HasPageBreakPrevention']++
        } else {
            $results['MissingPageBreakPrevention']++
            $issues += "⚠️  Missing page-break prevention: $relativePath"
        }
    } else {
        $results['MissingPrintCSS']++
        if ($content -match '<table') {
            $issues += "⚠️  Missing print CSS (has tables): $relativePath"
        }
    }
}

Write-Host "=== VERIFICATION RESULTS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Files: $($results['TotalFiles'])" -ForegroundColor White
Write-Host ""
Write-Host "1. UTF-8 Encoding:" -ForegroundColor Yellow
Write-Host "   ✅ UTF-8 without BOM: $($results['UTF8_OK'])" -ForegroundColor Green
if ($results['UTF8_BOM'] -gt 0) {
    Write-Host "   ❌ UTF-8 with BOM: $($results['UTF8_BOM'])" -ForegroundColor Red
}
Write-Host ""
Write-Host "2. Global Navigation Header:" -ForegroundColor Yellow
Write-Host "   ✅ Has global-nav: $($results['HasGlobalNav'])" -ForegroundColor Green
if ($results['MissingGlobalNav'] -gt 0) {
    Write-Host "   ❌ Missing global-nav: $($results['MissingGlobalNav'])" -ForegroundColor Red
}
Write-Host ""
Write-Host "3. Print CSS:" -ForegroundColor Yellow
Write-Host "   ✅ Has print CSS: $($results['HasPrintCSS'])" -ForegroundColor Green
if ($results['MissingPrintCSS'] -gt 0) {
    Write-Host "   ⚠️  Missing print CSS: $($results['MissingPrintCSS'])" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "4. Page Break Prevention:" -ForegroundColor Yellow
Write-Host "   ✅ Has page-break prevention: $($results['HasPageBreakPrevention'])" -ForegroundColor Green
if ($results['MissingPageBreakPrevention'] -gt 0) {
    Write-Host "   ⚠️  Missing page-break prevention: $($results['MissingPageBreakPrevention'])" -ForegroundColor Yellow
}
Write-Host ""

if ($issues.Count -gt 0) {
    Write-Host "=== ISSUES FOUND ===" -ForegroundColor Red
    Write-Host ""
    foreach ($issue in $issues) {
        Write-Host "  $issue" -ForegroundColor Yellow
    }
    Write-Host ""
} else {
    Write-Host "=== ✅ ALL CHECKS PASSED! ===" -ForegroundColor Green
    Write-Host ""
}

# Summary
$successRate = [math]::Round((($results['UTF8_OK'] + $results['HasGlobalNav'] + $results['HasPrintCSS'] + $results['HasPageBreakPrevention']) / ($results['TotalFiles'] * 4)) * 100, 1)
Write-Host "Overall Success Rate: $successRate%" -ForegroundColor Cyan
