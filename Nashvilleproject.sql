/*

Cleaning Data in SQL Queries

*/

Select *
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing 
set SaleDate = CONVERT(Date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing 
set SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into two new indivdual comumns (Address, City, State)

Select *
from PortfolioProject.dbo.NashvilleHousing 

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing --adding column to table
add PropertySplitAddress nvarchar(255); 

update NashvilleHousing --adding data into new column 
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

Alter table NashvilleHousing --adding column to table
add PropertySplitCity nvarchar(255)

update NashvilleHousing ----adding data into new column 
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))

--split owner address
select
PARSENAME(replace(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)
from NashvilleHousing

Alter table NashvilleHousing 
add OwnerSplitAddress nvarchar(255); 

update NashvilleHousing 
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3)

Alter table NashvilleHousing 
add OwnerSplitCity nvarchar(255);

update NashvilleHousing 
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2)

Alter table NashvilleHousing 
add OwnerSplitState nvarchar(255)

update NashvilleHousing 
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1)

--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
 Case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end

--Remove Duplicates
with rownumctw as (
select *,
	ROW_NUMBER() over (
	Partition by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID 
					) row_num

from PortfolioProject.dbo.NashvilleHousing
)
delete
from rownumctw
where row_num > 1

-- Delete unused colomn

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop COLUMN SaleDate
