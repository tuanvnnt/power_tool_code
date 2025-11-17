------------------ Monthly Quantity Summary (MTD / YTD / PrevYear)
EVALUATE
SUMMARIZECOLUMNS (
    date_tb[Year],
    date_tb[Month_Number_Of_Year],

    "Qty", [Qty],
    "Qty MTD", TOTALMTD ( [Qty], date_tb[Date] ),
    "Qty YTD", TOTALYTD ( [Qty], date_tb[Date] ),
    "Qty PrevYear", CALCULATE ( [Qty], SAMEPERIODLASTYEAR ( date_tb[Date] ) )
)
ORDER BY
    date_tb[Year],
    date_tb[Month_Number_Of_Year]

------------------ Monthly Quantity Summary by Direction (MTD / YTD / PrevYear)
EVALUATE
SUMMARIZECOLUMNS (
    date_tb[Year],
    date_tb[Month_Number_Of_Year],
    PBI_inout_custom[direction],

    "Qty", [Qty],
    "Qty MTD", TOTALMTD ( [Qty], date_tb[Date] ),
    "Qty YTD", TOTALYTD ( [Qty], date_tb[Date] ),
    "Qty PrevYear", CALCULATE ( [Qty], SAMEPERIODLASTYEAR ( date_tb[Date] ) )
)
ORDER BY
    date_tb[Year],
    date_tb[Month_Number_Of_Year],
    PBI_inout_custom[direction]

------------------ Monthly Qty Summary by Direction & Brand (MTD / YTD / PrevYear / YoY %)
EVALUATE
VAR BaseTable =
    SUMMARIZECOLUMNS (
        date_tb[Year],
        date_tb[Month_Number_Of_Year],
        PBI_inout_custom[direction],
        brand[brand_name],

        "Qty", [Qty],
        "Qty MTD", TOTALMTD ( [Qty], date_tb[Date] ),
        "Qty YTD", TOTALYTD ( [Qty], date_tb[Date] ),
        "Qty PrevYear", CALCULATE ( [Qty], SAMEPERIODLASTYEAR ( date_tb[Date] ) )
    )
RETURN
    ADDCOLUMNS (
        BaseTable,
        "YoY %", 
            VAR CurrentQty = [Qty]
            VAR PrevQty = [Qty PrevYear]
            RETURN 
                IF (
                    NOT ISBLANK(PrevQty) && PrevQty <> 0,
                    DIVIDE(CurrentQty - PrevQty, PrevQty),
                    BLANK()
                )
    )
ORDER BY
    date_tb[Year],
    date_tb[Month_Number_Of_Year],
    PBI_inout_custom[direction],
    brand[brand_name]

------------------ Top 5 Brands – Monthly Qty Summary by Direction (MTD / YTD / PrevYear / YoY %)
DEFINE
    VAR TopNBrands =
        TOPN (
            5,
            SUMMARIZE (
                brand,
                brand[brand_name],
                "TotalQty", CALCULATE ( [Qty] )
            ),
            [TotalQty], DESC
        )
EVALUATE
VAR BaseTable =
    CALCULATETABLE (
        SUMMARIZECOLUMNS (
            date_tb[Year],
            date_tb[Month_Number_Of_Year],
            PBI_inout_custom[direction],
            brand[brand_name],
            "Qty", [Qty],
            "Qty MTD", TOTALMTD ( [Qty], date_tb[Date] ),
            "Qty YTD", TOTALYTD ( [Qty], date_tb[Date] ),
            "Qty PrevYear", CALCULATE ( [Qty], SAMEPERIODLASTYEAR ( date_tb[Date] ) )
        ),
        KEEPFILTERS ( TopNBrands )
    )
RETURN
    ADDCOLUMNS (
        BaseTable,
        "YoY %",
            VAR CurrentQty = [Qty]
            VAR PrevQty = [Qty PrevYear]
            RETURN
                IF (
                    NOT ISBLANK ( PrevQty ) && PrevQty <> 0,
                    DIVIDE ( CurrentQty - PrevQty, PrevQty ),
                    BLANK()
                )
    )
ORDER BY
    date_tb[Year],
    date_tb[Month_Number_Of_Year],
    PBI_inout_custom[direction],
    brand[brand_name]

------------------ Show top 10 row in inbound table
EVALUATE
TOPN(
5,  			-- number of rows you want
'inbound', 		-- table
'inbound'[id], 	-- order by expression
DESC			-- order direction
)
    
------------------ Summarized box qty per brand in table inbound 
EVALUATE
SUMMARIZE(
    'inbound',
    'inbound'[brand_name],
    "TotalQty", SUM('inbound'[box_qty])
)

------------------ filter row have box_qty > 1000
EVALUATE
FILTER(
    'inbound',
    'inbound'[box_qty] > 1000
)

