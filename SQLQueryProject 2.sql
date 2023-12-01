--CLEANING DATA IN SQL QUERIES

SELECT*
FROM Portfolio..NashvilleHousing


--STANDARDIZE DATE FORMAT

SELECT SaleDate
FROM Portfolio..NashvilleHousing

SELECT SaleDate, CONVERT(date,SaleDate)
FROM Portfolio..NashvilleHousing

UPDATE Portfolio..NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

ALTER TABLE Portfolio..NashvilleHousing
ADD SaleDateConverted date;

UPDATE Portfolio..NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

SELECT SaleDateConverted
FROM Portfolio..NashvilleHousing


--populate property address date---------------------

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing
where PropertyAddress is null
 
 
SELECT *
FROM Portfolio..NashvilleHousing
--where PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID,B.PropertyAddress
FROM Portfolio..NashvilleHousing A
JOIN Portfolio..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Portfolio..NashvilleHousing A
JOIN Portfolio..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Portfolio..NashvilleHousing A
JOIN Portfolio..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Portfolio..NashvilleHousing A
JOIN Portfolio..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
--WHERE A.PropertyAddress IS NULL

-----Mreaking out address into individual columns(address, city, state)---------------------------------------------


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
FROM Portfolio..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)
FROM Portfolio..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
FROM Portfolio..NashvilleHousing 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress)) as Address 
FROM Portfolio..NashvilleHousing 


ALTER TABLE Portfolio..NashvilleHousing
ADD propertysplitaddress NVARCHAR(255);

UPDATE Portfolio..NashvilleHousing
set propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Portfolio..NashvilleHousing
ADD propertysplitcity NVARCHAR(255);

UPDATE Portfolio..NashvilleHousing
set propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress))



SELECT *
FROM Portfolio..NashvilleHousing 

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Portfolio..NashvilleHousing 
 --* PARSENAME ALWAYS LOOK FROM BACKWORD



 ALTER TABLE Portfolio..NashvilleHousing
ADD Ownersplitaddress NVARCHAR(255);

UPDATE Portfolio..NashvilleHousing
set Ownersplitaddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE Portfolio..NashvilleHousing
ADD Ownersplitcity NVARCHAR(255);

UPDATE Portfolio..NashvilleHousing
set Ownersplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE Portfolio..NashvilleHousing
ADD Ownersplitstate NVARCHAR(255);

UPDATE Portfolio..NashvilleHousing
set Ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM Portfolio..NashvilleHousing 

-------------------------------------------------------------------------------------------------
---Change Y and N to Yes and No in 'sold as vacant' field--------------------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portfolio..NashvilleHousing 

UPDATE Portfolio..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-----------------------------------------------------------------------------------------
--REMOVE DUPLICATES----------------


--SELECT*,
--	ROW_NUMBER() OVER (
--	PARTITION BY ParcelID,
--				 PropertyAddress,
--				 SalePrice,
--				 SaleDate,
--				 LegalReference
--				 ORDER BY UniqueID
--				 ) row_num
--FROM Portfolio..NashvilleHousing
--ORDER BY [UniqueID ]

WITH ROWNUMCTE AS (
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM Portfolio..NashvilleHousing
--ORDER BY [UniqueID ] 
)
 SELECT *
 FROM ROWNUMCTE
 WHERE row_num > 1
 ORDER BY PropertyAddress




WITH ROWNUMCTE AS (
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM Portfolio..NashvilleHousing
--ORDER BY [UniqueID ] 
)
SELECT *
 FROM ROWNUMCTE
 WHERE row_num > 1
 --ORDER BY PropertyAddress



 -----------------------------------------------------------------------------
 --DELETE UNUSED COLUMN

 --SELECT*
 --FROM Portfolio..NashvilleHousing

 ALTER TABLE Portfolio..NashvilleHousing
 DROP COLUMN SaleDate, TaxDistrict