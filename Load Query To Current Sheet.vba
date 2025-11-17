Sub LoadQueryToCurrentSheet()
    Dim queryName As String
    Dim query As WorkbookQuery
    Dim ws As Worksheet
    queryName = "NOTE"
    Set ws = ActiveSheet ' Load the query into the currently active sheet
    On Error Resume Next
    Set query = ThisWorkbook.Queries(queryName)
    On Error GoTo 0
        If query Is Nothing Then
        MsgBox "Query '" & queryName & "' not found.", vbExclamation, "Error"
        Exit Sub
    End If
    With ws.ListObjects.Add(SourceType:=0, Source:= _
        "OLEDB;Provider=Microsoft.Mashup.OleDb.1;Data Source=$Workbook$;Location=" & query.Name, _
        Destination:=ws.Range("A1")).QueryTable
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
    MsgBox "Query '" & queryName & "' loaded to " & ws.Name & " at A1.", vbInformation, "Success"
End Sub
