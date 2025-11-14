$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

# Read Pronouns.xlsx
Write-Host "=== PRONOUNS.XLSX ===" -ForegroundColor Green
$workbook1 = $excel.Workbooks.Open("C:\Users\pc\Desktop\Article\Pronouns.xlsx")
foreach($sheet in $workbook1.Sheets) {
    Write-Host "`n--- Sheet: $($sheet.Name) ---" -ForegroundColor Yellow
    $range = $sheet.UsedRange
    $rows = $range.Rows.Count
    $cols = $range.Columns.Count
    for($r=1; $r -le $rows; $r++) {
        $line = ""
        for($c=1; $c -le $cols; $c++) {
            $cell = $sheet.Cells.Item($r,$c).Text
            if ($cell) {
                $line += $cell + "`t"
            } else {
                $line += "`t"
            }
        }
        Write-Host $line
    }
}
$workbook1.Close($false)

# Read Possessive Pronouns.xlsx
Write-Host "`n`n=== POSSESSIVE PRONOUNS.XLSX ===" -ForegroundColor Green
$workbook2 = $excel.Workbooks.Open("C:\Users\pc\Desktop\Article\Possessive Pronouns.xlsx")
foreach($sheet in $workbook2.Sheets) {
    Write-Host "`n--- Sheet: $($sheet.Name) ---" -ForegroundColor Yellow
    $range = $sheet.UsedRange
    $rows = $range.Rows.Count
    $cols = $range.Columns.Count
    for($r=1; $r -le $rows; $r++) {
        $line = ""
        for($c=1; $c -le $cols; $c++) {
            $cell = $sheet.Cells.Item($r,$c).Text
            if ($cell) {
                $line += $cell + "`t"
            } else {
                $line += "`t"
            }
        }
        Write-Host $line
    }
}
$workbook2.Close($false)

$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
