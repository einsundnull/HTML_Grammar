# PowerShell script to reconvert files from Windows-1252 to UTF-8

$baseDir = "C:\Users\pc\Documents\Phoenix Code\Grammar"

$problematicFiles = @(
    "Directions\option-b\directions.html",
    "Directions\option-b\index.html",
    "Time\option-a\clock.html",
    "Time\option-a\index.html",
    "Time\option-a\vocabulary.html",
    "Time\option-b\index.html",
    "Time\option-b\time.html"
)

Write-Host "=== RECONVERTING FILE ENCODING ===" -ForegroundColor Green
Write-Host ""

$stats = @{
    'FilesFixed' = 0
}

foreach ($relPath in $problematicFiles) {
    $filePath = Join-Path $baseDir $relPath

    if (-not (Test-Path $filePath)) {
        Write-Host "  [SKIP] File not found: $relPath" -ForegroundColor Yellow
        continue
    }

    Write-Host "  [PROCESSING] $relPath" -ForegroundColor Cyan

    try {
        # Try reading as Windows-1252 (common encoding that causes these issues)
        $windows1252 = [System.Text.Encoding]::GetEncoding(1252)
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $content = $windows1252.GetString($bytes)

        # Check if we have the problematic characters
        if ($content -match '�') {
            Write-Host "    Still has � after Windows-1252 conversion, trying direct replacement..." -ForegroundColor Yellow

            # Read as default and do direct byte replacement
            $content = Get-Content -Path $filePath -Raw -Encoding Default

            # These are the actual bytes that appear as � in UTF-8 but should be umlauts
            # f� = fü (0xFC in Windows-1252/ISO-8859-1)
            # zw� = zwö (0xF6 in Windows-1252/ISO-8859-1)
            # drei� = dreiß (0xDF in Windows-1252/ISO-8859-1)

            # Read file, correct bytes, and save
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $correctedBytes = @()

            foreach ($byte in $bytes) {
                # Convert Windows-1252 special chars to UTF-8
                switch ($byte) {
                    0xFC { # ü
                        $correctedBytes += 0xC3
                        $correctedBytes += 0xBC
                    }
                    0xF6 { # ö
                        $correctedBytes += 0xC3
                        $correctedBytes += 0xB6
                    }
                    0xE4 { # ä
                        $correctedBytes += 0xC3
                        $correctedBytes += 0xA4
                    }
                    0xDC { # Ü
                        $correctedBytes += 0xC3
                        $correctedBytes += 0x9C
                    }
                    0xD6 { # Ö
                        $correctedBytes += 0xC3
                        $correctedBytes += 0x96
                    }
                    0xC4 { # Ä
                        $correctedBytes += 0xC3
                        $correctedBytes += 0x84
                    }
                    0xDF { # ß
                        $correctedBytes += 0xC3
                        $correctedBytes += 0x9F
                    }
                    default {
                        $correctedBytes += $byte
                    }
                }
            }

            # Write corrected bytes
            [System.IO.File]::WriteAllBytes($filePath, $correctedBytes)
            Write-Host "  [FIXED] $relPath - Byte-level correction applied" -ForegroundColor Green
            $stats['FilesFixed']++
        } else {
            # Save as UTF-8 without BOM
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
            Write-Host "  [FIXED] $relPath - Converted from Windows-1252 to UTF-8" -ForegroundColor Green
            $stats['FilesFixed']++
        }
    } catch {
        Write-Host "  [ERROR] Failed to convert $relPath : $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files fixed: $($stats['FilesFixed'])" -ForegroundColor Green
Write-Host ""
Write-Host "Encoding conversion complete!" -ForegroundColor Green
Write-Host "All files should now display umlauts correctly" -ForegroundColor White
Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
