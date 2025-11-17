let
FolderPath = Excel.CurrentWorkbook(){[Name="FolderPath"]}[Content]{0}[Column1],
Source = Folder.Files(FolderPath),
#"Added Custom" = Table.AddColumn(Source, "Custom", each Excel.Workbook([Content])),
in
#"Added Custom1"
