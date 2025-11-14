$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    # Read Prepsositions.ods
    Write-Host "=== PREPSOSITIONS.ODS ===" -ForegroundColor Green
    $workbook = $excel.Workbooks.Open("C:\Users\pc\Desktop\Prepositions\Prepsositions.ods")

    foreach($sheet in $workbook.Sheets) {
        Write-Host "`n--- Sheet: $($sheet.Name) ---" -ForegroundColor Yellow
        $range = $sheet.UsedRange
        $rows = $range.Rows.Count
        $cols = $range.Columns.Count

        Write-Host "Rows: $rows, Columns: $cols"

        for($r=1; $r -le [Math]::Min($rows, 100); $r++) {
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

        if ($rows -gt 100) {
            Write-Host "`n... (showing first 100 rows of $rows total)" -ForegroundColor Cyan
        }
    }

    $workbook.Close($false)
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
} finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
}
