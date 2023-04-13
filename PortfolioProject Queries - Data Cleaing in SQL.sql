/* Cleaning data in SQL Queries */

SELECT * 
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------
--standarize date 

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing --PortFolio projects is already selected
--or use Update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing --Added a column SaleDateConverted
ADD SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT(date,SaleDate)

-------------------------------------------------------------------------
--Populate property address data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
		-- Joined the table to itself, ParcelId is same but its not the same row
WHERE a.PropertyAddress is null

UPDATE a --a.NashwvilleHousing
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------
-- Breaking out Address into individual columns (Address, City, State)


SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 /*Removing the comma at the end*/) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 /*Removing the comma at the begining*/ , LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


--Lets split this but lets do this a little differently

SELECT OwnerAddress
FROM NashvilleHousing
	
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),--Parsename only uses '.' so replace ',' with '.'
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------

--Change 'Y' and 'N' to 'Yes' and 'No' in "Sold as vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

-------------------------------------------------------------------------

--Remove Duplicates

WITH row_numCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
			) row_num

FROM NashvilleHousing
--ORDER BY ParcelID
)
 DELETE  --SELECT * 
FROM row_numCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-------------------------------------------------------------------------
--Delete Unused Columns

SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate