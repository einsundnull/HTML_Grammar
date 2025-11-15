# PowerShell script to check and fix all Grammar files

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse

Write-Host "=== CHECKING ALL HTML FILES ===" -ForegroundColor Green
Write-Host "Total files found: $($allFiles.Count)" -ForegroundColor Cyan
Write-Host ""

$issuesFound = @()
$fixedFiles = @()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")

    # Read file content
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $needsUpdate = $false

    # 1. Check UTF-8 encoding (check for BOM or encoding issues)
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $hasBOM = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

    if ($hasBOM) {
        Write-Host "  [UTF-8 BOM] $relativePath" -ForegroundColor Yellow
        $issuesFound += "$relativePath - UTF-8 BOM detected"
        $needsUpdate = $true
    }

    # 2. Check for global-nav header (skip main index.html)
    if ($file.Name -ne "index.html" -or $file.Directory.Name -ne "Grammar") {
        if ($content -notmatch '<div class="global-nav">') {
            Write-Host "  [NO HEADER] $relativePath" -ForegroundColor Yellow
            $issuesFound += "$relativePath - Missing global-nav header"

            # Add global-nav if missing (after <body> tag)
            if ($content -match '<body[^>]*>') {
                $globalNavHTML = @'
<body>
    <div class="global-nav">
        <a href="../../index.html" class="home-link">&#127968; Home</a>
        <a href="../../Article/option-a/index.html">&#128221; Articles</a>
        <a href="../../Prepositions/option-a/index.html">&#128506;&#65039; Prepositions</a>
        <a href="../../Numbers/option-a/index.html">&#128290; Numbers</a>
        <a href="../../Directions/option-a/index.html">&#129517; Directions</a>
        <a href="../../Time/option-a/index.html">&#9200; Time</a>
    </div>
'@
                # Adjust paths based on depth
                $depth = ($relativePath.Split('\').Count - 1)
                if ($depth -eq 0) {
                    $prefix = ""
                } elseif ($depth -eq 1) {
                    $prefix = "../"
                } else {
                    $prefix = "../../"
                }

                $globalNavHTML = $globalNavHTML -replace '\.\./\.\./', $prefix
                $content = $content -replace '(<body[^>]*>)', $globalNavHTML
                $needsUpdate = $true
            }
        }
    }

    # 3. Check for print CSS page-break prevention
    if ($content -match '<table') {
        if ($content -notmatch 'page-break-inside:\s*avoid') {
            Write-Host "  [NO PRINT CSS] $relativePath" -ForegroundColor Yellow
            $issuesFound += "$relativePath - Missing print page-break prevention"

            # Add print CSS if completely missing
            if ($content -notmatch '@media print') {
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
        }
'@
                # Insert before </style>
                $content = $content -replace '(</style>)', "$printCSS`n`$1"
                $needsUpdate = $true
            } else {
                # Enhance existing print CSS
                if ($content -match '@media print \{([^}]*)\}') {
                    # Add page-break prevention if missing
                    $content = $content -replace '(@media print \{)', @'
$1
            table {
                page-break-inside: avoid !important;
                break-inside: avoid-page !important;
            }
            tr {
                page-break-inside: avoid !important;
                break-inside: avoid-page !important;
            }
            h1, h2, h3 {
                page-break-after: avoid !important;
                break-after: avoid-page !important;
            }
'@
                    $needsUpdate = $true
                }
            }
        }
    }

    # 4. Ensure global-nav CSS exists (skip main index.html)
    if ($file.Name -ne "index.html" -or $file.Directory.Name -ne "Grammar") {
        if ($content -match 'class="global-nav"' -and $content -notmatch '\.global-nav \{') {
            Write-Host "  [NO GLOBAL-NAV CSS] $relativePath" -ForegroundColor Yellow
            $issuesFound += "$relativePath - Missing global-nav CSS"

            $globalNavCSS = @'

        /* Global Navigation Header */
        .global-nav {
            background-color: #1a252f;
            padding: 10px 0;
            margin: -20px -20px 0 -20px;
            text-align: center;
            border-bottom: 3px solid #34495e;
        }
        .global-nav a {
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            margin: 0 15px;
            padding: 8px 16px;
            border-radius: 5px;
            transition: all 0.3s;
            font-size: 0.95em;
            font-weight: 500;
        }
        .global-nav a:hover {
            background-color: rgba(255,255,255,0.1);
            color: white;
        }
        .global-nav .home-link {
            font-weight: bold;
            color: #3498db;
        }
        .global-nav .home-link:hover {
            color: #5dade2;
        }
'@
            # Insert before </style>
            $content = $content -replace '(</style>)', "$globalNavCSS`n`$1"
            $needsUpdate = $true
        }
    }

    # Save if updates needed
    if ($needsUpdate) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        $fixedFiles += $relativePath
        Write-Host "  [FIXED] $relativePath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Green
Write-Host "Total files processed: $($allFiles.Count)" -ForegroundColor Cyan
Write-Host "Issues found: $($issuesFound.Count)" -ForegroundColor Yellow
Write-Host "Files fixed: $($fixedFiles.Count)" -ForegroundColor Green

if ($issuesFound.Count -gt 0) {
    Write-Host ""
    Write-Host "Issues Details:" -ForegroundColor Yellow
    $issuesFound | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "All checks completed!" -ForegroundColor Green