------------------ DAX Studio Template: SELECT-like Query
EVALUATE
ADDCOLUMNS(
    SUMMARIZE(
        'YourTable',
        'YourTable'[GroupColumn1],
        'YourTable'[GroupColumn2]
    ),
    "NewMeasure1", [YourMeasure1],
    "NewMeasure2", [YourMeasure2]
)
ORDER BY [NewMeasure1] DESC
	--SQL Concept	DAX Equivalent								Notes
	--SELECT		ADDCOLUMNS()								Add new calculated columns
	--FROM			'YourTable' inside SUMMARIZE()				The source table
	--GROUP BY		Columns listed in SUMMARIZE()				Grouping logic
	--WHERE			Wrap entire thing in FILTER() if needed		Optional
	--ORDER BY		Use ORDER BY at the bottom					DAX supports this too

------------------ SUMMARIZECOLUMNS
EVALUATE
SUMMARIZECOLUMNS(
    'PBI_inout_custom'[direction],
    "TotalQty", SUM('PBI_inout_custom'[qty])
)
	--SELECT direction, SUM(qty)
	--FROM PBI_inout_custom
	--GROUP BY direction

------------------ Example With Filter (WHERE)
EVALUATE
TOPN(
    10,
    ADDCOLUMNS(
        SUMMARIZE(
            FILTER(
                'PBI_inout_custom',
                'PBI_inout_custom'[direction] = "Inbound"
            ),
            'PBI_inout_custom'[brand_name]
        ),
        "TotalQty", SUM('PBI_inout_custom'[qty])
    ),
    [TotalQty],
    DESC
)

------------------ step by step , simple to complicate
	EVALUATE 'PBI_inout_custom'
	-- grouping
	EVALUATE
	SUMMARIZE('PBI_inout_custom', 'PBI_inout_custom'[direction])
	-- add column
	EVALUATE
	ADDCOLUMNS(
	    SUMMARIZE('PBI_inout_custom', 'PBI_inout_custom'[direction]),
	    "TotalQty", SUM('PBI_inout_custom'[qty])
	)
	-- select column
	EVALUATE
	SELECTCOLUMNS(
	    date_tb,
	    "Year", date_tb[Year],
	    "Month", date_tb[Month_Number_Of_Year]
	)
	-- add filter
	EVALUATE
	FILTER(
	    date_tb,
	    date_tb[Year] = 2023
	)
	EVALUATE
	FILTER(
	    'PBI_inout_custom',
	    'PBI_inout_custom'[direction] = "Inbound"
	)
	-- group by
	EVALUATE
	SUMMARIZE(
	    'PBI_inout_custom',
	    'PBI_inout_custom'[direction]
	)
	EVALUATE
	SUMMARIZE(
	    FILTER(
	        'PBI_inout_custom',
	        'PBI_inout_custom'[direction] = "Outbound"
	    ),
	    'PBI_inout_custom'[type],
	    "Qty", SUM('PBI_inout_custom'[qty])
	)
	-- group and sumarize a number
	EVALUATE
	SUMMARIZE(
	    'PBI_inout_custom',
	    'PBI_inout_custom'[direction],
	    "TotalQty", SUM('PBI_inout_custom'[qty])
	)
	-- add more column
	EVALUATE
	ADDCOLUMNS(
	    SUMMARIZE('PBI_inout_custom', 'PBI_inout_custom'[direction]),
	    "Qty", SUM('PBI_inout_custom'[qty]),
	    "RowCount", COUNTROWS('PBI_inout_custom')
	)
	-- sorting and top 5
	EVALUATE
	TOPN(
	    5,
	    ADDCOLUMNS(
	        SUMMARIZE(
	            FILTER('PBI_inout_custom', 'PBI_inout_custom'[direction] = "Outbound"),
	            'PBI_inout_custom'[brand_name]
	        ),
	        "TotalQty", SUM('PBI_inout_custom'[qty])
	    ),
	    [TotalQty],
	    DESC
	)
	-- Qty YTD (Year-to-Date)
	EVALUATE
	SUMMARIZECOLUMNS(
	    'date_tb'[Year],
	    "Qty YTD", TOTALYTD(
	        SUM('PBI_inout_custom'[qty]),
	        'date_tb'[Date]
	    )
	)
	-- Qty MTD (Month-to-Date)
	EVALUATE
	SUMMARIZECOLUMNS(
	    'date_tb'[Month_Name],
	    "Qty MTD", TOTALMTD(
	        SUM('PBI_inout_custom'[qty]),
	        'date_tb'[Date]
	    )
	)
	-- Qty Previous Year (YoY comparison)
	EVALUATE
	SUMMARIZECOLUMNS(
	    'date_tb'[Year],
	    "Qty LY", CALCULATE(
	        SUM('PBI_inout_custom'[qty]),
	        SAMEPERIODLASTYEAR('date_tb'[Date])
	    )
	)

------------------ YoY Summary – Yearly Qty with PrevYear & YoY%
EVALUATE
ADDCOLUMNS(
    SUMMARIZECOLUMNS('date_tb'[Year]),
    "ThisYear", CALCULATE(SUM('PBI_inout_custom'[qty])),
    "LastYear", CALCULATE(
        SUM('PBI_inout_custom'[qty]),
        SAMEPERIODLASTYEAR('date_tb'[Date])
    ),
    "YoY%", DIVIDE(
        CALCULATE(SUM('PBI_inout_custom'[qty])) 
        - CALCULATE(SUM('PBI_inout_custom'[qty]), SAMEPERIODLASTYEAR('date_tb'[Date])),
        CALCULATE(SUM('PBI_inout_custom'[qty]), SAMEPERIODLASTYEAR('date_tb'[Date]))
    )
)

