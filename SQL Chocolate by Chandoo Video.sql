show tables; #to show all tables
desc sales; #to describe the 'sales' table, what columns and data types there are
#semi-colon is added at the end of the query to indicate the end of the query. Otherwise there is an error sign in the next query.
SELECT * FROM sales; #'*' shows all data 
SELECT * FROM products;
SELECT * FROM people;

SELECT SaleDate, Amount, Customers FROM sales;

SELECT SaleDate, Amount, GeoID FROM sales;

SELECT SaleDate, Amount, Boxes, Amount/Boxes AS 'Amount per Box' FROM sales;

#Conditions
SELECT * 
FROM sales
WHERE amount > 10000 #condition
ORDER BY amount desc; #order by descending order, by default is ascending

SELECT * 
FROM sales
WHERE GeoID='g1' #condition
ORDER BY PID, Amount desc; #order by

SELECT * 
FROM sales
WHERE amount > 10000 and SaleDate >= '2022-01-01'; #condition to select sales in 2022 only; yy-mm-dd

SELECT SaleDate, Amount
FROM sales
WHERE amount >10000 and year(SaleDate) = 2022 #conditions for selecting sales from 2022 onwards, year is a built-in function
ORDER BY amount desc;

#sales between 0 to 50
SELECT *
FROM sales
WHERE boxes > 0 and boxes <= 50;

SELECT *
FROM sales
WHERE boxes between 0 and 50 #this includes 0 boxes
ORDER BY boxes;

#shipments happened on Fridays
SELECT SaleDate, Amount, Boxes, weekday(SaleDate) AS 'Day of week'
FROM sales
WHERE weekday(SaleDate) = 4; #4 is Friday?

# using other tables
SELECT *
FROM people;

SELECT *
FROM people
WHERE team = 'Delish' or team = 'Jucies';

# in clause that offers more flexible options
SELECT *
FROM people
WHERE team in ('Delish', 'Jucies');

# pattern matching using 'like' operator
SELECT *
FROM people
WHERE salesperson like 'B%'; #'%' = anything after 'B' = salesperson name starts with 'B'

SELECT *
FROM people
WHERE salesperson like '%B%'; #'%' anything before or after 'B' = anything that has 'b'

# using 'case' operator
SELECT SaleDate, Amount,
		case 	when amount <1000 then 'Under 1k'
				when amount <5000 then 'Under 5k'
				when amount <10000 then 'Under 10k'
			else '10k or more'
		end AS 'Amount category'
FROM sales;

#JOINS - Understand the tables to build join queries
#Sales with person's name
SELECT s.SaleDate, s.amount, p.salesperson, s.SPID, p.SPID
FROM sales AS s
JOIN people AS p on p.SPID = s.SPID; #'people' from people dataset

##Left Join = the query will keep all table data in the LEFT table (Sales) and take only specified column in the RIGHT column (SPID)

SELECT s.SaleDate, s.Amount, s.PID, pr.product
FROM sales AS s
LEFT JOIN products AS pr on pr.pid = s.pid;

#Joining 'sales', 'people', and 'product' tables
SELECT s.SaleDate, s.amount, p.salesperson, pr.product, p.team
FROM sales AS s
JOIN people AS p on p.SPID = s.SPID
LEFT JOIN products AS pr on pr.pid = s.pid;

#Add Condition to Joins - to add criteria
SELECT s.SaleDate, s.amount, p.salesperson, pr.product, p.team
FROM sales AS s
JOIN people AS p on p.SPID = s.SPID
LEFT JOIN products AS pr on pr.pid = s.pid
WHERE s.amount < 500
and p.Team = 'Delish';

SELECT s.SaleDate, s.amount, p.salesperson, pr.product, p.team
FROM sales AS s
JOIN people AS p on p.SPID = s.SPID
LEFT JOIN products AS pr on pr.pid = s.pid
WHERE s.amount < 500
and p.Team = ''; #person with no team

#Using Join to Join Geo
SELECT s.SaleDate, s.amount, p.salesperson, pr.product, p.team, g.geoid
FROM sales AS s
JOIN people AS p on p.SPID = s.SPID
LEFT JOIN products AS pr on pr.pid = s.pid
JOIN geo AS g on g.geoid = s.geoid
WHERE s.amount < 500
and p.Team = '' #person with no team
and g.geo in ('New Zealand', 'India') #location
ORDER BY saledate;

# GROUP BY - gives a pivot report
SELECT GeoID, sum(amount), avg(amount), sum(boxes) #the total amount, average amount, and sum boxes by GeoID
FROM sales
GROUP BY GeoID;

SELECT g.geo, sum(amount), avg(amount), sum(boxes) #the total amount by GeoID
FROM sales S
JOIN geo AS g on g.geoID = s.geoID
GROUP BY g.geo;

