---------------------------------------------------------------------------------------------------------------------------------
--Standardize Date Format
SELECT SaleDateConverted
FROM NashvilleHousing   


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID=b.ParcelID 
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID=b.ParcelID 
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL

---Updated Data
SELECT*
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------
--Breaking Data Into Individuals Columns(Address,City,State)

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing


select PropertyAddress
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(250)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(250)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT OwnerAddress
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL;

--Alternative method 
SELECT 
PARSENAME(REPLACE(OwnerAddress ,',','.'),3),
PARSENAME(REPLACE(OwnerAddress ,',','.'),2),
PARSENAME(REPLACE(OwnerAddress ,',','.'),1)
FROM NashvilleHousing
where OwnerAddress is not NULL

--For Address
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(250)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress ,',','.'),3)

--For City

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(250)

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress ,',','.'),2)

--For State

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(250)

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress ,',','.'),1)
--Check Filtered Data
SELECT*
From NashvilleHousing
WHERE OwnerAddress IS NOT NULL

--------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sola as Vacant "Field
select SoldAsVacant, 
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
     Else SoldAsVacant
     END as new
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
     Else SoldAsVacant
     END
select*
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------
--Removing Dublicates
WITH RowNumCTE AS(
SELECT*,ROW_NUMBER() OVER(PARTITION BY ParcelID,
                                       PropertyAddress,
                                       SalePrice,
                                       SaleDate,
                                       LegalReference  
                                       ORDER BY 
                                       UniqueID ) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1

--------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

select*
from NashvilleHousing
