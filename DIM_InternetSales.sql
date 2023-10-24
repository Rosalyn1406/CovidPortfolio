--Cleansed Fact_InternetSales Table--
SELECT 
  [ProductKey], 
  [OrderDateKey], 
  [DueDateKey], 
  [ShipDateKey], 
  [CustomerKey] 
  --,[PromotionKey]
  --,[CurrencyKey]
  --,[SalesTerritoryKey]
  , [SalesOrderNumber] 
  --,[SalesOrderLineNumber]
  --,[RevisionNumber]
  --,[OrderQuantity]
  --,[UnitPrice]
  --,[ExtendedAmount]
  --,[UnitPriceDiscountPct]
  --,[DiscountAmount]
  --,[ProductStandardCost]
  --,[TotalProductCost]
  , [SalesAmount] 
  --,[TaxAmt]
  --,[Freight]
  --,[CarrierTrackingNumber]
  --,[CustomerPONumber]
  --,[OrderDate]
  --,[DueDate]
  --,[ShipDate]
FROM 
  [AdventureWorksDW2019].[dbo].[FactInternetSales] 
where 
  left(OrderDateKey, 4) >= year(getdate()) -2 --Only bring two years of date from extraction--
order by 
  OrderDateKey asc

/*
Note: 
a) left(OrderDateKey,4): taking the first 4 characters on the left 
b) getdate() : gets today's date
c) year(getdate()) : gets the year of today's date
d) year(getdate()) - 2: gets the year of today's date subtract 2
*/