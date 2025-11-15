# PowerShell script to fix remaining files without toggle buttons

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"

# Files that need manual fixing
$filesToFix = @(
    "Article\Article.html"
)

Write-Host "=== FIXING REMAINING FILES ===" -ForegroundColor Green
Write-Host ""

foreach ($relPath in $filesToFix) {
    $filePath = Join-Path $baseDir $relPath

    if (-not (Test-Path $filePath)) {
        Write-Host "  [SKIP] File not found: $relPath" -ForegroundColor Yellow
        continue
    }

    Write-Host "  [PROCESSING] $relPath" -ForegroundColor Cyan

    $content = Get-Content -Path $filePath -Raw -Encoding UTF8
    $needsUpdate = $false

    # Check what's missing
    $hasToggleBtn = $content -match 'toggle-btn'
    $hasStyleToggle = $content -match 'style-toggle-btn'
    $hasPrintButtons = $content -match 'print-buttons'

    # Add compact mode button if missing
    if (-not $hasToggleBtn) {
        Write-Host "    Adding compact mode button..." -ForegroundColor Yellow

        # Add CSS for toggle button
        if ($content -notmatch '\.toggle-btn') {
            $toggleBtnCSS = @'

        .toggle-btn {
            background-color: #95a5a6;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            transition: background-color 0.3s;
        }
        .toggle-btn:hover {
            background-color: #7f8c8d;
        }
'@
            $content = $content -replace '(</style>)', "$toggleBtnCSS`n`$1"
        }

        # Add compact mode CSS
        if ($content -notmatch 'compact-mode') {
            $compactCSS = @'

        /* Compact Mode */
        body.compact-mode table {
            font-size: 0.9em;
        }
        body.compact-mode th, body.compact-mode td {
            padding: 8px;
        }

        /* Extra Compact Mode */
        body.extra-compact-mode table {
            font-size: 0.75em;
        }
        body.extra-compact-mode th, body.extra-compact-mode td {
            padding: 4px 6px;
        }
'@
            $content = $content -replace '(</style>)', "$compactCSS`n`$1"
        }

        # Find where to insert the button - after h1
        if ($content -match '<h1[^>]*>') {
            $buttonHTML = @'

    <div style="text-align: center; margin: 15px 0;">
        <button class="toggle-btn" onclick="toggleCompactMode()">&#128202; Kompakt-Modus</button>
    </div>
'@
            $content = $content -replace '(<h1[^>]*>[^<]*</h1>)', "`$1$buttonHTML"
        }

        # Add JavaScript function
        if ($content -notmatch 'function toggleCompactMode') {
            $toggleJS = @'

    <script>
        function toggleCompactMode() {
            const body = document.body;
            const button = document.querySelector('.toggle-btn');

            if (!body.classList.contains('compact-mode') && !body.classList.contains('extra-compact-mode')) {
                body.classList.add('compact-mode');
                button.innerHTML = '&#128202; Extra-Kompakt-Modus';
            } else if (body.classList.contains('compact-mode')) {
                body.classList.remove('compact-mode');
                body.classList.add('extra-compact-mode');
                button.innerHTML = '&#128202; Normal-Modus';
            } else {
                body.classList.remove('extra-compact-mode');
                button.innerHTML = '&#128202; Kompakt-Modus';
            }
        }
    </script>
'@
            $content = $content -replace '(</body>)', "$toggleJS`n`$1"
        }

        $needsUpdate = $true
    }

    # Add style toggle button
    if (-not $hasStyleToggle -and ($hasToggleBtn -or $needsUpdate)) {
        Write-Host "    Adding style toggle button..." -ForegroundColor Yellow

        # Add CSS
        if ($content -notmatch '\.style-toggle-btn') {
            $styleCSS = @'

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

        /* Newspaper Style */
        body.newspaper-style {
            background-color: #f8f8f8;
            color: #1a1a1a;
        }
        body.newspaper-style h1, body.newspaper-style h2, body.newspaper-style h3 {
            color: #000000;
        }
        body.newspaper-style th {
            background-color: #444444;
        }
        body.newspaper-style td {
            border: 1px solid #666666;
        }
'@
            $content = $content -replace '(</style>)', "$styleCSS`n`$1"
        }

        # Add button after toggle-btn
        $content = $content -replace '(<button class="toggle-btn"[^>]*>[^<]*</button>)', "`$1`n        <button class=`"style-toggle-btn`" onclick=`"toggleStyle()`">&#128214; Buch-Modus</button>"

        # Add JavaScript
        if ($content -notmatch 'function toggleStyle') {
            $styleJS = @'

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
            $content = $content -replace '(</script>)', "$styleJS`n`$1"
        }

        $needsUpdate = $true
    }

    # Add print buttons
    if (-not $hasPrintButtons -and ($hasToggleBtn -or $needsUpdate)) {
        Write-Host "    Adding print buttons..." -ForegroundColor Yellow

        # Add CSS
        if ($content -notmatch '\.print-buttons') {
            $printCSS = @'

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
            $content = $content -replace '(</style>)', "$printCSS`n`$1"
        }

        # Add buttons HTML
        $printHTML = @'

        <div class="print-buttons">
            <button class="print-btn normal" onclick="printMode('normal')">&#128424; Drucken Normal</button>
            <button class="print-btn compact" onclick="printMode('compact')">&#128424; Drucken Kompakt</button>
            <button class="print-btn extra-compact" onclick="printMode('extra-compact')">&#128424; Drucken Extra-Kompakt</button>
        </div>
'@

        if ($content -match '<button class="style-toggle-btn"') {
            $content = $content -replace '(<button class="style-toggle-btn"[^>]*>[^<]*</button>)', "`$1$printHTML"
        } elseif ($content -match '<button class="toggle-btn"') {
            $content = $content -replace '(<button class="toggle-btn"[^>]*>[^<]*</button>)', "`$1$printHTML"
        }

        # Add JavaScript
        if ($content -notmatch 'function printMode') {
            $printJS = @'

        function printMode(mode) {
            document.body.classList.remove('compact-mode', 'extra-compact-mode');
            if (mode === 'compact') {
                document.body.classList.add('compact-mode');
            } else if (mode === 'extra-compact') {
                document.body.classList.add('extra-compact-mode');
            }
            window.print();
        }
'@
            $content = $content -replace '(</script>)', "$printJS`n`$1"
        }

        $needsUpdate = $true
    }

    # Save if needed
    if ($needsUpdate) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
        Write-Host "  [FIXED] $relPath" -ForegroundColor Green
    } else {
        Write-Host "  [OK] $relPath - Already has all buttons" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "All remaining files processed!" -ForegroundColor Green
