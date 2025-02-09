SELECT * FROM project_1.motorcycle_sales_india;


-- CLEANING THE DATASET

-- 1. Date type correction of Sale_date and Engine_cc column

alter table motorcycle_sales_india
modify sale_date date ;

alter table motorcycle_sales_india
modify Engine_CC int ;

-- 2. The data was relatively clean and did not contain any null values or blank spaces that needed to be filled or trimmed.




-- STANDARDIZING THE DATASET

-- 1. Rearrange columns Dealer_Name, State, and City to appear at the front for better readability 

alter table motorcycle_sales_india
modify column Dealer_Name varchar(225) after Sale_ID;

alter table motorcycle_sales_india
modify column State varchar(225) after Dealer_Name;

alter table motorcycle_sales_india
modify column City varchar(225) after State;

-- 2. Removed the "cc" from the engine_cc column after the numeric values, to better categorize the data and identify patterns more effectively.

select bike_model, engine_cc, left(engine_cc,3) AS cc
from motorcycle_sales_india;

update motorcycle_sales_india
set Engine_CC = left(engine_cc,3);

-- 3. In the payment_mode column, "Loan" and "EMI" coulmn are merged under a new category named "Financed" since both represent the same type of payment method.

select distinct(payment_mode)
from motorcycle_sales_india;

update motorcycle_sales_india
set Payment_Mode = "Financed"
where Payment_Mode = "Loan"
or Payment_Mode = "EMI" ;

-- 4. In the bike_category, some electric vehicles had numerical values in the engine_cc column. 
--    Since electric bikes do not have an engine, engine_cc values are replaced with 0.

select bike_category, engine_cc
from motorcycle_sales_india
where bike_category = "Electric" ;

update motorcycle_sales_india
set engine_cc = 0
where bike_category = "Electric" ;

-- 5. Engine_CC values were incorrect due to mismatches with model names (e.g., RR 310, RC 200, Bullet 350, Pulsar 220),
--    Extracted correct CC from Bike_Model and updated Engine_CC for bikes above 125cc 

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




-- INSIGHTS AND TRENDS FROM DATASET

-- 1. Best-Selling Motorcycle Brands & Models (Increacse stock of best-selling model, offer better deal on slow-moving model to reduce inventory)

select  state, city, bike_brand, bike_model, Bike_Category,
	SUM(sale_quantity) as total_sales
from motorcycle_sales_india
group by state, city, bike_brand, bike_model, Bike_Category
order by total_sales desc ;

-- 2. To find which category is performing well in which region to promote target based marketing, and bundle less selling models with accessories to increase profit

select city, bike_category,
	sum(sale_quantity) as total_sales
from motorcycle_sales_india
group by bike_category, city
order by city, total_sales desc;

-- 3. Prefered payment mode (If EMI are popular, so partner with banks to offer less interest EMI plans, can see which tier city prefer what type of payment method)

select payment_mode, city, COUNT(*) as total_transactions, 
    SUM(sale_quantity) as total_bikes_sold, 
    ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) over (), 2) as percentage_of_total
from motorcycle_sales_india
group by city, payment_mode
order by city;

-- 4. Dealer Performance Analysis(Reward high performing dealer, train low performing dealer)

select dealer_name, state, city, SUM(sale_quantity) as total_bikes_sold
from motorcycle_sales_india
group by Dealer_Name, state, city
order by total_bikes_sold desc;


