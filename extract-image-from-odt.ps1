# PowerShell script to extract image from Dual Function Prepositions.odt

$odtFile = "C:\Users\pc\Documents\Phoenix Code\Grammar\Dual Function Prepositions.odt"
$tempDir = "C:\Users\pc\Documents\Phoenix Code\Grammar\temp_odt_extract"
$targetDir = "C:\Users\pc\Documents\Phoenix Code\Grammar\Prepositions\images"

# Create temp directory
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory | Out-Null

# Create target directory for images
if (-not (Test-Path $targetDir)) {
    New-Item -Path $targetDir -ItemType Directory | Out-Null
}

# Extract ODT (it's a ZIP file)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($odtFile, $tempDir)

# Find and copy images
$picturesDir = "$tempDir\Pictures"
if (Test-Path $picturesDir) {
    Write-Host "Found Pictures directory" -ForegroundColor Green

    $images = Get-ChildItem -Path $picturesDir -File
    foreach ($image in $images) {
        $newName = "dual-function-diagram.png"
        Copy-Item -Path $image.FullName -Destination "$targetDir\$newName" -Force
        Write-Host "Extracted: $($image.Name) -> $newName" -ForegroundColor Cyan
    }
} else {
    Write-Host "No Pictures directory found" -ForegroundColor Yellow
}

# Clean up
Remove-Item -Path $tempDir -Recurse -Force

Write-Host ""
Write-Host "Image extraction complete!" -ForegroundColor Green
Write-Host "Image saved to: $targetDir" -ForegroundColor Cyan
