let
    Source = Excel.CurrentWorkbook(){[Name="FilePath"]}[Content],
    File = Source{0}[Column1]
in
    File
