**Anmol's Portfolio Project**

**Motorcycle Sales Data Analysis in India**


**Overview**
This project analyzes motorcycle sales data in India using SQL to clean, standardize, and extract insights. The goal is to provide business-driven recommendations to improve sales, optimize inventory, and enhance customer engagement.


**Dataset**
The dataset was generated using chatGPT which contains motorcycle sales transactions, including:
- Dealer Details (Dealer Name, State, City)
- Bike Information (Brand, Model, Category, Engine CC)
- Sales Data (Sale Date, Quantity, Payment Mode)


**Data Cleaning & Standardization**

-- 1. Converted sale_date and engine_cc columns to appropriate data types.

```sql

alter table motorcycle_sales_india
modify sale_date date ;

alter table motorcycle_sales_india
modify Engine_CC int ;

-- 2. Rearranged columns (Dealer_Name, State, City) for better readability.

alter table motorcycle_sales_india
modify column Dealer_Name varchar(225) after Sale_ID;

alter table motorcycle_sales_india
modify column State varchar(225) after Dealer_Name;

alter table motorcycle_sales_india
modify column City varchar(225) after State;

-- 3. Standardized engine_cc by removing 'cc' from values.

select bike_model, engine_cc, left(engine_cc,3) AS cc
from motorcycle_sales_india;

update motorcycle_sales_india
set Engine_CC = left(engine_cc,3);

-- 4. Merged Loan & EMI payment modes into a new category called Financed.

select distinct(payment_mode)
from motorcycle_sales_india;

update motorcycle_sales_india
set Payment_Mode = "Financed"
where Payment_Mode = "Loan"
or Payment_Mode = "EMI" ;

-- 5. Set engine_cc = 0 for electric bikes, as they do not have an engine.

select bike_category, engine_cc
from motorcycle_sales_india
where bike_category = "Electric" ;

update motorcycle_sales_india
set engine_cc = 0
where bike_category = "Electric" ;

-- 6. Replaced incorrect engine_cc values using bike model names (e.g., Bullet 350, Pulsar 220).

select Bike_Model, Engine_CC,
	REGEXP_SUBSTR(Bike_Model, '[0-9]+') as cc
from motorcycle_sales_india
group by Bike_Model, Engine_CC,REGEXP_SUBSTR(Bike_Model, '[0-9]+')
having cc > 125
and Engine_CC <> CC
and Engine_CC > 125;

UPDATE motorcycle_sales_india
SET engine_cc = REGEXP_SUBSTR(Bike_Model, '[0-9]+')
WHERE Engine_CC > 125
AND REGEXP_SUBSTR(Bike_Model, '[0-9]+') > 125
AND Engine_CC <> REGEXP_SUBSTR(Bike_Model, '[0-9]+');

```
**Key Insights**

-- 1.  Best-Selling Brands & Models

select  state, city, bike_brand, bike_model, Bike_Category,
	SUM(sale_quantity) as total_sales
from motorcycle_sales_india
group by state, city, bike_brand, bike_model, Bike_Category
order by total_sales desc ;

-- 2.  Region-Wise Bike Category Trends

select city, bike_category,
	sum(sale_quantity) as total_sales
from motorcycle_sales_india
group by bike_category, city
order by city, total_sales desc;

-- 3. Prefered payment mode

select payment_mode, city, COUNT(*) as total_transactions, 
    SUM(sale_quantity) as total_bikes_sold, 
    ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) over (), 2) as percentage_of_total
from motorcycle_sales_india
group by city, payment_mode
order by city;

-- 4. Dealer Performance Analysis

select dealer_name, state, city, SUM(sale_quantity) as total_bikes_sold
from motorcycle_sales_india
group by Dealer_Name, state, city
order by total_bikes_sold desc;




## H2
### H3
Bold	**bold text**
Italic	*italicized text*
Blockquote	> blockquote
Ordered List	1. First item
2. Second item
3. Third item
Unordered List	- First item
- Second item
- Third item
Code	`code`
Horizontal Rule	---
Link	[title](https://www.example.com)
Image	![alt text](image.jpg)
