Function LoadTextFile(FullFileName As String) As String
  With CreateObject("Scripting.FileSystemObject")
    LoadTextFile = .OpenTextFile(FullFileName, 1).readall
  End With 
End Function

let
// load the reference file (variables are shown in capitals;  
// variable values are replaced with strings from the excel control workbook)
    Source = Excel.Workbook(File.Contents(PATH_AND_NAME), null, true),
    ImportSheet = Source{[Item=SHEET_NAME,Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(ImportSheet),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"ACCOUNT", type text}})
in
    #"Changed Type"