------------------ Monthly Qty Summary – ThisMonth vs LastMonth (using Year + Month Number)
EVALUATE
ADDCOLUMNS(
    SUMMARIZECOLUMNS('date_tb'[Year], 'date_tb'[Month_Number_Of_Year]),
    "ThisMonth", CALCULATE(SUM('PBI_inout_custom'[qty])),
    "LastMonth", CALCULATE(
        SUM('PBI_inout_custom'[qty]),
        PREVIOUSMONTH('date_tb'[Date])
    ),
    "MoM%", DIVIDE(
        CALCULATE(SUM('PBI_inout_custom'[qty])) 
        - CALCULATE(SUM('PBI_inout_custom'[qty]), PREVIOUSMONTH('date_tb'[Date])),
        CALCULATE(SUM('PBI_inout_custom'[qty]), PREVIOUSMONTH('date_tb'[Date]))
    )
)

------------------ Running Total (Cumulative Qty)
EVALUATE
ADDCOLUMNS(
    SUMMARIZECOLUMNS('date_tb'[Date]),
    "RunningQty", CALCULATE(
        SUM('PBI_inout_custom'[qty]),
        FILTER(
            ALL('date_tb'),
            'date_tb'[Date] <= MAX('date_tb'[Date])
        )
    )
)

------------------ QTD / YTD Monthly Summary
EVALUATE
ADDCOLUMNS(
    SUMMARIZECOLUMNS(
        'date_tb'[Year],
        'date_tb'[Month_Number_Of_Year]
    ),
    "Qty", CALCULATE(SUM('PBI_inout_custom'[qty])),
    "Qty QTD", TOTALQTD(
        SUM('PBI_inout_custom'[qty]),
        'date_tb'[Date]
    ),
    "Qty YTD", TOTALYTD(
        SUM('PBI_inout_custom'[qty]),
        'date_tb'[Date]
    )
)
ORDER BY
    'date_tb'[Year],
    'date_tb'[Month_Number_Of_Year]

------------------ QTD / YTD Monthly Summary by Direction
EVALUATE
ADDCOLUMNS(
    SUMMARIZECOLUMNS(
        'date_tb'[Year],
        'date_tb'[Month_Number_Of_Year],
        'PBI_inout_custom'[direction]
    ),
    "Qty", CALCULATE(SUM('PBI_inout_custom'[qty])),
    "Qty QTD", CALCULATE(
        TOTALQTD(SUM('PBI_inout_custom'[qty]), 'date_tb'[Date])
    ),
    "Qty YTD", CALCULATE(
        TOTALYTD(SUM('PBI_inout_custom'[qty]), 'date_tb'[Date])
    )
)
ORDER BY
    'date_tb'[Year],
    'date_tb'[Month_Number_Of_Year],
    'PBI_inout_custom'[direction]

------------------ QTD_YTD_YoY_MoM_by_Direction
EVALUATE
ADDCOLUMNS(
    SUMMARIZECOLUMNS(
        'date_tb'[Year],
        'date_tb'[Month_Number_Of_Year],
        'PBI_inout_custom'[direction]
    ),
    "Qty", CALCULATE(SUM('PBI_inout_custom'[qty])),
    "Qty QTD", CALCULATE(
        TOTALQTD(SUM('PBI_inout_custom'[qty]), 'date_tb'[Date])
    ),
    "Qty YTD", CALCULATE(
        TOTALYTD(SUM('PBI_inout_custom'[qty]), 'date_tb'[Date])
    ),
    "Qty LastYear", CALCULATE(
        SUM('PBI_inout_custom'[qty]),
        SAMEPERIODLASTYEAR('date_tb'[Date])
    ),
    "YoY%", DIVIDE(
        CALCULATE(SUM('PBI_inout_custom'[qty]))
        - CALCULATE(SUM('PBI_inout_custom'[qty]), SAMEPERIODLASTYEAR('date_tb'[Date])),
        CALCULATE(SUM('PBI_inout_custom'[qty]), SAMEPERIODLASTYEAR('date_tb'[Date]))
    ),
    "Qty LastMonth", CALCULATE(
        SUM('PBI_inout_custom'[qty]),
        PREVIOUSMONTH('date_tb'[Date])
    ),
    "MoM%", DIVIDE(
        CALCULATE(SUM('PBI_inout_custom'[qty]))
        - CALCULATE(SUM('PBI_inout_custom'[qty]), PREVIOUSMONTH('date_tb'[Date])),
        CALCULATE(SUM('PBI_inout_custom'[qty]), PREVIOUSMONTH('date_tb'[Date]))
    )
)
ORDER BY
    'date_tb'[Year],
    'date_tb'[Month_Number_Of_Year],
    'PBI_inout_custom'[direction]
