param(
    [Parameter(Mandatory = $true)][string]$RequestPath,
    [Parameter(Mandatory = $true)][string]$OutputPath,
    [string]$ExpectedSourceHash = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$scriptWatch = [Diagnostics.Stopwatch]::StartNew()

function Release-ComObject([object]$Object) {
    if ($null -ne $Object -and [Runtime.InteropServices.Marshal]::IsComObject($Object)) {
        [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($Object)
    }
}

function Convert-CellValueToText([object]$Value) {
    if ($null -eq $Value) { return '' }
    if ($Value -is [double] -and $Value -eq [Math]::Truncate($Value)) {
        return ([long]$Value).ToString([Globalization.CultureInfo]::InvariantCulture)
    }
    return [Convert]::ToString($Value, [Globalization.CultureInfo]::InvariantCulture).Trim()
}

function Get-OptionalProperty([object]$Object, [string]$Name) {
    try {
        $value = $Object.$Name
        if ($null -eq $value) { return '' }
        return [Convert]::ToString($value, [Globalization.CultureInfo]::InvariantCulture)
    }
    catch {
        return ''
    }
}

function Get-CellFormatFingerprint([object]$Cell) {
    $font = $null
    $interior = $null
    $validation = $null
    $borders = $null
    try {
        $font = $Cell.Font
        $interior = $Cell.Interior
        $validation = $Cell.Validation
        $borders = $Cell.Borders
        $borderValues = New-Object 'System.Collections.Generic.List[string]'
        foreach ($index in @(7, 8, 9, 10)) {
            $border = $null
            try {
                $border = $borders.Item($index)
                $borderValues.Add(($index.ToString() + ':' +
                    (Get-OptionalProperty $border 'LineStyle') + ':' +
                    (Get-OptionalProperty $border 'Weight') + ':' +
                    (Get-OptionalProperty $border 'Color')))
            }
            finally {
                Release-ComObject $border
            }
        }

        $parts = @(
            (Get-OptionalProperty $Cell 'Style'),
            (Get-OptionalProperty $Cell 'NumberFormat'),
            (Get-OptionalProperty $Cell 'HorizontalAlignment'),
            (Get-OptionalProperty $Cell 'VerticalAlignment'),
            (Get-OptionalProperty $Cell 'WrapText'),
            (Get-OptionalProperty $Cell 'Orientation'),
            (Get-OptionalProperty $Cell 'Locked'),
            (Get-OptionalProperty $Cell 'Hidden'),
            (Get-OptionalProperty $font 'Name'),
            (Get-OptionalProperty $font 'Size'),
            (Get-OptionalProperty $font 'Bold'),
            (Get-OptionalProperty $font 'Italic'),
            (Get-OptionalProperty $font 'Underline'),
            (Get-OptionalProperty $font 'Color'),
            (Get-OptionalProperty $interior 'Pattern'),
            (Get-OptionalProperty $interior 'Color'),
            (Get-OptionalProperty $validation 'Type'),
            (Get-OptionalProperty $validation 'Formula1'),
            (Get-OptionalProperty $validation 'Formula2'),
            ($borderValues -join ',')
        )
        return ($parts -join '|')
    }
    finally {
        Release-ComObject $borders
        Release-ComObject $validation
        Release-ComObject $interior
        Release-ComObject $font
    }
}

function Get-WorkbookMetadataFingerprint([object]$Workbook) {
    $records = New-Object 'System.Collections.Generic.List[string]'
    $sheets = $Workbook.Worksheets
    try {
        foreach ($sheet in $sheets) {
            $used = $null
            try {
                $used = $sheet.UsedRange
                $records.Add(('S|{0}|{1}|{2}' -f $sheet.Name, $used.Rows.Count, $used.Columns.Count))

                $formulaCells = $null
                try {
                    $formulaCells = $used.SpecialCells(-4123) # xlCellTypeFormulas
                    foreach ($cell in $formulaCells.Cells) {
                        try {
                            $records.Add(('F|{0}|{1}|{2}' -f $sheet.Name, $cell.Address($false, $false), [string]$cell.Formula))
                        }
                        finally {
                            Release-ComObject $cell
                        }
                    }
                }
                catch { }
                finally {
                    Release-ComObject $formulaCells
                }

                $commentCells = $null
                try {
                    $commentCells = $used.SpecialCells(-4144) # xlCellTypeComments / legacy notes
                    foreach ($cell in $commentCells.Cells) {
                        $comment = $null
                        try {
                            $comment = $cell.Comment
                            if ($null -ne $comment) {
                                $records.Add(('C|{0}|{1}|{2}|{3}' -f $sheet.Name, $cell.Address($false, $false), $comment.Author, $comment.Text()))
                            }
                        }
                        finally {
                            Release-ComObject $comment
                            Release-ComObject $cell
                        }
                    }
                }
                catch { }
                finally {
                    Release-ComObject $commentCells
                }
            }
            finally {
                # 不释放 Sheets 枚举得到的 Sheet 对象：它与调用方持有的 Worksheet 是同一 RCW，
                # 强制释放会让调用方的引用失效。
                Release-ComObject $used
            }
        }
    }
    finally {
        Release-ComObject $sheets
    }
    return (($records | Sort-Object) -join "`n")
}

function Find-TargetRow([object]$Worksheet, [int]$ConfigId, [int]$GroupId) {
    $used = $null
    try {
        $used = $Worksheet.UsedRange
        $firstRow = [Math]::Max(6, [int]$used.Row)
        $lastRow = [int]$used.Row + [int]$used.Rows.Count - 1
        $matches = New-Object 'System.Collections.Generic.List[int]'
        $configText = $ConfigId.ToString([Globalization.CultureInfo]::InvariantCulture)
        $groupText = $GroupId.ToString([Globalization.CultureInfo]::InvariantCulture)

        # 一次性读取 A:B 列区间，避免逐行 COM 调用；2000+ 行逐行读取约需 5 秒。
        $bulk = $null
        if ($lastRow -ge $firstRow) {
            $firstCell = $null
            $lastCell = $null
            try {
                $firstCell = $Worksheet.Cells.Item($firstRow, 1)
                $lastCell = $Worksheet.Cells.Item($lastRow, 2)
                $bulk = $Worksheet.Range($firstCell, $lastCell).Value2
            }
            finally {
                Release-ComObject $lastCell
                Release-ComObject $firstCell
            }
        }

        if ($bulk -is [Array]) {
            $rowCount = $bulk.GetLength(0)
            for ($offset = 0; $offset -lt $rowCount; $offset++) {
                if ((Convert-CellValueToText $bulk[($offset + 1), 1]) -ne $configText) { continue }
                if ((Convert-CellValueToText $bulk[($offset + 1), 2]) -ne $groupText) { continue }
                $matches.Add($firstRow + $offset)
            }
        }
        else {
            # 兼容极少数无法批量读取的情况（例如单行区间）。
            for ($row = $firstRow; $row -le $lastRow; $row++) {
                $cellA = $null
                $cellB = $null
                try {
                    $cellA = $Worksheet.Cells.Item($row, 1)
                    $cellB = $Worksheet.Cells.Item($row, 2)
                    if ((Convert-CellValueToText $cellA.Value2) -eq $configText -and
                        (Convert-CellValueToText $cellB.Value2) -eq $groupText) {
                        $matches.Add($row)
                    }
                }
                finally {
                    Release-ComObject $cellB
                    Release-ComObject $cellA
                }
            }
        }

        if ($matches.Count -ne 1) {
            throw "MonsterFormation 中 configId=$ConfigId、groupId=$GroupId 命中 $($matches.Count) 行，已拒绝写入。"
        }
        return $matches[0]
    }
    finally {
        Release-ComObject $used
    }
}

function Get-FileSha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Get-StreamSha256([IO.Stream]$Stream) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $Stream.Position = 0
        return [BitConverter]::ToString($sha.ComputeHash($Stream)).Replace('-', '')
    }
    finally { $Stream.Position = 0; $sha.Dispose() }
}

