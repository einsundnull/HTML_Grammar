# PowerShell script to read Dual Function Prepositions.odt

$odtFile = "C:\Users\pc\Documents\Phoenix Code\Grammar\Dual Function Prepositions.odt"
$tempDir = "C:\Users\pc\Documents\Phoenix Code\Grammar\temp_odt_extract"

# Create temp directory
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory | Out-Null

# Extract ODT (it's a ZIP file)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($odtFile, $tempDir)

# Read content.xml
$contentXml = Get-Content -Path "$tempDir\content.xml" -Raw -Encoding UTF8

# Output the content
Write-Host "=== CONTENT.XML ===" -ForegroundColor Green
Write-Host $contentXml

# Clean up
Remove-Item -Path $tempDir -Recurse -Force

Write-Host ""
Write-Host "=== EXTRACTION COMPLETE ===" -ForegroundColor Green