#from people table on team and category
SELECT pr.category, p.team, sum(boxes), sum(amount)
FROM sales AS s
JOIN people AS p on p.spid = s.spid
JOIN products AS pr on pr.pid = s.pid
WHERE p.team <> '' #only showing people with team (exclude ppl with no team) - can omit this condition
GROUP BY pr.category, p.team
ORDER BY pr.category, p.team;

#total amount by top 10 products
SELECT pr.product, sum(s.amount) AS 'Total Amount'
FROM sales AS s
JOIN products AS pr on pr.pid = s.pid
GROUP BY pr.product
ORDER BY 'Total Amount' desc
LIMIT 10;

#Intermediate Problems
#1) Print details of shipments (sales) where amounts are >2,000 and boxes are <100
SELECT *
FROM sales
WHERE Amount > 2000 and boxes <100;

#2) How many shipments (sales) each of the sales persons had in the month of January 2022 Solution: just count(*) the number of orders made by a salesperson i.e., count each 'salesperson' "quantity"
SELECT p.salesperson, count(*) AS 'Shipment Count'
FROM sales AS s
JOIN people AS p on p.spid = s.spid
WHERE SaleDate between '2022-01-01' and '2022-01-31'
GROUP BY p.salesperson;

#3) Which product sells more boxes? Milk bars or eclairs?
SELECT pr.product, sum(boxes) AS 'Total Boxes' #if use count(boxes), it gives the total sales count (no. of rows) instead of total (sum) boxes?
FROM sales AS s
JOIN products AS pr on pr.pid = s.pid
WHERE pr.product in ('Milk Bars', 'Eclairs')
GROUP BY pr.product;

#4) Which product sold more boxes in the first 7 days of February 2022? Milk Bars or Eclairs?
SELECT pr.product, sum(boxes) AS 'Total Boxes' #if s.saledate was added, the results will show two 'milk bars' entries on two different dates. Therefore, remove s.saledate
FROM sales AS s
JOIN products AS pr on pr.pid = s.pid
WHERE pr.product in ('Milk Bars', 'Eclairs') and s.SaleDate between '2022-02-01' and '2022-02-07'
GROUP BY pr.product;

#5) Which shipments had under 100 customers and under 100 boxes? Did any of them occur on Wednesday?
SELECT *
FROM sales
WHERE customers < 100 and boxes <100;

SELECT *, 
		case 	when weekday(saledate) = 2 then 'Wednesday Shipment'
			else '' #not double quotation but 2x single quote ' '
		end AS 'W Shipment'
FROM sales
WHERE customers <100 and boxes <100;

#Hard Problems
#1) What are the names of salespersons who had at least one shipment (sale) in the first 7 days of January 2022?
SELECT p.salesperson, s.amount #this shows the amount of sales per each salesperson
FROM sales AS s
JOIN people AS p on p.spid = s.spid
WHERE s.saledate between '2022-01-01' and '2022-01-07' and amount > 1; 

SELECT distinct p.salesperson  #this shows each salesperson who had sales in the first 7 days of January 2022 (since salesperson without sales would not be included in the list?).
FROM sales AS s
JOIN people AS p on p.spid = s.spid
WHERE s.saledate between '2022-01-01' and '2022-01-07';

#2) Which salespersons did not make any shipments in the first 7 days of January 2022?
SELECT p.salesperson
FROM people AS p
WHERE p.spid not in #subquery
(select distinct s.spid from sales as S where s.saledate between '2022-01-01' and '2022-01-07');

#3) How many times we shipped more than 1000 boxes in each month?
SELECT year(saledate) AS 'Year', month(saledate) AS 'Month', count(*) AS 'No. of Times more than 1k boxes shipped'
FROM sales
WHERE boxes >1000
GROUP BY year(saledate), month(saledate)
ORDER BY year(saledate), month(saledate);

#4) Did we ship at least one box of 'After Nines' to 'New Zealand' on all the months?
set @product_name = 'After Nines';
set @country_name = 'New Zealand';
SELECT year(saledate) AS 'Year', month(saledate) AS 'Month',
IF(sum(boxes)>1, 'Yes','No') AS 'Status'
FROM sales AS s
JOIN products AS pr on pr.pid = s.pid
JOIN geo AS g on g.geoID=S.geoid
WHERE pr.product = @product_name and g.geo = @country_name
GROUP BY year(saledate), month(saledate)
ORDER BY year(saledate), month(saledate);


#5) India or Australia? Who buys more chocolate boxes on a monthly basis?
SELECT year(saledate) AS 'Year', month(saledate) AS 'Month',
sum(CASE WHEN g.geo='India' = 1 THEN boxes ELSE 0 END) AS 'India Boxes',
sum(CASE WHEN g.geo='Australia' = 1 THEN boxes ELSE 0 END) AS 'Australia Boxes'
FROM sales AS s
JOIN geo AS g on g.geoid = s.geoid
GROUP BY year(saledate), month(saledate)
ORDER BY year(saledate), month(saledate);