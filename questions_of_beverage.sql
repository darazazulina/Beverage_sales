SELECT *
FROM beverage
LIMIT 10;




-- Наиболее покупаемые продукты
SELECT Product, COUNT(*) AS Num_by_products
FROM beverage
GROUP BY Product
ORDER BY num_by_products DESC
LIMIT 10;

-- Количество покупок по категориям
SELECT Category, COUNT(*) AS Num_by_categories
FROM beverage
GROUP BY Category
ORDER BY num_by_categories DESC;

-- Наибольшее количество заказов по регионам
SELECT Region, COUNT(DISTINCT Order_ID) AS Num_by_regions
FROM beverage
GROUP BY Region
ORDER BY num_by_regions DESC
LIMIT 5;

-- Количество заказов по типам клиентов
SELECT Customer_Type, COUNT(DISTINCT Order_ID) AS Num_of_customer_type
FROM beverage
GROUP BY Customer_Type;





-- Затраты и количество купленных товаров по регионам
SELECT Region, COUNT(Quantity) AS Quantity, ROUND(SUM(Total_Price::numeric), 2) AS Total_Price 
FROM beverage
GROUP BY Region
ORDER BY Total_Price DESC;

-- Затраты и количество купленных товаров по категориям
SELECT Category, COUNT(Quantity) AS Quantity, ROUND(SUM(Total_Price::numeric), 2) AS Total_Price 
FROM beverage
GROUP BY Category
ORDER BY Total_Price DESC;

-- Продажи по дате
SELECT Order_Date, ROUND(SUM(Total_Price::numeric), 2) AS Sales
FROM beverage
GROUP BY Order_Date
ORDER BY Order_Date;

-- Продажи по месяцам
SELECT DATE_PART('year', Order_Date) AS date_year, 
	   DATE_PART('month', Order_Date) AS date_month, 
	   ROUND(SUM(Total_Price::numeric), 2) AS Sales
FROM beverage
GROUP BY date_month, date_year
ORDER BY date_year, date_month;

-- Прибыль по годам
SELECT DATE_PART('year', Order_Date) AS Sales_by_Year, ROUND(SUM(Total_Price::numeric), 2) AS Sales
FROM beverage
GROUP BY Sales_by_Year
ORDER BY Sales_by_Year
LIMIT 10;





-- Метрические показатели
-- DAU: число покупателей в день (за последние полгода)
WITH d AS(
	SELECT 
		Order_Date, 
		COUNT(DISTINCT Customer_ID) AS cust_day
	FROM beverage
	WHERE Order_Date >= '2023-07-01'
	GROUP BY Order_Date
)

SELECT ROUND(AVG(cust_day)::numeric, 2) AS DAU
FROM d;

-- WAU: число покупателей в неделю (за последние полгода)
WITH w AS(
	SELECT 
		DATE_PART('year', Order_Date) AS year_num,
		DATE_PART('week', Order_Date) AS week_num, 
		COUNT(DISTINCT Customer_ID) AS cust_week
	FROM beverage
	WHERE Order_Date >= '2023-07-01'
	GROUP BY year_num, week_num
)

SELECT ROUND(AVG(cust_week)::numeric, 2) AS WAU
FROM w;

-- MAU: число покупателей в месяц (за последние полгода)
WITH m AS(
	SELECT 
		DATE_PART('year', Order_Date) AS year_num,
		DATE_PART('month', Order_Date) AS month_num, 
		COUNT(DISTINCT Customer_ID) AS cust_month
	FROM beverage
	WHERE Order_Date >= '2023-07-01'
	GROUP BY year_num, month_num
)

SELECT ROUND(AVG(cust_month)::numeric, 2) AS MAU
FROM m;

-- Sticky_factor: степень лояльности и частота взаимодействия клиентов (за последние полгода)
WITH d AS(
	SELECT 
		Order_Date, 
		COUNT(DISTINCT Customer_ID) AS cust_day
	FROM beverage
	WHERE Order_Date >= '2023-07-01'
	GROUP BY Order_Date
),
m AS(
	SELECT 
		DATE_PART('year', Order_Date) AS year_num,
		DATE_PART('month', Order_Date) AS month_num, 
		COUNT(DISTINCT Customer_ID) AS cust_month
	FROM beverage
	WHERE Order_Date >= '2023-07-01'
	GROUP BY year_num, month_num
)

SELECT ROUND(AVG(cust_day) / AVG(cust_month) * 100, 2) AS sticky_factor
FROM d, m;


-- Lifetime
WITH f as( -- День первой покупки
	SELECT DISTINCT Customer_ID,
		Order_Date,
		FIRST_VALUE(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date) AS First_Order
	FROM beverage
	WHERE Order_Date >= '2023-07-01' 
	ORDER BY Order_Date
),
df as ( -- Разница между датой текущей покупки и датой первой покупки
	SELECT
	    Order_Date - First_Order AS diff,
	    COUNT(DISTINCT Customer_ID) AS count_cust
	FROM f
	GROUP BY diff
),
ret as( -- Доля оставшихся клиентов
	SELECT 
		diff, 
	    ROUND(count_cust * 1.0 / FIRST_VALUE(count_cust) OVER (ORDER BY diff), 4) AS retention
	FROM df
)

SELECT 
    SUM(retention) AS lifetime
FROM ret;





