-- Cleansed DIM_DateTable and rename. -- 
SELECT  
	   [DateKey],
       [FullDateAlternateKey] as Date,
      --[DayNumberOfWeek]
       [EnglishDayNameOfWeek] as Day,
      --[SpanishDayNameOfWeek]
      --[FrenchDayNameOfWeek]
      --[DayNumberOfMonth]
      --[DayNumberOfYear]
       [WeekNumberOfYear] as WeekNumber,
       [EnglishMonthName] as Month,
	   left([EnglishMonthName],3) as MonthShort, --abbreviate the month with the first 3 characters-- 
      --[SpanishMonthName]
      --[FrenchMonthName]
       [MonthNumberOfYear] as MonthNumber,
       [CalendarQuarter] as Quarter,
       [CalendarYear] as Year
      --[CalendarSemester]
      --[FiscalQuarter]
      --[FiscalYear]
      --[FiscalSemester]
  FROM [AdventureWorksDW2019].[dbo].[DimDate]
  where CalendarYear >= 2019
