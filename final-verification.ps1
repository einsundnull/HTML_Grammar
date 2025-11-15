# Final verification of all buttons

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse

Write-Host "=== FINAL VERIFICATION ===" -ForegroundColor Green
Write-Host ""

$stats = @{
    'ContentPages' = 0
    'IndexPages' = 0
    'ContentWithStyleToggle' = 0
    'ContentWithPrintButtons' = 0
    'ContentWithBothButtons' = 0
}

$report = @()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    $isIndexPage = $file.Name -eq "index.html"
    $isMainIndex = $file.Name -eq "index.html" -and $file.Directory.Name -eq "Grammar"

    # Skip main index
    if ($isMainIndex) {
        continue
    }

    if ($isIndexPage) {
        $stats['IndexPages']++
    } else {
        $stats['ContentPages']++

        $hasStyleToggle = $content -match 'style-toggle-btn'
        $hasPrintButtons = $content -match 'print-buttons'

        if ($hasStyleToggle) {
            $stats['ContentWithStyleToggle']++
        }

        if ($hasPrintButtons) {
            $stats['ContentWithPrintButtons']++
        }

        if ($hasStyleToggle -and $hasPrintButtons) {
            $stats['ContentWithBothButtons']++
        }

        $status = ""
        if ($hasStyleToggle -and $hasPrintButtons) {
            $status = "✅ COMPLETE"
        } elseif ($hasStyleToggle -or $hasPrintButtons) {
            $status = "⚠️  PARTIAL"
        } else {
            $status = "❌ MISSING"
        }

        $report += [PSCustomObject]@{
            File = $relativePath
            StyleToggle = if($hasStyleToggle){"✅"}else{"❌"}
            PrintButtons = if($hasPrintButtons){"✅"}else{"❌"}
            Status = $status
        }
    }
}

Write-Host "=== STATISTICS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Content Pages: $($stats['ContentPages'])" -ForegroundColor White
Write-Host "Total Index Pages: $($stats['IndexPages'])" -ForegroundColor White
Write-Host ""
Write-Host "Content Pages with Style Toggle: $($stats['ContentWithStyleToggle'])/$($stats['ContentPages'])" -ForegroundColor $(if($stats['ContentWithStyleToggle'] -eq $stats['ContentPages']){'Green'}else{'Yellow'})
Write-Host "Content Pages with Print Buttons: $($stats['ContentWithPrintButtons'])/$($stats['ContentPages'])" -ForegroundColor $(if($stats['ContentWithPrintButtons'] -eq $stats['ContentPages']){'Green'}else{'Yellow'})
Write-Host "Content Pages with BOTH: $($stats['ContentWithBothButtons'])/$($stats['ContentPages'])" -ForegroundColor $(if($stats['ContentWithBothButtons'] -eq $stats['ContentPages']){'Green'}else{'Yellow'})
Write-Host ""

# Show files missing buttons
$incomplete = $report | Where-Object { $_.Status -ne "✅ COMPLETE" }
if ($incomplete.Count -gt 0) {
    Write-Host "=== INCOMPLETE FILES ===" -ForegroundColor Yellow
    Write-Host ""
    $incomplete | Format-Table -AutoSize
} else {
    Write-Host "=== ✅ ALL CONTENT PAGES HAVE BOTH BUTTONS! ===" -ForegroundColor Green
}

Write-Host ""
Write-Host "Verification complete!" -ForegroundColor Green
