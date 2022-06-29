/*
Cleaning Data in SQL Queries
-- Standardize Date Format

-- Populate Property Address Data

-- Breaking out address into Individual Columns (Address, City, State)

-- Change Y and N to Yes and No in "Sold as vacant field"

-- Remove Duplicates

-- Delete Unused columns
*/
USE Housing;
SET SQL_SAFE_UPDATES = 0;
-- Standardize Date Format
SELECT * 
FROM `nashville housing data for datacleaning`;

SELECT SaleDateConverted
FROM `nashville housing data for datacleaning`;

SELECT STR_TO_DATE(SaleDate, '%M %d %Y')
FROM `nashville housing data for datacleaning`;

UPDATE `nashville housing data for datacleaning`
SET SaleDate = replace(SaleDate, ',','');

ALTER TABLE `nashville housing data for datacleaning`
ADD SaleDateConverted Date;
UPDATE `nashville housing data for datacleaning`
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %d %Y');

SELECT STR_TO_DATE(SaleDate, '%M %d %Y')
as formatted_date
FROM  `nashville housing data for datacleaning`;

-- Populate Property Address Data
-- WHERE PropertyAddress IS NULL;
SELECT *
FROM `nashville housing data for datacleaning`
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress )
FROM `nashville housing data for datacleaning` a
join `nashville housing data for datacleaning` b
   on a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress);
-- FROM `nashville housing data for datacleaning` a
-- join `nashville housing data for datacleaning` b
--    on a.ParcelID = b.ParcelID
--    AND a.UniqueID <> b.UniqueID
-- WHERE a.PropertyAddress is null;

-- Breaking out address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM `nashville housing data for datacleaning`;

SELECT substring(PropertyAddress, 1, locate(',',PropertyAddress)-1) as Address,
	substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress)) as City
FROM `nashville housing data for datacleaning`;

ALTER TABLE `nashville housing data for datacleaning`
ADD PropertySplitAddress Nvarchar(255);
UPDATE `nashville housing data for datacleaning`
SET PropertySplitAddress = substring(PropertyAddress, 1, locate(',',PropertyAddress)-1);

ALTER TABLE `nashville housing data for datacleaning`
ADD PropertySplitCity Nvarchar(255);
UPDATE `nashville housing data for datacleaning`
SET PropertySplitCity = substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress));

SELECT *
FROM `nashville housing data for datacleaning`;

-- SELECT locate ('@','rajendra.gupta16@gmail.com') as 'CharacterPosition'

-- Looking at the Owner's Address


SELECT SUBSTRING_INDEX(REPLACE(OwnerAddress,',','.'),'.',1) AS ADDRES,
	SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress,',','.'),'.',2),'.',-1 ) AS ADDRESnew,
	SUBSTRING_INDEX(REPLACE(OwnerAddress,',','.'),'.',-1) AS NEWADDR
   -- substring(OwnerAddress,locate(',',OwnerAddress)+1,locate(',',OwnerAddress)) as addre
FROM `nashville housing data for datacleaning`;

ALTER TABLE `nashville housing data for datacleaning`
ADD OwnerSplitAddress Nvarchar(255);
UPDATE `nashville housing data for datacleaning`
SET OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress,',','.'),'.',1);

ALTER TABLE `nashville housing data for datacleaning`
ADD OwnerSplitCity Nvarchar(255);
UPDATE `nashville housing data for datacleaning`
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress,',','.'),'.',2),'.',-1 );

ALTER TABLE `nashville housing data for datacleaning`
ADD OwnerSplitState Nvarchar(255);
UPDATE `nashville housing data for datacleaning`
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress,',','.'),'.',-1);

SELECT *
FROM `nashville housing data for datacleaning`;

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `nashville housing data for datacleaning`
GROUP BY SoldAsVacant
ORDER BY 2; 

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant - 'Y' THEN 'Yes'
     WHEN SoldAsVacant - 'N' THEN 'No'
	 ELSE SoldAsVacant
     END
FROM `nashville housing data for datacleaning`;

UPDATE `nashville housing data for datacleaning`
SET SoldAsVacant = 
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END;

-- Remove Duplicates
-- Let's first identify duplicate rows and then delete it
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
					UniqueID
                    ) row_num
FROM `nashville housing data for datacleaning`
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- DELETE UNUSED COLUMNS

SELECT *
FROM `nashville housing data for datacleaning`;

ALTER TABLE `nashville housing data for datacleaning`
DROP COLUMN OwnerAddress;
ALTER TABLE `nashville housing data for datacleaning`
DROP COLUMN PropertyAddress;
ALTER TABLE `nashville housing data for datacleaning`
DROP COLUMN TaxDistrict;
ALTER TABLE `nashville housing data for datacleaning`
DROP COLUMN SaleDate;
