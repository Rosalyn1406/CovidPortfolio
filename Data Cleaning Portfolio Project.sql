-- Cleaning data in SQL Series

select *
from PortfolioProject..NashvilleHousing

-- a) Standardize Date Format
select SaleDateConverted, convert(date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)

-- b) Populate Property Address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- Looking at Property Address that is null 
select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b 
	 on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null  -- this shows us 35 rows of Property Address that is null

-- Populate the null Property Address to the same ParcelID that has the address
select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b 
	 on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a  
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b 
	 on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]

/* 
Note:
a) have to use alias name in update if there is join statement
b) isnull(a.PropertyAddress,b.PropertyAddress) can be given a name to a.PropertyAddress _> isnull(a.PropertyAddress,'No Address')
c) Some same ParcelID has no Property Address in one of them, so we need to populate them 
d) isnull(a.PropertyAddress,b.PropertyAddress) takes b.PropertyAddress and puts it into the null a.PropertyAddress)
*/

-- c) Breaking out Address into Individual Columns (Address, City, State)

-- i) Property Address
select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as "Address" 
, substring(PropertyAddress, charindex(',', PropertyAddress) +1 , len(PropertyAddress)) as "Address"  
from PortfolioProject..NashvilleHousing

/*
a) substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as "Address" 
- taking PropertyAddress, starting from 1st position, finish at ',' and exclude the ','

b) substring(PropertyAddress, charindex(',', PropertyAddress) +1 , len(PropertyAddress)) as "Address"  
- taking PropertyAdreess, starting at the charindex with the ',' itself, finish at the length of PropertyAddress 
*/

-- Updating the two columns
alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) 

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1 , len(PropertyAddress)) 

-- ii) Owner Address: address, city, state
select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
parsename(replace(OwnerAddress, ',','.'), 3),  -- address
parsename(replace(OwnerAddress, ',','.'), 2),  -- city
parsename(replace(OwnerAddress, ',','.'), 1)   -- State
from PortfolioProject.dbo.NashvilleHousing

/*
Notes: 
a) parsename works with period (.)
b) replace all comas(,) with period (.)
c) parsename output things backward so go by 3,2,1
*/

-- Update and Insert Owner Address Column for:

-- i) Address
alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.'), 3)

-- ii) City
alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.'), 2)

-- iii) State
alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'), 1)

-- d) Change Y and N to Yes and No in "Sold as Vacant" field

-- Count how many yes, no, y and n
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by (SoldAsVacant)
order by 2

-- Changing y and n to yes and no
select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

-- Updating 
update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
end

-- e) Removing Duplicates

with RowNumCTE as (
select *, 
	row_number () over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueId
					) row_num
from PortfolioProject..NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
-- Shows Duplicates
	--select *
	--from RowNumCTE
	--where row_num > 1
	--order by PropertyAddress   
-- Deleting the duplicates
	--delete
	--from RowNumCTE
	--where row_num > 1

-- f) Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate -- delete sale date as well
