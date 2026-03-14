let
    Source = Excel.CurrentWorkbook(){[Name="LogTable"]}[Content],

    // Clean text
    TrimEmployeeList = Table.TransformColumns(
        Source,
        {
            {"employee ID involve", each Text.Trim(_), type text},
            {"TaskType", each Text.Trim(_), type text}
        }
    ),

    // Split employee list into a list
    AddEmployeeList = Table.AddColumn(
        TrimEmployeeList,
        "EmployeeList",
        each List.Transform(
            Text.Split([employee ID involve], ","),
            each Text.Trim(_)
        )
    ),

    // Count employee headcount
    AddEmployeeCount = Table.AddColumn(
        AddEmployeeList,
        "EmployeeCount",
        each List.Count([EmployeeList]),
        Int64.Type
    ),

    // Expand one row into many employee rows
    ExpandEmployeeList = Table.ExpandListColumn(AddEmployeeCount, "EmployeeList"),

    // Rename expanded employee column
    RenameEmployeeID = Table.RenameColumns(
        ExpandEmployeeList,
        {{"EmployeeList", "employee ID"}}
    ),

    // Allocate output equally by headcount
    AddAllocatedOutput = Table.AddColumn(
        RenameEmployeeID,
        "Allocated Output (item qty)",
        each [#"Output (item qty)"] / [EmployeeCount],
        type number
    ),

    // Optional: keep allocated output as the reporting output column
    RemoveOldOutput = Table.RemoveColumns(AddAllocatedOutput, {"Output (item qty)", "employee ID involve"}),

    RenameAllocatedOutput = Table.RenameColumns(
        RemoveOldOutput,
        {{"Allocated Output (item qty)", "Output (item qty)"}}
    ),

    // Set data types
    ChangeTypes = Table.TransformColumnTypes(
        RenameAllocatedOutput,
        {
            {"Date", type date},
            {"TaskType", type text},
            {"employee ID", type text},
            {"Output (item qty)", type number},
            {"Work Time (h)", type number},
            {"EmployeeCount", Int64.Type}
        }
    )
in
    ChangeTypes