function Copy-StreamToFile([IO.Stream]$Source, [string]$Destination) {
    $output = [IO.File]::Open($Destination, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try { $Source.Position = 0; $Source.CopyTo($output); $output.Flush($true) }
    finally { $Source.Position = 0; $output.Dispose() }
}

function Copy-FileWithRetry([string]$Source, [string]$Destination, [int]$Attempts = 4) {
    # 备份位于 Unity 工程内，可能被资源导入短暂占用，因此带少量重试。
    for ($attempt = 1; $attempt -le $Attempts; $attempt++) {
        try {
            [IO.File]::Copy($Source, $Destination, $true)
            return
        }
        catch [IO.IOException] {
            if ($attempt -eq $Attempts) { throw }
            Start-Sleep -Milliseconds 200
        }
    }
}

function Get-BackupDirectory {
    if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        throw '无法定位工具目录（$PSScriptRoot 为空），已拒绝写入以避免备份落到错误位置。'
    }
    return [IO.Path]::Combine($PSScriptRoot, 'StageToolsBackup')
}

function Open-ExcelApplication {
    $excelType = [Type]::GetTypeFromProgID('Excel.Application')
    if ($null -eq $excelType) {
        throw '未检测到 Microsoft Excel。为完整保留旧版 .xls 的公式、批注和格式，本工具必须通过本机 Excel 执行单元格级写入。'
    }
    $excel = [Activator]::CreateInstance($excelType)
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $excel.AskToUpdateLinks = $false
    $excel.EnableEvents = $false
    $excel.AutomationSecurity = 3 # msoAutomationSecurityForceDisable
    $excel.Calculation = -4135 # xlCalculationManual
    $excel.CalculateBeforeSave = $false
    return $excel
}

