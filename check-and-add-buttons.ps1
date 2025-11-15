# PowerShell script to check and add Book Mode and Print Buttons to all pages

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse | Where-Object { $_.Name -notlike "index.html" -or $_.Directory.Name -ne "Grammar" }

Write-Host "=== CHECKING ALL PAGES FOR BUTTONS ===" -ForegroundColor Green
Write-Host "Total files to check: $($allFiles.Count)" -ForegroundColor Cyan
Write-Host ""

$stats = @{
    'TotalFiles' = $allFiles.Count
    'HasStyleToggle' = 0
    'MissingStyleToggle' = 0
    'HasPrintButtons' = 0
    'MissingPrintButtons' = 0
    'FilesFixed' = 0
}

$fixedFiles = @()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $needsUpdate = $false

    # Skip if it's a main index page without tables
    $isIndexPage = $file.Name -eq "index.html"

    # Check for style-toggle button
    $hasStyleToggle = $content -match 'style-toggle-btn'
    $hasToggleBtn = $content -match 'toggle-btn'

    # Check for print buttons
    $hasPrintButtons = $content -match 'print-buttons'

    if ($hasStyleToggle) {
        $stats['HasStyleToggle']++
    } else {
        $stats['MissingStyleToggle']++
        Write-Host "  [MISSING STYLE TOGGLE] $relativePath" -ForegroundColor Yellow
    }

    if ($hasPrintButtons) {
        $stats['HasPrintButtons']++
    } else {
        $stats['MissingPrintButtons']++
        Write-Host "  [MISSING PRINT BUTTONS] $relativePath" -ForegroundColor Yellow
    }

    # Add missing buttons
    if (-not $hasStyleToggle -and $hasToggleBtn) {
        Write-Host "  [ADDING STYLE TOGGLE] $relativePath" -ForegroundColor Cyan

        # Add CSS for style-toggle-btn if missing
        if ($content -notmatch '\.style-toggle-btn') {
            $styleToggleCSS = @'

        /* Style Toggle Button */
        .style-toggle-btn {
            background-color: #444444;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            margin-left: 15px;
            transition: background-color 0.3s;
        }
        .style-toggle-btn:hover {
            background-color: #222222;
        }
'@
            $content = $content -replace '(</style>)', "$styleToggleCSS`n`$1"
        }

        # Add newspaper-style CSS if missing
        if ($content -notmatch 'body\.newspaper-style') {
            $newspaperCSS = @'

        /* Book/Newspaper Style - Black & White */
        body.newspaper-style {
            background-color: #f8f8f8;
            color: #1a1a1a;
        }
        body.newspaper-style h1, body.newspaper-style h2, body.newspaper-style h3 {
            color: #000000;
        }
        body.newspaper-style h2 {
            background-color: #333333;
            color: #ffffff;
        }
        body.newspaper-style th {
            background-color: #444444;
            color: white;
        }
        body.newspaper-style table {
            background-color: #ffffff;
        }
        body.newspaper-style td {
            border: 1px solid #666666;
        }
        body.newspaper-style .nav {
            background-color: #2c2c2c;
        }
'@
            $content = $content -replace '(</style>)', "$newspaperCSS`n`$1"
        }

        # Add style-toggle button HTML after toggle-btn
        $content = $content -replace '(<button class="toggle-btn"[^>]*>[^<]*</button>)', "`$1`n        <button class=`"style-toggle-btn`" onclick=`"toggleStyle()`">&#128214; Buch-Modus</button>"

        # Add toggleStyle() JavaScript function if missing
        if ($content -notmatch 'function toggleStyle') {
            $toggleStyleJS = @'

        function toggleStyle() {
            document.body.classList.toggle('newspaper-style');
            const button = document.querySelector('.style-toggle-btn');
            if (document.body.classList.contains('newspaper-style')) {
                button.innerHTML = '&#127912; Farb-Modus';
            } else {
                button.innerHTML = '&#128214; Buch-Modus';
            }
        }
'@
            $content = $content -replace '(</script>)', "$toggleStyleJS`n`$1"
        }

        $needsUpdate = $true
    }

    if (-not $hasPrintButtons -and $hasToggleBtn) {
        Write-Host "  [ADDING PRINT BUTTONS] $relativePath" -ForegroundColor Cyan

        # Add CSS for print buttons if missing
        if ($content -notmatch '\.print-buttons') {
            $printButtonsCSS = @'

        /* Print Buttons */
        .print-buttons {
            text-align: center;
            margin: 15px 0;
            padding: 10px;
            display: flex;
            gap: 10px;
            justify-content: center;
            flex-wrap: wrap;
        }
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
        }
        .print-btn:hover {
            background-color: #2980b9;
        }
        .print-btn.compact {
            background-color: #27ae60;
        }
        .print-btn.compact:hover {
            background-color: #229954;
        }
        .print-btn.extra-compact {
            background-color: #e67e22;
        }
        .print-btn.extra-compact:hover {
            background-color: #d35400;
        }
        @media print {
            .print-buttons {
                display: none !important;
            }
        }
'@
            $content = $content -replace '(</style>)', "$printButtonsCSS`n`$1"
        }

        # Find where to insert print buttons - after style-toggle-btn or toggle-btn
        if ($content -match '<button class="style-toggle-btn"') {
            $printButtonsHTML = @'

        <div class="print-buttons">
            <button class="print-btn normal" onclick="printMode('normal')">&#128424; Drucken Normal</button>
            <button class="print-btn compact" onclick="printMode('compact')">&#128424; Drucken Kompakt</button>
            <button class="print-btn extra-compact" onclick="printMode('extra-compact')">&#128424; Drucken Extra-Kompakt</button>
        </div>
'@
            $content = $content -replace '(<button class="style-toggle-btn"[^>]*>[^<]*</button>)', "`$1$printButtonsHTML"
        } elseif ($content -match '<button class="toggle-btn"') {
            $printButtonsHTML = @'

        <div class="print-buttons">
            <button class="print-btn normal" onclick="printMode('normal')">&#128424; Drucken Normal</button>
            <button class="print-btn compact" onclick="printMode('compact')">&#128424; Drucken Kompakt</button>
            <button class="print-btn extra-compact" onclick="printMode('extra-compact')">&#128424; Drucken Extra-Kompakt</button>
        </div>
'@
            $content = $content -replace '(<button class="toggle-btn"[^>]*>[^<]*</button>)', "`$1$printButtonsHTML"
        }

        # Add printMode() JavaScript function if missing
        if ($content -notmatch 'function printMode') {
            $printModeJS = @'

        function printMode(mode) {
            // Remove all mode classes
            document.body.classList.remove('compact-mode', 'extra-compact-mode');

            // Apply the requested mode
            if (mode === 'compact') {
                document.body.classList.add('compact-mode');
            } else if (mode === 'extra-compact') {
                document.body.classList.add('extra-compact-mode');
            }

            // Print
            window.print();
        }
'@
            $content = $content -replace '(</script>)', "$printModeJS`n`$1"
        }

        $needsUpdate = $true
    }

    # Save if updates needed
    if ($needsUpdate) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        $stats['FilesFixed']++
        $fixedFiles += $relativePath
        Write-Host "  [FIXED] $relativePath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Green
Write-Host "Total files checked: $($stats['TotalFiles'])" -ForegroundColor Cyan
Write-Host ""
Write-Host "Style Toggle Buttons:" -ForegroundColor Yellow
Write-Host "  Has: $($stats['HasStyleToggle'])" -ForegroundColor Green
Write-Host "  Missing: $($stats['MissingStyleToggle'])" -ForegroundColor $(if($stats['MissingStyleToggle'] -gt 0){'Red'}else{'Green'})
Write-Host ""
Write-Host "Print Buttons:" -ForegroundColor Yellow
Write-Host "  Has: $($stats['HasPrintButtons'])" -ForegroundColor Green
Write-Host "  Missing: $($stats['MissingPrintButtons'])" -ForegroundColor $(if($stats['MissingPrintButtons'] -gt 0){'Red'}else{'Green'})
Write-Host ""
Write-Host "Files Fixed: $($stats['FilesFixed'])" -ForegroundColor Green

if ($fixedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Fixed Files:" -ForegroundColor Cyan
    $fixedFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
}

Write-Host ""
Write-Host "All checks completed!" -ForegroundColor Green
