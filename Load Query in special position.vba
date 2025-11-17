Sub LoadQuery() ' load but some can not set connect only again
    Dim ws As Worksheet
    Dim lastRow As Long, lastCol As Long
    Dim targetCol As Long
    Dim colLetter As String
    Dim position As String
    Dim queryName As String
    Dim query As WorkbookQuery
    Set ws = ActiveSheet
    lastRow = ws.Cells.Find(What:="*", SearchOrder:=xlByRows, SearchDirection:=xlPrevious).Row
    lastCol = ws.Cells.Find(What:="*", SearchOrder:=xlByColumns, SearchDirection:=xlPrevious).Column
    targetCol = lastCol + 1
    colLetter = Split(Cells(1, targetCol).Address, "$")(1)
    position = colLetter
    position = position + "9"
	
    queryName = "NOTE"
    Set ws = ActiveSheet
    On Error Resume Next
    Set query = ThisWorkbook.Queries(queryName)
    On Error GoTo 0
        If query Is Nothing Then
        MsgBox "Query '" & queryName & "' not found.", vbExclamation, "Error"
        Exit Sub
    End If
    With ws.ListObjects.Add(SourceType:=0, Source:= _
        "OLEDB;Provider=Microsoft.Mashup.OleDb.1;Data Source=$Workbook$;Location=" & query.Name, _
        Destination:=ws.Range(position)).QueryTable
        .CommandType = xlCmdDefault
        .CommandText = Array("SELECT * FROM [" & query.Name & "]")
        .RowNumbers = False
        .FillAdjacentFormulas = False
        .PreserveFormatting = True
        .RefreshOnFileOpen = False
        .BackgroundQuery = True
        .RefreshStyle = xlInsertDeleteCells
        .SavePassword = False
        .SaveData = True
        .AdjustColumnWidth = True
        .RefreshPeriod = 0
        .PreserveColumnInfo = False
        .Refresh BackgroundQuery:=False
    End With
End Sub




