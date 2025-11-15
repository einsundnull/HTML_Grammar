# PowerShell script to add page-break protection to all files

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse | Where-Object { $_.Name -notlike "index.html" -or $_.Directory.Name -ne "Grammar" }

Write-Host "=== ADDING PAGE-BREAK PROTECTION ===" -ForegroundColor Green
Write-Host ""

$stats = @{
    'TotalProcessed' = 0
    'AlreadyProtected' = 0
    'NeedsUpdate' = 0
    'Updated' = 0
}

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    # Skip index pages
    if ($file.Name -eq "index.html") {
        continue
    }

    # Skip files without tables
    if ($content -notmatch '<table') {
        continue
    }

    $stats['TotalProcessed']++

    # Check if already has table protection
    $hasTableProtection = $content -match '@media print.*?table\s*\{[^}]*page-break-inside:\s*avoid'

    if ($hasTableProtection) {
        $stats['AlreadyProtected']++
        Write-Host "  [OK] $relativePath - Already protected" -ForegroundColor Green
        continue
    }

    $stats['NeedsUpdate']++
    Write-Host "  [UPDATING] $relativePath" -ForegroundColor Yellow

    # Check if @media print exists
    if ($content -match '@media print') {
        # Add table protection inside existing @media print
        $pageBreakCSS = @'

            table {
                page-break-inside: avoid !important;
                break-inside: avoid-page !important;
                table-layout: fixed !important;
            }

            tr {
                page-break-inside: avoid !important;
                break-inside: avoid-page !important;
            }

            h1, h2, h3 {
                page-break-after: avoid !important;
                break-after: avoid-page !important;
                page-break-inside: avoid !important;
            }
'@

        # Insert after @media print {
        $content = $content -replace '(@media print\s*\{)', "`$1$pageBreakCSS"
    } else {
        # Add complete @media print block
        $printCSS = @'

        /* Print Layout - No Page Breaks */
        @media print {
            body {
                background-color: white;
                color: black;
            }

            table {
                page-break-inside: avoid !important;
                break-inside: avoid-page !important;
                table-layout: fixed !important;
            }

            tr {
                page-break-inside: avoid !important;
                break-inside: avoid-page !important;
            }

            h1, h2, h3 {
                page-break-after: avoid !important;
                break-after: avoid-page !important;
                page-break-inside: avoid !important;
            }

            .global-nav, .nav, .toggle-btn, .style-toggle-btn, .print-buttons {
                display: none !important;
            }

            th {
                background-color: #cccccc !important;
                color: black !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
        }
'@
        # Insert before </style>
        $content = $content -replace '(</style>)', "$printCSS`n`$1"
    }

    # Save with UTF-8 without BOM
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)

    $stats['Updated']++
    Write-Host "  [FIXED] $relativePath" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total files processed: $($stats['TotalProcessed'])" -ForegroundColor White
Write-Host "Already protected: $($stats['AlreadyProtected'])" -ForegroundColor Green
Write-Host "Needed update: $($stats['NeedsUpdate'])" -ForegroundColor Yellow
Write-Host "Updated: $($stats['Updated'])" -ForegroundColor Green
Write-Host ""

if ($stats['Updated'] -gt 0) {
    Write-Host "✅ Page-break protection added successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Protection includes:" -ForegroundColor Cyan
    Write-Host "  • Tables won't be split across pages" -ForegroundColor White
    Write-Host "  • Headers stay with their tables" -ForegroundColor White
    Write-Host "  • Table rows stay together" -ForegroundColor White
    Write-Host "  • Modern and legacy CSS properties" -ForegroundColor White
} else {
    Write-Host "✅ All files already have page-break protection!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
