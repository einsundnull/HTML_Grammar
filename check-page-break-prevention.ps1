# PowerShell script to check page-break prevention in all HTML files

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse | Where-Object { $_.Name -notlike "index.html" -or $_.Directory.Name -ne "Grammar" }

Write-Host "=== CHECKING PAGE-BREAK PREVENTION ===" -ForegroundColor Green
Write-Host ""

$stats = @{
    'TotalFiles' = 0
    'HasPrintCSS' = 0
    'HasTablePageBreak' = 0
    'HasHeaderPageBreak' = 0
    'HasBoth' = 0
    'MissingProtection' = 0
}

$missingProtection = @()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    # Skip index pages
    if ($file.Name -eq "index.html") {
        continue
    }

    $stats['TotalFiles']++

    # Check if file has tables
    $hasTables = $content -match '<table'

    if (-not $hasTables) {
        continue
    }

    # Check for @media print
    $hasPrintCSS = $content -match '@media print'

    if ($hasPrintCSS) {
        $stats['HasPrintCSS']++
    }

    # Check for table page-break prevention
    $hasTablePageBreak = $content -match 'table\s*\{[^}]*page-break-inside:\s*avoid' -or
                         $content -match 'table\s*\{[^}]*break-inside:\s*avoid'

    if ($hasTablePageBreak) {
        $stats['HasTablePageBreak']++
    }

    # Check for header page-break prevention (h1, h2, h3)
    $hasHeaderPageBreak = $content -match 'h[123][^}]*\{[^}]*page-break-after:\s*avoid' -or
                          $content -match 'h[123][^}]*\{[^}]*break-after:\s*avoid' -or
                          ($content -match '@media print' -and $content -match 'h[123].*page-break-after:\s*avoid')

    if ($hasHeaderPageBreak) {
        $stats['HasHeaderPageBreak']++
    }

    # Check if has both protections
    if ($hasTablePageBreak -and $hasHeaderPageBreak) {
        $stats['HasBoth']++
    }

    # Report missing protection
    if (-not $hasTablePageBreak -or -not $hasHeaderPageBreak) {
        $stats['MissingProtection']++

        $issues = @()
        if (-not $hasPrintCSS) { $issues += "No @media print" }
        if (-not $hasTablePageBreak) { $issues += "No table protection" }
        if (-not $hasHeaderPageBreak) { $issues += "No header protection" }

        $missingProtection += [PSCustomObject]@{
            File = $relativePath
            PrintCSS = if($hasPrintCSS){"✅"}else{"❌"}
            TableProtection = if($hasTablePageBreak){"✅"}else{"❌"}
            HeaderProtection = if($hasHeaderPageBreak){"✅"}else{"❌"}
            Issues = $issues -join ", "
        }
    }
}

Write-Host "=== STATISTICS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total files with tables: $($stats['TotalFiles'])" -ForegroundColor White
Write-Host "Files with @media print CSS: $($stats['HasPrintCSS'])" -ForegroundColor White
Write-Host "Files with table page-break protection: $($stats['HasTablePageBreak'])" -ForegroundColor White
Write-Host "Files with header page-break protection: $($stats['HasHeaderPageBreak'])" -ForegroundColor White
Write-Host "Files with BOTH protections: $($stats['HasBoth'])" -ForegroundColor $(if($stats['HasBoth'] -eq $stats['TotalFiles']){'Green'}else{'Yellow'})
Write-Host "Files MISSING protection: $($stats['MissingProtection'])" -ForegroundColor $(if($stats['MissingProtection'] -gt 0){'Red'}else{'Green'})
Write-Host ""

if ($missingProtection.Count -gt 0) {
    Write-Host "=== FILES MISSING PAGE-BREAK PROTECTION ===" -ForegroundColor Red
    Write-Host ""
    $missingProtection | Format-Table -AutoSize -Wrap
    Write-Host ""
    Write-Host "These files need page-break prevention to avoid:" -ForegroundColor Yellow
    Write-Host "  1. Tables being split across pages" -ForegroundColor Yellow
    Write-Host "  2. Headers being separated from their tables" -ForegroundColor Yellow
} else {
    Write-Host "=== ✅ ALL FILES HAVE COMPLETE PAGE-BREAK PROTECTION! ===" -ForegroundColor Green
}

Write-Host ""
Write-Host "Check complete!" -ForegroundColor Green
