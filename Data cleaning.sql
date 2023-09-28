--DATA CLEANSING

SELECT *
FROM Nashville

--FORMATTING SALES DATE 

ALTER TABLE Nashville
ADD DateConverted date

UPDATE Nashville
SET DateConverted=CAST(SaleDate AS date)

--Populate empty Property Address column
SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.[UniqueID ]<>b.[UniqueID ]
AND a.ParcelID=b.ParcelID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
					FROM Nashville a
					JOIN Nashville b
					ON a.[UniqueID ]<>b.[UniqueID ]
					AND a.ParcelID=b.ParcelID
					WHERE a.PropertyAddress IS NULL


--Splitting addresses into individual columns (Address, City, State)
SELECT PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS [Address],
	   SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM Nashville

ALTER TABLE Nashville
ADD PropertySplitAddress nvarchar(100)

UPDATE Nashville
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville
ADD PropertySplitCity nvarchar(100)

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT OwnerAddress
FROM Nashville

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashville

ALTER TABLE Nashville
ADD PropertySplitState nvarchar(100)

UPDATE Nashville
SET PropertySplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--CHANGE Y AND N to Yes AND No in 'SoldAsVacant'
SELECT SoldAsVacant,
		CASE

		WHEN SoldAsVacant = 'No' THEN 'N' ELSE 'Y'

		END
FROM Nashville

UPDATE Nashville
SET SoldAsVacant=CASE
				  WHEN SoldAsVacant = 'No' THEN 'N' ELSE 'Y'
				  END


--REMOVE DUPLICATES
WITH CTE_DUP
AS (
SELECT *,ROW_NUMBER() OVER (PARTITION BY PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID ) as row_num
FROM Nashville
)
DELETE CTE_DUP
WHERE row_num>1


--DROP UNUSED COLUMNS
ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate

SELECT * FROM Nashville