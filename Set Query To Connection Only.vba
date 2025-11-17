Sub SetQueryToConnectionOnly()  'warning : it will delete all table inside
    Dim wb As Workbook
    Dim conn As WorkbookConnection
    Dim lo As ListObject
    Dim queryName As String
    Dim ws As Worksheet
    Set wb = ThisWorkbook
    queryName = "NOTE"
    On Error Resume Next
    For Each ws In wb.Sheets
        For Each lo In ws.ListObjects
            If Not lo.QueryTable Is Nothing Then
                If lo.QueryTable.WorkbookConnection.Name = "Query - " & queryName Then
                    lo.Delete
                End If
            End If
        Next lo
    Next ws
    On Error GoTo 0
    For Each conn In wb.Connections
        If conn.Name = "Query - " & queryName Then
            conn.OLEDBConnection.BackgroundQuery = False
            conn.Delete
            Exit For
        End If
    Next conn
    MsgBox "Query '" & queryName & "' is now set to 'Connection Only'.", vbInformation, "Success"
End Sub
