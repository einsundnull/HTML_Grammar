# Simple script to replace print buttons with single button

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse

Write-Host "=== FIXING PRINT BUTTONS ===" -ForegroundColor Green
Write-Host ""

$fixed = 0

foreach ($file in $allFiles) {
    # Skip index pages
    if ($file.Name -eq "index.html") {
        continue
    }

    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    # Check if needs fixing
    if ($content -notmatch '<div class="print-buttons">') {
        continue
    }

    # Read line by line to find and replace the print-buttons section
    $lines = Get-Content -Path $file.FullName -Encoding UTF8
    $newLines = @()
    $inPrintButtons = $false
    $replaced = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if ($line -match '<div class="print-buttons">') {
            # Start of print-buttons section - replace with single button
            $newLines += '        <button class="print-btn" onclick="window.print()">&#128424; Drucken</button>'
            $inPrintButtons = $true
            $replaced = $true
            continue
        }

        if ($inPrintButtons) {
            # Skip lines until we find the closing div
            if ($line -match '</div>') {
                $inPrintButtons = $false
            }
            continue
        }

        $newLines += $line
    }

    if ($replaced) {
        # Save the file
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllLines($file.FullName, $newLines, $utf8NoBom)
        $fixed++
        Write-Host "  [FIXED] $($file.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Fixed $fixed files" -ForegroundColor Cyan
Write-Host "Complete!" -ForegroundColor Green
