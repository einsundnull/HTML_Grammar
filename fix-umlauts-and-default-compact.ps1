# PowerShell script to fix umlauts and set extra-compact as default

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"
$allFiles = Get-ChildItem -Path $baseDir -Filter "*.html" -Recurse

Write-Host "=== FIXING UMLAUTS AND DEFAULT COMPACT MODE ===" -ForegroundColor Green
Write-Host ""

$stats = @{
    'TotalFiles' = 0
    'FixedUmlauts' = 0
    'SetDefaultCompact' = 0
    'UpdatedToggle' = 0
}

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace($baseDir + "\", "")
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $needsUpdate = $false

    $stats['TotalFiles']++

    # Skip main index
    if ($file.Name -eq "index.html" -and $file.Directory.Name -eq "Grammar") {
        continue
    }

    # Problem 1: Fix common umlaut HTML entities to actual UTF-8 characters
    $originalContent = $content

    # Replace HTML entities with actual UTF-8 umlauts
    $content = $content -replace '&auml;', 'ä'
    $content = $content -replace '&ouml;', 'ö'
    $content = $content -replace '&uuml;', 'ü'
    $content = $content -replace '&Auml;', 'Ä'
    $content = $content -replace '&Ouml;', 'Ö'
    $content = $content -replace '&Uuml;', 'Ü'
    $content = $content -replace '&szlig;', 'ß'

    if ($content -ne $originalContent) {
        $stats['FixedUmlauts']++
        Write-Host "  [UMLAUTS] Fixed in $relativePath" -ForegroundColor Cyan
        $needsUpdate = $true
    }

    # Problem 2: Set extra-compact-mode as default
    # Add class to body tag
    if ($content -match '<body[^>]*>' -and $content -notmatch '<body[^>]*class="extra-compact-mode"') {
        # Check if body already has a class
        if ($content -match '<body class="([^"]*)"') {
            # Add to existing class
            $content = $content -replace '<body class="([^"]*)"', '<body class="$1 extra-compact-mode"'
        } else {
            # Add new class attribute
            $content = $content -replace '<body>', '<body class="extra-compact-mode">'
        }
        $stats['SetDefaultCompact']++
        Write-Host "  [DEFAULT] Set extra-compact as default in $relativePath" -ForegroundColor Yellow
        $needsUpdate = $true
    }

    # Problem 2b: Update toggle function to skip compact mode (Normal <-> Extra-Compact only)
    if ($content -match 'function toggleCompactMode') {
        $newToggleFunction = @'
        function toggleCompactMode() {
            const body = document.body;
            const button = document.querySelector('.toggle-btn');

            if (body.classList.contains('extra-compact-mode')) {
                // Extra-Compact -> Normal
                body.classList.remove('extra-compact-mode');
                button.innerHTML = '&#128202; Extra-Kompakt-Modus';
            } else {
                // Normal -> Extra-Compact
                body.classList.add('extra-compact-mode');
                button.innerHTML = '&#128202; Normal-Modus';
            }
        }
'@
        # Replace old function
        $content = $content -replace 'function toggleCompactMode\(\)\s*\{[^}]*\}', $newToggleFunction

        # Update initial button text to match default state (extra-compact)
        $content = $content -replace '(<button class="toggle-btn"[^>]*>)[^<]*(</button>)', '$1&#128202; Normal-Modus$2'

        $stats['UpdatedToggle']++
        Write-Host "  [TOGGLE] Updated toggle function in $relativePath" -ForegroundColor Magenta
        $needsUpdate = $true
    }

    # Save if updates were made
    if ($needsUpdate) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total files processed: $($stats['TotalFiles'])" -ForegroundColor White
Write-Host "Files with fixed umlauts: $($stats['FixedUmlauts'])" -ForegroundColor Green
Write-Host "Files set to default extra-compact: $($stats['SetDefaultCompact'])" -ForegroundColor Green
Write-Host "Files with updated toggle: $($stats['UpdatedToggle'])" -ForegroundColor Green
Write-Host ""

Write-Host "Changes made:" -ForegroundColor Cyan
Write-Host "  - Replaced HTML entities with UTF-8 umlauts" -ForegroundColor White
Write-Host "  - Set extra-compact-mode as default on all pages" -ForegroundColor White
Write-Host "  - Updated toggle to switch between Extra-Compact and Normal" -ForegroundColor White
Write-Host "  - Button now shows Normal-Modus by default" -ForegroundColor White
Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
