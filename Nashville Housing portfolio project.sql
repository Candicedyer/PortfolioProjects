-- Cleaning the data

-- Viewing table

SELECT*
FROM [Portfolio Project]..Nashvillehousing


-- Standardized date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [Portfolio Project]..Nashvillehousing


ALTER TABLE [Portfolio Project]..Nashvillehousing
ADD SaleDateConverted Date;

UPDATE [Portfolio Project]..Nashvillehousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Portfolio Project]..Nashvillehousing



-- Populate Property Adress Data

SELECT *
FROM [Portfolio Project]..Nashvillehousing
WHERE PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..Nashvillehousing a
JOIN [Portfolio Project]..Nashvillehousing b
ON a.ParcelID =b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..Nashvillehousing a
JOIN [Portfolio Project]..Nashvillehousing b
ON a.ParcelID =b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking Address into individual columns (address, city, state)

SELECT PropertyAddress
FROM [Portfolio Project]..Nashvillehousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [Portfolio Project]..Nashvillehousing

ALTER TABLE [Portfolio Project]..Nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [Portfolio Project]..Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [Portfolio Project]..Nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE [Portfolio Project]..Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM [Portfolio Project]..Nashvillehousing


--

SELECT OwnerAddress
FROM [Portfolio Project]..Nashvillehousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM [Portfolio Project]..Nashvillehousing

ALTER TABLE [Portfolio Project]..Nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Portfolio Project]..Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE [Portfolio Project]..Nashvillehousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Portfolio Project]..Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE [Portfolio Project]..Nashvillehousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Portfolio Project]..Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM [Portfolio Project]..Nashvillehousing



--Change Y and N to yes and no

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM [Portfolio Project]..Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END 
FROM [Portfolio Project]..Nashvillehousing


UPDATE [Portfolio Project]..Nashvillehousing
SET SoldAsVacant= CASE When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END 


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM [Portfolio Project]..Nashvillehousing

)
DELETE
FROM RowNumCTE
WHERE row_num >1


-- Delete Unused Columns

SELECT *
FROM [Portfolio Project]..Nashvillehousing

ALTER TABLE [Portfolio Project]..Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress