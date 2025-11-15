# PowerShell script to fix print buttons and remove toggle button

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse

Write-Host "=== FIXING PRINT BUTTONS AND REMOVING TOGGLE ===" -ForegroundColor Green
Write-Host ""

$stats = @{
    'TotalProcessed' = 0
    'RemovedToggle' = 0
    'FixedPrintButtons' = 0
}

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    # Skip main index
    if ($file.Name -eq "index.html" -and $file.Directory.Name -eq "Grammar") {
        continue
    }

    # Skip index pages without content
    if ($file.Name -eq "index.html") {
        continue
    }

    $stats['TotalProcessed']++
    $needsUpdate = $false

    # 1. Remove toggle button HTML
    if ($content -match '<button class="toggle-btn"') {
        $content = $content -replace '<button class="toggle-btn"[^>]*>[^<]*</button>\s*', ''
        $stats['RemovedToggle']++
        Write-Host "  [REMOVED TOGGLE] $relativePath" -ForegroundColor Yellow
        $needsUpdate = $true
    }

    # 2. Replace print buttons with single extra-compact button
    if ($content -match '<div class="print-buttons">') {
        # Replace entire print-buttons div with single button
        $newPrintButton = '<button class="print-btn" onclick="window.print()">&#128424; Drucken</button>'

        $content = $content -replace '<div class="print-buttons">.*?</div>', $newPrintButton, 'Singleline'

        $stats['FixedPrintButtons']++
        Write-Host "  [FIXED PRINT] $relativePath" -ForegroundColor Cyan
        $needsUpdate = $true
    }

    # 3. Remove toggleCompactMode function
    if ($content -match 'function toggleCompactMode') {
        $content = $content -replace 'function toggleCompactMode\(\)\s*\{[^\}]*\}', ''
        $needsUpdate = $true
    }

    # 4. Remove printMode function (not needed anymore)
    if ($content -match 'function printMode') {
        $content = $content -replace 'function printMode\([^\)]*\)\s*\{[^\}]*\}', ''
        $needsUpdate = $true
    }

    # 5. Update CSS for single print button
    if ($content -match '\.print-buttons') {
        # Replace print-buttons CSS with simpler single button CSS
        $simplePrintCSS = @'

        /* Print Button */
        .print-btn {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            transition: background-color 0.3s;
            font-weight: 500;
            margin-left: 15px;
        }
        .print-btn:hover {
            background-color: #2980b9;
        }
        @media print {
            .print-btn {
                display: none !important;
            }
        }
'@
        # Remove old print-buttons CSS
        $content = $content -replace '/\* Print Buttons \*/.*?@media print \{.*?\.print-buttons \{.*?\}.*?\}', $simplePrintCSS, 'Singleline'
        $needsUpdate = $true
    }

    # 6. Remove toggle-btn CSS if exists
    if ($content -match '\.toggle-btn') {
        $content = $content -replace '/\* Compact Mode \*/.*?\.toggle-btn:hover \{.*?\}', '', 'Singleline'
        $needsUpdate = $true
    }

    # 7. Clean up extra whitespace in button area
    $content = $content -replace '<div style="text-align: center; margin: 15px 0;">\s*</div>', ''
    $content = $content -replace '<div style="text-align: center; margin: 15px 0;">\s*<button', '<div style="text-align: center; margin: 15px 0;"><button'

    # Save if updates were made
    if ($needsUpdate) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        Write-Host "  [UPDATED] $relativePath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files processed: $($stats['TotalProcessed'])" -ForegroundColor White
Write-Host "Toggle buttons removed: $($stats['RemovedToggle'])" -ForegroundColor Green
Write-Host "Print buttons fixed: $($stats['FixedPrintButtons'])" -ForegroundColor Green
Write-Host ""
Write-Host "Changes made:" -ForegroundColor Cyan
Write-Host "  - Removed all toggle buttons" -ForegroundColor White
Write-Host "  - Replaced 3 print buttons with 1 simple print button" -ForegroundColor White
Write-Host "  - Print button now directly calls window.print()" -ForegroundColor White
Write-Host "  - All pages stay in extra-compact mode" -ForegroundColor White
Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
