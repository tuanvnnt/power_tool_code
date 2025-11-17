Sales TY = SUM('Sales'[Amount])

Sales LY = CALCULATE(
    [Sales TY],
    DATEADD('Date'[Date], -1, YEAR)
)

Sales YoY % = 
DIVIDE([Sales TY] - [Sales LY], [Sales LY])

Sales MTD TY =
CALCULATE(
    SUM('Sales'[Amount]),
    DATESMTD('Date'[Date])
)

Sales MTD LY =
CALCULATE(
    [Sales MTD TY],
    DATEADD('Date'[Date], -1, YEAR)
)

Sales MTD YoY % =
DIVIDE([Sales MTD TY] - [Sales MTD LY], [Sales MTD LY])

---------------------------------------------------------------------------------

Step 1. Create a slicer table
Make a small disconnected table (no relationships) called PeriodSelector with one column:
Period
MTD
QTD
YTD
You can do this right inside Power BI with Enter Data.
Step 2. Build the measure
Sales Dynamic =
VAR _period = SELECTEDVALUE('PeriodSelector'[Period])
RETURN
SWITCH(
    TRUE(),
    _period = "MTD", CALCULATE(SUM('Sales'[Amount]), DATESMTD('Date'[Date])),
    _period = "QTD", CALCULATE(SUM('Sales'[Amount]), DATESQTD('Date'[Date])),
    _period = "YTD", CALCULATE(SUM('Sales'[Amount]), DATESYTD('Date'[Date])),
    SUM('Sales'[Amount])   -- default if nothing selected
)
Step 3. Use it in visuals
Add the Period field to a slicer visual.
Drop Sales Dynamic into your cards, charts, or tables.
Switching the slicer changes how the measure calculates — instantly flipping between MTD, QTD, and YTD views.

---------------------------------------------------------------------------------

Now your slicer controls both the period (MTD/QTD/YTD) and the year (TY/LY).
1. Create two slicer tables
Table 1 – PeriodSelector
Period
MTD
QTD
YTD
Table 2 – YearSelector
YearType
TY
LY
Both are disconnected (no relationships).
2. Dynamic measure
Sales Dynamic =
VAR _period = SELECTEDVALUE('PeriodSelector'[Period])
VAR _year   = SELECTEDVALUE('YearSelector'[YearType])
VAR _base =
    SWITCH(
        TRUE(),
        _period = "MTD", DATESMTD('Date'[Date]),
        _period = "QTD", DATESQTD('Date'[Date]),
        _period = "YTD", DATESYTD('Date'[Date]),
        ALL('Date')  -- fallback
    )
VAR _shift =
    SWITCH(
        TRUE(),
        _year = "LY", DATEADD(_base, -1, YEAR),
        _base
    )
RETURN
CALCULATE(
    SUM('Sales'[Amount]),
    _shift
)
3. How it works
_period chooses how far in the calendar you go (month-to-date, quarter-to-date, etc.).
_year chooses which year’s slice of that range you use — current (TY) or one year back (LY).
The final CALCULATE pulls sales for that shifted date range.
4. Use it
Drop both slicers — PeriodSelector[Period] and YearSelector[YearType] — on the page.
Then use Sales Dynamic in visuals.
Now you can flip from:
MTD TY → current month so far
MTD LY → same period last year
YTD TY / YTD LY → full-year vs last-year comparisons
All from one measure.

---------------------------------------------------------------------------------

You’ll have one measure that can show TY, LY, or even their YoY % difference, all driven by slicers.
1. Update the slicer table
Merge both controls into a single table called ViewSelector with this column:
View
MTD TY
MTD LY
QTD TY
QTD LY
YTD TY
YTD LY
YoY %
(still disconnected)
2. One dynamic measure
Sales Dynamic =
VAR _view = SELECTEDVALUE('ViewSelector'[View])
VAR _period =
    SWITCH(
        TRUE(),
        LEFT(_view, 3) = "MTD", DATESMTD('Date'[Date]),
        LEFT(_view, 3) = "QTD", DATESQTD('Date'[Date]),
        LEFT(_view, 3) = "YTD", DATESYTD('Date'[Date])
    )
VAR _salesTY =
    CALCULATE(
        SUM('Sales'[Amount]),
        _period
    )
VAR _salesLY =
    CALCULATE(
        SUM('Sales'[Amount]),
        DATEADD(_period, -1, YEAR)
    )
