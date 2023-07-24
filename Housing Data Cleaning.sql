# Data Cleaning

use DataProject;
select * 
from NashvilleHousing limit 5;

----------------------------------------------------------------------------------
-- Standardize Data Format
-- select SaleDate, convert(date, SaleDate) as Date1
-- from NashvilleHousing;

----------------------------------------------------------------------------------
-- Polulate Property Address data (fill empty field in PropertyAddress)
select * 
from NashvilleHousing
where PropertyAddress = '';

   # Same ParcelID has same PropertyAddress
set SQL_safe_Updates = 0;  # to enable update

with t1 as (
select a.ParcelID, a.PropertyAddress,
case when a.PropertyAddress = '' then b.PropertyAddress end as ProAddUpdate
from NashvilleHousing a
join NashvilleHOusing b
     on a.ParcelID = b.ParcelID
     and a.UniqueID <> b.UniqueID
where a.PropertyAddress = '')
-- select ParcelID from t1;

update NashvilleHousing n
join t1
on n.ParcelID = t1.ParcelID
set n.PropertyAddress = t1.ProAddUpdate
where n.ParcelID = t1.ParcelID and n.PropertyAddress = '';

--------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
   # based on period '.'
select PropertyAddress
from NashvilleHousing;

select PropertyAddress, left(PropertyAddress, position('.' in PropertyAddress)-1) as street,
right(PropertyAddress, length(PropertyAddress) - position('.' in PropertyAddress)) as city
from NashvilleHousing;

alter table NashvilleHousing
add street varchar(255);

update NashvilleHousing
set street = left(PropertyAddress, position('.' in PropertyAddress)-1);

alter table NashvilleHousing
add city varchar(255);

update NashvilleHousing
set city = right(PropertyAddress, length(PropertyAddress) - position('.' in PropertyAddress));

select * from NashvilleHousing limit 5;
--------------------------------------------------------------------------------
-- change Y and N to Yes and No in 'Sold As Vacant' field.
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
where SoldAsVacant = 'Y' or SoldAsVacant = 'N'
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'yes'
     when SoldAsVacant = 'N' Then 'no' 
     else SoldAsVacant end as SoldAsVacant_update
from NashvilleHousing
where SoldAsVacant = 'Y' or SoldAsVacant = 'N';

Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'yes'
     when SoldAsVacant = 'N' Then 'no' 
     else SoldAsVacant end;

-------------------------------------------------------------------------
-- Remove duplicates
   # row_number(): assigns a sequential number to each row in the result set
	
    #alter table NashvilleHousing
	#drop RowNum;
SET sql_mode = '';

alter table NashvilleHousing
add Num int;

with RowNumTable as (
select ParcelID, row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate
                          order by UniqueID) RowNum
from NashvilleHousing
)
update NashvilleHousing n
join RowNumTable
on n.ParcelID = RowNumTable.ParcelID
set n.Num = RowNumTable.RowNum;

select * from NashvilleHousing limit 5;

Delete
from NashvilleHousing
where Num >1;

select * 
from NashvilleHousing
where Num >1;

--------------------------------------------------------
-- Delete Unused Columns

alter table NashvilleHousing
drop column OwnerAddress, 
drop column TaxDistrict;

select * from NashvilleHousing;