function Open-Workbook([object]$Excel, [string]$Path, [bool]$ReadOnly) {
    return $Excel.Workbooks.Open($Path, 0, $ReadOnly)
}

$result = [ordered]@{
    success = $false
    error = ''
    backupPath = ''
    rowNumber = 0
    oldFormation = ''
    oldMonsterGroup = ''
    oldDescription = ''
    newFormation = ''
    newMonsterGroup = ''
    newDescription = ''
    elapsedMs = 0
}

$tempPath = $null
$backupPath = $null
$excel = $null
$workbook = $null
$worksheet = $null
$targetFormationCell = $null
$targetMonsterCell = $null
$targetDescriptionCell = $null
$sourceStream = $null
$sourceLocks = New-Object 'System.Collections.Generic.List[System.IO.Stream]'
$writeMutex = $null
$ownsMutex = $false
$commitStarted = $false
$journalPath = $null

try {
    $request = Get-Content -LiteralPath $RequestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $excelPath = [IO.Path]::GetFullPath([string]$request.excelPath)
    if (-not [IO.File]::Exists($excelPath)) {
        throw "MonsterFormation 表不存在：$excelPath"
    }
    if ([IO.Path]::GetFileName($excelPath) -cne 'MonsterFormation.xls') {
        throw "安全写表入口只允许写入 MonsterFormation.xls，已拒绝：$excelPath"
    }
    if ([IO.Path]::GetExtension($excelPath).ToLowerInvariant() -ne '.xls') {
        throw "只允许修改 .xls 文件：$excelPath"
    }

    $configId = [int]$request.configId
    $groupId = [int]$request.groupId
    $expectedFormation = [string]$request.expectedFormation
    $expectedMonsterGroup = [string]$request.expectedMonsterGroup
    $expectedDescription = [string]$request.expectedDescription
    $newFormation = [string]$request.newFormation
    $newMonsterGroup = [string]$request.newMonsterGroup
    $newDescription = [string]$request.newDescription
    if ([string]::IsNullOrWhiteSpace($newFormation)) { throw '阵型名称不能为空。' }
    if ([string]::IsNullOrWhiteSpace($newMonsterGroup)) { throw '怪物组合不能为空。' }
    if ($newMonsterGroup -cnotmatch '^[1-9][0-9]*:[1-9][0-9]*(\|[1-9][0-9]*:[1-9][0-9]*)*$') {
        throw '怪物组合只允许正整数 ActorID:数量，不允许小数、空项或负数。'
    }
    foreach ($part in ($newMonsterGroup -split '[|:]')) {
        $parsed = 0
        if (-not [int]::TryParse($part, [ref]$parsed)) { throw '怪物 ID 或数量超出 Int32 范围。' }
    }
    if ($newFormation.StartsWith('=') -or $newDescription.StartsWith('=')) {
        throw '阵型和描述不能以等号开头，避免 Excel 将文本作为公式执行。'
    }
    # 互斥锁保护 StageTools，文件句柄同时阻止其他程序写入和重命名。
    $writeMutex = New-Object Threading.Mutex($false, 'Local\StageTools.ExcelWriter.v2')
    try { $ownsMutex = $writeMutex.WaitOne(0) }
    catch [Threading.AbandonedMutexException] { $ownsMutex = $true }
    if (-not $ownsMutex) { throw '另一个 StageTools 正在提交，请稍后重新读取。' }
    $excelDirectory = [IO.Path]::GetDirectoryName($excelPath)
    $tableNames = @('MonsterSpawnType', 'MonsterSpawns', 'MonsterFormation', 'Actor')
    if ($null -eq $request.tableHashes -or $request.tableHashes.Count -ne 4) {
        throw '缺少读取草稿时四张表的版本快照，请更新工具并重新创建草稿。'
    }
    for ($index = 0; $index -lt $tableNames.Count; $index++) {
        $tablePath = [IO.Path]::Combine($excelDirectory, $tableNames[$index] + '.xls')
        if ($index -eq 2) {
            $sourceStream = [IO.File]::Open($tablePath, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
            $locked = $sourceStream
        }
        else {
            $locked = [IO.File]::Open($tablePath, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        }
        $sourceLocks.Add($locked)
        if ((Get-StreamSha256 $locked) -cne [string]$request.tableHashes[$index]) {
            throw ($tableNames[$index] + ' 已发生变化，旧草稿已失效，请重新创建。')
        }
    }
    $journalPath = $excelPath + '.stage-tools-pending.json'
    if ([IO.File]::Exists($journalPath)) {
        $pending = Get-Content -LiteralPath $journalPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $currentHash = Get-StreamSha256 $sourceStream
        if ($currentHash -eq $pending.oldHash -or $currentHash -eq $pending.newHash) {
            [IO.File]::Delete($journalPath)
        }
        else { throw ('检测到未完成提交，请先检查备份并恢复：' + $pending.backupPath) }
    }


    $sourceHashBefore = Get-StreamSha256 $sourceStream
    if (-not [string]::IsNullOrWhiteSpace($ExpectedSourceHash) -and $sourceHashBefore -ne $ExpectedSourceHash.ToUpperInvariant()) {
        throw '源表在写入前已发生变化，已拒绝覆盖。请重新读取点位后再试。'
    }

    $excelDirectory = [IO.Path]::GetDirectoryName($excelPath)
    $baseName = [IO.Path]::GetFileNameWithoutExtension($excelPath)
    $extension = [IO.Path]::GetExtension($excelPath)
    $token = [Guid]::NewGuid().ToString('N')
    $tempPath = [IO.Path]::Combine($excelDirectory, ('.~stage-tools-{0}-{1}{2}' -f $baseName, $token, $extension))

    Copy-StreamToFile $sourceStream $tempPath
    $excel = Open-ExcelApplication

    $workbook = Open-Workbook $excel $tempPath $false
    if ($workbook.ReadOnly) { throw 'Excel 将临时副本以只读方式打开，无法安全写入。请关闭占用表格的程序后重试。' }
    $worksheet = $workbook.Worksheets.Item('Sheet1')
    $row = Find-TargetRow $worksheet $configId $groupId
    $targetFormationCell = $worksheet.Cells.Item($row, 3)
    $targetMonsterCell = $worksheet.Cells.Item($row, 4)
    $targetDescriptionCell = $worksheet.Cells.Item($row, 6)

    $currentFormation = Convert-CellValueToText $targetFormationCell.Value2
    $currentMonsterGroup = Convert-CellValueToText $targetMonsterCell.Value2
    $currentDescription = Convert-CellValueToText $targetDescriptionCell.Value2
    if ($currentFormation -cne $expectedFormation -or $currentMonsterGroup -cne $expectedMonsterGroup -or
        $currentDescription -cne $expectedDescription) {
        throw ("目标行已发生变化，已拒绝覆盖。`n当前：{0} / {1} / {2}`n读取草稿时：{3} / {4} / {5}" -f
            $currentFormation, $currentMonsterGroup, $currentDescription,
            $expectedFormation, $expectedMonsterGroup, $expectedDescription)
    }
    if ([bool]$targetFormationCell.HasFormula -or [bool]$targetMonsterCell.HasFormula -or [bool]$targetDescriptionCell.HasFormula) {
        throw '目标 C/D/F 单元格包含公式。为避免破坏公式，工具已拒绝写入。'
    }

    $metadataBefore = Get-WorkbookMetadataFingerprint $workbook
    $formationFormatBefore = Get-CellFormatFingerprint $targetFormationCell
    $monsterFormatBefore = Get-CellFormatFingerprint $targetMonsterCell
    $descriptionFormatBefore = Get-CellFormatFingerprint $targetDescriptionCell

    $targetFormationCell.Value2 = $newFormation
    $targetMonsterCell.Value2 = $newMonsterGroup
    $targetDescriptionCell.Value2 = $newDescription
    $workbook.Save()
    $workbook.Close($false)
    Release-ComObject $targetMonsterCell; $targetMonsterCell = $null
    Release-ComObject $targetFormationCell; $targetFormationCell = $null
    Release-ComObject $targetDescriptionCell; $targetDescriptionCell = $null
    Release-ComObject $worksheet; $worksheet = $null
    Release-ComObject $workbook; $workbook = $null

    $workbook = Open-Workbook $excel $tempPath $true
    $worksheet = $workbook.Worksheets.Item('Sheet1')
    $verifiedRow = Find-TargetRow $worksheet $configId $groupId
    $targetFormationCell = $worksheet.Cells.Item($verifiedRow, 3)
    $targetMonsterCell = $worksheet.Cells.Item($verifiedRow, 4)
    $targetDescriptionCell = $worksheet.Cells.Item($verifiedRow, 6)

    if ((Convert-CellValueToText $targetFormationCell.Value2) -cne $newFormation -or
        (Convert-CellValueToText $targetMonsterCell.Value2) -cne $newMonsterGroup -or
        ([string]$targetDescriptionCell.Value2) -cne $newDescription) {
        throw '写后复核失败：目标单元格值不一致，原表未被替换。'
    }
    if ((Get-WorkbookMetadataFingerprint $workbook) -cne $metadataBefore) {
        throw '写后复核失败：检测到公式、批注或工作表结构变化，原表未被替换。'
    }
    if ((Get-CellFormatFingerprint $targetFormationCell) -cne $formationFormatBefore -or
        (Get-CellFormatFingerprint $targetMonsterCell) -cne $monsterFormatBefore -or
        (Get-CellFormatFingerprint $targetDescriptionCell) -cne $descriptionFormatBefore) {
        throw '写后复核失败：检测到目标单元格格式变化，原表未被替换。'
    }

    $workbook.Close($false)
    Release-ComObject $targetMonsterCell; $targetMonsterCell = $null
    Release-ComObject $targetFormationCell; $targetFormationCell = $null
    Release-ComObject $targetDescriptionCell; $targetDescriptionCell = $null
    Release-ComObject $worksheet; $worksheet = $null
    Release-ComObject $workbook; $workbook = $null
    $excel.Quit()
    Release-ComObject $excel; $excel = $null
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    $sourceHashBeforeReplace = Get-StreamSha256 $sourceStream
    if ($sourceHashBeforeReplace -ne $sourceHashBefore) {
        throw '正式表在写入期间已发生变化，已拒绝替换。请重新读取点位后再试。'
    }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedSourceHash) -and $sourceHashBeforeReplace -ne $ExpectedSourceHash.ToUpperInvariant()) {
        throw '正式表在写入期间已发生变化，已拒绝替换。请重新读取点位后再试。'
    }

    # 独占句柄下提交，先持久化唯一备份和恢复标记；不释放锁再替换文件。
    # 提交不是断电原子操作；可捕获异常会回滚，强杀/断电留下恢复标记。
    $backupDirectory = Get-BackupDirectory
    [IO.Directory]::CreateDirectory($backupDirectory) | Out-Null
    $backupPath = [IO.Path]::Combine($backupDirectory, ('{0}-{1}.backup{2}' -f $baseName, $token, $extension))
    Copy-StreamToFile $sourceStream $backupPath
    $newHash = Get-FileSha256 $tempPath
    $journal = @{ oldHash = $sourceHashBefore; newHash = $newHash; backupPath = $backupPath } | ConvertTo-Json
    $journalBytes = [Text.Encoding]::UTF8.GetBytes($journal)
    $journalStream = [IO.File]::Open($journalPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try { $journalStream.Write($journalBytes, 0, $journalBytes.Length); $journalStream.Flush($true) }
    finally { $journalStream.Dispose() }
    $commitStarted = $true
    $updatedStream = [IO.File]::OpenRead($tempPath)
    try {
        $sourceStream.Position = 0
        $updatedStream.CopyTo($sourceStream)
        $sourceStream.SetLength($updatedStream.Length)
        $sourceStream.Flush($true)
    }
    finally { $updatedStream.Dispose() }
    if ((Get-StreamSha256 $sourceStream) -cne $newHash) { throw '提交后字节校验失败，将回滚原表。' }
    $result.success = $true
    try { [IO.File]::Delete($journalPath) } catch { }

    $result.backupPath = $backupPath
    $result.rowNumber = $row
    $result.oldFormation = $currentFormation
    $result.oldMonsterGroup = $currentMonsterGroup
    $result.oldDescription = $currentDescription
    $result.newFormation = $newFormation
    $result.newMonsterGroup = $newMonsterGroup
    $result.newDescription = $newDescription
}
catch {
    $result.error = $_.Exception.Message
    if ($commitStarted -and -not $result.success -and $null -ne $sourceStream) {
        try {
            $restore = [IO.File]::OpenRead($backupPath)
            try {
                $sourceStream.Position = 0
                $restore.CopyTo($sourceStream)
                $sourceStream.SetLength($restore.Length)
                $sourceStream.Flush($true)
            }
            finally { $restore.Dispose() }
            if ((Get-StreamSha256 $sourceStream) -cne $sourceHashBefore) { throw '回滚校验失败' }
            [IO.File]::Delete($journalPath)
        }
        catch { $result.error += ('；回滚未完成，请保留恢复标记并检查备份：' + $backupPath) }
    }
}
finally {
    foreach ($locked in $sourceLocks) { $locked.Dispose() }
    if ($ownsMutex) { $writeMutex.ReleaseMutex() }
    if ($null -ne $writeMutex) { $writeMutex.Dispose() }
    if ($null -ne $workbook) {
        try { $workbook.Close($false) } catch { }
    }
    Release-ComObject $targetDescriptionCell
    Release-ComObject $targetMonsterCell
    Release-ComObject $targetFormationCell
    Release-ComObject $worksheet
    Release-ComObject $workbook
    if ($null -ne $excel) {
        try { $excel.Quit() } catch { }
    }
    Release-ComObject $excel
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    if ($null -ne $tempPath -and [IO.File]::Exists($tempPath)) {
        try { [IO.File]::Delete($tempPath) } catch { }
    }

    $scriptWatch.Stop()
    $result.elapsedMs = $scriptWatch.ElapsedMilliseconds

    $outputDirectory = [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($OutputPath))
    [IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
    [IO.File]::WriteAllText($OutputPath, ($result | ConvertTo-Json -Depth 5), (New-Object Text.UTF8Encoding($false)))
}

if ($result.success) { exit 0 }
exit 1
