CREATE TABLE beverage(
	Order_ID text,
	Customer_ID text,
	Customer_Type text,
	Product text,
	Category text,
	Unit_Price real,
	Quantity integer,
	Discount real,
	Total_Price real,
	Region text,
	Order_Date date
)

SELECT *
FROM beverage
LIMIT 20