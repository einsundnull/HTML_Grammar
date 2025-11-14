$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    $workbook = $excel.Workbooks.Open("C:\Users\pc\Desktop\Prepositions\Prepsositions.ods")
    $sheet = $workbook.Sheets.Item(1)
    $range = $sheet.UsedRange
    $rows = $range.Rows.Count
    $cols = $range.Columns.Count

    Write-Host "Total Rows: $rows"
    Write-Host "Total Columns: $cols"
    Write-Host ""

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
        if ($line.Trim()) {
            Write-Host $line
        }
    }

    $workbook.Close($false)
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
} finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
}
