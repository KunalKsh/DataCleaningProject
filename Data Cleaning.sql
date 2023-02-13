
-- Selecting all data

Select * 
from dbo.HouseData

--Standardizing Date Format

Select SaleDateConverted, Convert(Date, SaleDate)
from dbo.HouseData

Update HouseData
Set SaleDate =  Convert(Date, SaleDate)

Alter Table HouseData
Add SaleDateConverted Date;

Update HouseData
Set SaleDateConverted = Convert(Date,SaleDate)

-- Populating Property Address Data

--1. Checking where PropertyAddress is null

Select * 
from dbo.HouseData
where PropertyAddress is null
order by ParcelID

--2. Join Table ParcelId with UniqueID and fill it with property address

Select A.ParcelID,A.PropertyAddress, 
B.ParcelID, B.PropertyAddress, 
ISNULL(A.PropertyAddress,B.PropertyAddress) as UpdatedAddress
from dbo.HouseData A
Join dbo.HouseData B
 on A.ParcelID = B.ParcelID
 and a.UniqueID <> b.UniqueID
 where A.PropertyAddress is null

 Update A
 Set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
 from dbo.HouseData A
Join dbo.HouseData B
 on A.ParcelID = B.ParcelID
 and a.UniqueID <> b.UniqueID
 where A.PropertyAddress is null

 -- Breaking Address into Individual Columns(ADDRESS, CITY, STATE)

 Select PropertyAddress
 from dbo.HouseData

 Select SUBSTRING(PropertyAddress,1,
 CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, 
 LEN(PropertyAddress)) as Address
 from dbo.HouseData

 Alter Table HouseData
 Add PropertySplitAddress Nvarchar(255);

 Update HouseData
 SET PropertySplitAddress = Parsename
 (Replace(PropertyAddress,',','.'),3)

 Alter Table HouseData
 Add PropertySplitCity Nvarchar(255);

 Update HouseData
 Set PropertySplitCity = PARSENAME(
 Replace(PropertyAddress,',','.'),2)

 Alter Table HouseData
 Add PropertySplitState Nvarchar(255);

 Update HouseData
 Set PropertySplitState = Parsename(
 Replace(PropertyAddress,',','.'),1)

 Select * 
 From dbo.HouseData

 --Breaking OwnerAddress using different method

 Select OwnerAddress
 From dbo.HouseData

 Select
 Parsename(Replace(OwnerAddress,',','.'),3)
 ,Parsename(Replace(OwnerAddress,',','.'),2)
 ,Parsename(Replace(OwnerAddress,',','.'),1)
 From dbo.HouseData

 Alter Table HouseData
 Add SplitOwnerAddress Nvarchar(255);

 Update HouseData
 Set SplitOwnerAddress = Parsename(
 Replace(OwnerAddress,',', '.'),3)

 Alter Table HouseData
 Add SplitOwnerCity Nvarchar(255);

 Update HouseData
 Set SplitOwnerCity = Parsename(
 Replace(OwnerAddress,',','.'),2)

 Alter Table HouseData
 Add SplitOwnerState Nvarchar(255);

 Update HouseData
 Set SplitOwnerState = Parsename(
 Replace(OwnerAddress,',','.'),1)

 Select * 
 from dbo.HouseData

 -- Renaming Y and N to Yes and No respectively in "SoldasVacant" field

Select distinct(SoldasVacant),count(SoldasVacant)
from dbo.HouseData
group by SoldAsVacant
order by 2

SELECT Soldasvacant, 
CASE 
  WHEN SoldasVacant = 'Y' THEN 'Yes' 
  When SoldAsVacant = 'N' Then 'No'
END AS SoldasVacant
FROM dbo.HouseData

Update HouseData
SET SoldAsVacant = CASE When SoldAsVacant = 'N' THEN 'NO'
	   When SoldAsVacant = 'Y' THEN 'Yes'
	   ELSE SoldAsVacant
	   END

-- Removing Duplicates
--Finding Duplicates

With CTERowNum As(
select *,
	ROW_NUMBER() OVER(
	Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
					UniqueID
					) row_num
	from dbo.HouseData)
	
--Delete duplicates

DELETE
from CTERowNum
where row_num > 1

--Deleting Unused Columns

Select * 
from dbo.HouseData

Alter table dbo.Housedata
Drop Column OwnerAddress, TaxDistrict