RETURN
SWITCH(
    TRUE(),
    RIGHT(_view, 2) = "TY", _salesTY,
    RIGHT(_view, 2) = "LY", _salesLY,
    _view = "YoY %", DIVIDE(_salesTY - _salesLY, _salesLY),
    _salesTY
)
3. How it behaves
Chooses MTD / QTD / YTD by reading the first three letters of the selection.
Determines TY / LY / YoY % by the ending text.
Automatically switches calculation logic — one measure covers all views.
4. Use it
Add ViewSelector[View] to a slicer.
Use Sales Dynamic in visuals (cards, charts, etc.).
Now you can click MTD TY, MTD LY, YoY %, and watch everything shift instantly.
It’s the same backbone analysts use in pro dashboards — one dynamic measure instead of six or more static ones.

---------------------------------------------------------------------------------

this is the polished version: one measure that switches between TY, LY, and YoY %, and also auto-formats itself to show the right display type.
1. Keep the same slicer table
ViewSelector
View
MTD TY
MTD LY
QTD TY
QTD LY
YTD TY
YTD LY
YoY %
Still disconnected.
2. Add the formatted measure
Sales Dynamic =
VAR _view = SELECTEDVALUE('ViewSelector'[View])
VAR _period =
    SWITCH(
        TRUE(),
        LEFT(_view,3) = "MTD", DATESMTD('Date'[Date]),
        LEFT(_view,3) = "QTD", DATESQTD('Date'[Date]),
        LEFT(_view,3) = "YTD", DATESYTD('Date'[Date])
    )
VAR _salesTY =
    CALCULATE(SUM('Sales'[Amount]), _period)
VAR _salesLY =
    CALCULATE(SUM('Sales'[Amount]), DATEADD(_period, -1, YEAR))
VAR _result =
    SWITCH(
        TRUE(),
        RIGHT(_view,2) = "TY", _salesTY,
        RIGHT(_view,2) = "LY", _salesLY,
        _view = "YoY %", DIVIDE(_salesTY - _salesLY, _salesLY),
        _salesTY
    )
VAR _format =
    SWITCH(
        TRUE(),
        _view = "YoY %", "0.0%",
        "$#,##0"
    )
RETURN
FORMAT(_result, _format)
3. What’s new
_format picks a display rule:
"0.0%" → for YoY %
"$#,##0" → for sales amounts (you can change the symbol).
FORMAT() converts the numeric result into a styled string — so your visuals show $, commas, or % correctly.
4. Quick tip
If you plan to use it in charts, keep a numeric version too (without FORMAT()), because formatted strings can’t be summed or charted smoothly.
Call that one Sales Dynamic (Value), and use the formatted one only in cards or KPI tiles.
That’s the complete flexible measure setup — one slicer, one measure, multiple perspectives, automatic formatting.

---------------------------------------------------------------------------------
Here’s the last layer — color logic for visuals or KPIs that change automatically when YoY goes up or down.
1. Keep everything from before, but add a color measure alongside your main one:
Sales Dynamic Color =
VAR _view = SELECTEDVALUE('ViewSelector'[View])
VAR _period =
    SWITCH(
        TRUE(),
        LEFT(_view,3) = "MTD", DATESMTD('Date'[Date]),
        LEFT(_view,3) = "QTD", DATESQTD('Date'[Date]),
        LEFT(_view,3) = "YTD", DATESYTD('Date'[Date])
    )
VAR _salesTY =
    CALCULATE(SUM('Sales'[Amount]), _period)
VAR _salesLY =
    CALCULATE(SUM('Sales'[Amount]), DATEADD(_period, -1, YEAR))
VAR _YoY =
    DIVIDE(_salesTY - _salesLY, _salesLY)
RETURN
SWITCH(
    TRUE(),
    _view = "YoY %" && _YoY > 0, "#4CAF50",   -- green for growth
    _view = "YoY %" && _YoY < 0, "#F44336",   -- red for decline
    "#FFFFFF"                                -- default (white/neutral)
)
2. How to use it
Keep your Sales Dynamic measure for the numeric or formatted value.
Use Sales Dynamic Color as the conditional formatting rule for font color or background color in your KPI card or table.
3. Example effect
View	Value	Color
MTD TY	$1.25M	white
MTD LY	$1.10M	white
YoY %	+13.6%	green
YoY %	−4.2%	red
This is the final polish — together, these two measures give you a full “smart” KPI: dynamic period, year logic, correct formatting, and visual feedback.


---------------------------------------------------------------------------------



