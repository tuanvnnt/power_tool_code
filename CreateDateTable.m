let
    CreateDateTable = (StartDate, EndDate) =>
let
    /*StartDate=#date(2012,1,1),
    EndDate=#date(2013,12,31),*/
    //Create lists of month and day names for use later on
    MonthList = {"January", "February", "March", "April", "May", "June"
                 , "July", "August", "September", "October", "November", "December"},
    DayList = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"},
    //Find the number of days between the end date and the start date
    NumberOfDates = Duration.Days(EndDate-StartDate),
    //Generate a continuous list of dates from the start date to the end date
    DateList = List.Dates(StartDate, NumberOfDates, #duration(1, 0, 0, 0)),
    //Turn this list into a table
    TableFromList = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}
                     , null, ExtraValues.Error),
    //Caste the single column in the table to type date
    ChangedType = Table.TransformColumnTypes(TableFromList,{{"Date", type date}}),
    //Add custom columns for day of month, month number, year
    DayOfMonth = Table.AddColumn(ChangedType, "DayOfMonth", each Date.Day([Date])),
    MonthNumber = Table.AddColumn(DayOfMonth, "MonthNumberOfYear", each Date.Month([Date])),
    Year = Table.AddColumn(MonthNumber, "Year", each Date.Year([Date])),
    DayOfWeekNumber = Table.AddColumn(Year, "DayOfWeekNumber", each Date.DayOfWeek([Date])+1),
    //Since Power Query doesn't have functions to return day or month names, 
    //use the lists created earlier for this
    MonthName = Table.AddColumn(DayOfWeekNumber, "MonthName", each MonthList{[MonthNumberOfYear]-1}),
    DayName = Table.AddColumn(MonthName, "DayName", each DayList{[DayOfWeekNumber]-1}),
    //Add a column that returns true if the date on rows is the current date
    IsToday = Table.AddColumn(DayName, "IsToday", each Date.IsInCurrentDay([Date]))
in
    IsToday
in
    CreateDateTable
