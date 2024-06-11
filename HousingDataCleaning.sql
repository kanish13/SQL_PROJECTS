
-- CREATING DATABASE

create database HousingProject

-- CLEANING DATA IN SQL QUERIES

SELECT * FROM HousingProject..nashHousing

-- STANDARDIZE DATA FORMAT

SELECT SaleDate , SaleDateConverted
from HousingProject..nashHousing

alter table HousingProject..nashHousing
add SaleDateConverted Date

update HousingProject..nashHousing
set SaleDateConverted=Convert(Date,SaleDate)


-- POPULATE PROPERTY ADDRESS DATA

SELECT *
from HousingProject..nashHousing
order by ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingProject..nashHousing a
join HousingProject..nashHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]


update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingProject..nashHousing a
join HousingProject..nashHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is Null

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS,CITY,STATE)


SELECT PropertyAddress
from HousingProject..nashHousing

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from HousingProject..nashHousing

alter table HousingProject..nashHousing
add PropertySplitAddress nvarchar(300)

update HousingProject..nashHousing
set  PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table HousingProject..nashHousing
add PropertySplitCity nvarchar(300)

update HousingProject..nashHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertyAddress,PropertySplitAddress,PropertySplitCity
from HousingProject..nashHousing

SELECT OwnerAddress
from HousingProject..nashHousing

select PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerState,
PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerCity,
PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerDoor
from HousingProject..nashHousing

alter table HousingProject..nashHousing
add OwnerState nvarchar(300)

update HousingProject..nashHousing
set  OwnerState=PARSENAME(replace(OwnerAddress,',','.'),1)

alter table HousingProject..nashHousing
add OwnerCity nvarchar(300)

update HousingProject..nashHousing
set OwnerCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table HousingProject..nashHousing
add OwnerDoor nvarchar(300)

update HousingProject..nashHousing
set OwnerDoor=PARSENAME(replace(OwnerAddress,',','.'),3)

Select OwnerDoor,OwnerCity,OwnerState
from HousingProject..nashHousing

-- CHANGE Yes AND No TO Y AND N IN 'SoldAsVacant' FIELD

select SoldAsVacant
from HousingProject..nashHousing

Update HousingProject..nashHousing
set SoldAsVacant='Y'
where SoldAsVacant='Yes'

Update HousingProject..nashHousing
set SoldAsVacant='N'
where SoldAsVacant='No'

-- REMOVE DUPLICATES

with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID
) row_num
from HousingProject..nashHousing
)
Select *
from RowNumCTE
where row_num>1


-- DELETE UNUSED COLUMNS

select * 
from HousingProject..nashHousing

Alter table HousingProject..nashHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

Alter table HousingProject..nashHousing
drop column SaleDate