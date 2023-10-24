-- Cleansed DIM_Customers Table -- 

SELECT 
  c.customerkey as CustomerKey --,[GeographyKey]
  --,[CustomerAlternateKey]
  --,[Title]
  , 
  c.FirstName as [First Name] --,[MiddleName]
  , 
  c.LastName as [Last Name], 
  c.FirstName + ' ' + c.LastName as [Full Name] --Combined first and last name--
  --,[NameStyle]
  --,[BirthDate]
  --,[MaritalStatus]
  --,[Suffix]
  , 
  case c.Gender when 'M' then 'Male' when 'F' then 'Female' end as Gender --,[EmailAddress]
  --,[YearlyIncome]
  --,[TotalChildren]
  --,[NumberChildrenAtHome]
  --,[EnglishEducation]
  --,[SpanishEducation]
  --,[FrenchEducation]
  --,[EnglishOccupation]
  --,[SpanishOccupation]
  --,[FrenchOccupation]
  --,[HouseOwnerFlag]
  --,[NumberCarsOwned]
  --,[AddressLine1]
  --,[AddressLine2]
  --,[Phone]
  , 
  c.DateFirstPurchase as DateFirstPurchase, 
  --,[CommuteDistance]
  g.city as [Customer City] -- Joined in City from Geography Table
FROM 
  [AdventureWorksDW2019].[dbo].[DimCustomer] as c 
  left join dbo.DimGeography as g on g.GeographyKey = c.GeographyKey --left join--
order by 
  CustomerKey ASC -- Order list by CustomerKey

