let
    dbPath = "C:\Users\user\OneDrive - MAISON RMI\inventory_database_111_onedrive\inbound_outbound.sqlite3",
    Source = Odbc.DataSource("Driver={SQLite3 ODBC Driver};Database=" & dbPath, [HierarchicalNavigation=true]),
    QueryResult = Odbc.Query(
        "Driver={SQLite3 ODBC Driver};Database=" & dbPath,
        "SELECT DISTINCT do_num FROM inbound WHERE DATE(gi_date) >= DATE('2024-12-13', '-7 days');"
    ),
    #"Renamed Columns" = Table.RenameColumns(QueryResult,{{"do_num", "CURRENT DO"}})
in
    #"Renamed Columns"
