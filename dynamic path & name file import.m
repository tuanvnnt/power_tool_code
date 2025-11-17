let
    FilePath = Excel.CurrentWorkbook(){[Name="FilePath"]}[Content]{0}[Column1],
    FileName = Excel.CurrentWorkbook(){[Name="FileItem"]}[Content]{0}[Column1],
    FullPathToFile2 = FilePath & FileName,
    Source = Excel.Workbook(File.Contents(FullPathToFile2), null, true)
in
    Source
