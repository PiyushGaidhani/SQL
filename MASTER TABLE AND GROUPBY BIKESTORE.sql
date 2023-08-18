-- drop database
DROP DATABASE IF EXISTS BikeStores;

-- drop tables
DROP TABLE IF EXISTS sales.order_items;
DROP TABLE IF EXISTS sales.orders;
DROP TABLE IF EXISTS production.stocks;
DROP TABLE IF EXISTS production.products;
DROP TABLE IF EXISTS production.categories;
DROP TABLE IF EXISTS production.brands;
DROP TABLE IF EXISTS sales.customers;
DROP TABLE IF EXISTS sales.staffs;
DROP TABLE IF EXISTS sales.stores;

-- drop the schemas
DROP SCHEMA IF EXISTS sales;
DROP SCHEMA IF EXISTS production;

-- CREATE DATABASE
CREATE DATABASE BikeStores;
USE BikeStores;	

-- create schemas
CREATE SCHEMA production;
CREATE SCHEMA sales;

-- create tables
CREATE  TABLE production.categories (
	category_id INT AUTO_INCREMENT  PRIMARY KEY,
	category_name VARCHAR (255) NOT NULL
);
SELECT count(*) FROM    production.categories  ; -- 7

CREATE TABLE production.brands (
	brand_id INT AUTO_INCREMENT PRIMARY KEY,
	brand_name VARCHAR (255) NOT NULL
);
SELECT count(*) FROM  production.brands ; -- 9

CREATE TABLE production.products (
	product_id INT AUTO_INCREMENT PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	FOREIGN KEY (category_id) REFERENCES production.categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (brand_id) REFERENCES production.brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE
);

SELECT count(*) FROM   production.products  ; -- 321
SELECT * FROM   production.products ;

CREATE TABLE sales.customers (
	customer_id INT AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255) NOT NULL,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
	zip_code VARCHAR (5)
);
SELECT count(*) FROM   sales.customers  ; -- 1445

CREATE TABLE sales.stores (
	store_id INT AUTO_INCREMENT PRIMARY KEY,
	store_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255),
	street VARCHAR (255),
	city VARCHAR (255),
	state VARCHAR (10),
	zip_code VARCHAR (5)
);
SELECT count(*) FROM    sales.stores   ; -- 3

CREATE TABLE sales.staffs (
	staff_id INT AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (255) NOT NULL UNIQUE,
	phone VARCHAR (25),
	active tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (manager_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SELECT count(*) FROM    sales.staffs   ; -- 10

CREATE TABLE sales.orders (
	order_id INT AUTO_INCREMENT PRIMARY KEY,
	customer_id INT,
	order_status tinyint NOT NULL,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
	order_date DATE NOT NULL,
	required_date DATE NOT NULL,
	shipped_date DATE,
	store_id INT NOT NULL,
	staff_id INT NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES sales.customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (staff_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SELECT count(*) FROM    sales.orders  ; -- 1615

CREATE TABLE sales.order_items (
	order_id INT,
	item_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
	PRIMARY KEY (order_id, item_id),
	FOREIGN KEY (order_id) REFERENCES sales.orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);
SELECT count(*) FROM   sales.order_items ; -- 4722

CREATE TABLE production.stocks (
	store_id INT,
	product_id INT,
	quantity INT,
	PRIMARY KEY (store_id, product_id),
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);
SELECT count(*) FROM   production.stocks; -- 939

-- creation of master table 
-- use only left outer join for the time being
-- focus on necessary columns which you think is important from business side
-- get all the data

SELECT * FROM bikestores.pg_cust_sales_order_master;

USE BikeStores;

CREATE TABLE PG_CUST_SALES_ORDER_MASTER AS  
SELECT distinct o.customer_id,cu.first_name as customer_fn,cu.last_name as customer_ln,
str.store_name,str.store_id,oi.item_id,oi.product_id,p.product_name,br.brand_id,br.brand_name,oi.order_id, o.order_status,o.order_date,o.shipped_date,oi.quantity,oi.list_price
FROM sales.order_items AS oi
LEFT OUTER JOIN sales.orders as o on oi.order_id = o.order_id
left outer join sales.customers as cu on o.customer_id = cu.customer_id
left outer join production.stocks as s on oi.product_id = s.product_id
left outer join production.products as p on s.product_id = p.product_id
left outer join sales.staffs as sta on o.staff_id = sta.staff_id
left outer join production.brands as br on p.brand_id = br.brand_id 
left outer join production.categories as ca on p.category_id = ca.category_id
left outer join sales.stores as str on o.store_id = str.store_id;



       
       

-- latest order date 
SELECT CUSTOMER_ID, customer_fn AS CUS_FIRSTNAME , customer_ln AS CUS_LASTNAME,
 PRODUCT_NAME,MAX(ORDER_DATE) AS ORDERDATE FROM PG_CUST_SALES_ORDER_MASTER
 GROUP BY 1,2,3,4
 ORDER by 1,2,3
 LIMIT 3;


-- CHEAPEST AND COSTLIEST PRODUCTS 
SELECT  distinct CUSTOMER_ID, customer_fn , customer_ln, PRODUCT_NAME, PRODUCT_ID,
MIN(LIST_PRICE) AS CHEAPEST_PRODUCT ,MAX(LIST_PRICE) AS COSTLIEST_PRODUCT
FROM PG_CUST_SALES_ORDER_MASTER
GROUP BY 1,2,3,4,5
ORDER BY 1,2,3,4,5;

select count(*)from PG_CUST_SALES_ORDER_MASTER

-- TOTAL ORDERS PRODUCT WISE WHOSE ORDERS IS MORE THAN 200
SELECT product_name,COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS
FROM  PG_CUST_SALES_ORDER_MASTER
GROUP BY product_name
HAVING TOTAL_ORDERS > 150
ORDER BY TOTAL_ORDERS DESC;

-- STORE WISE ORDERS 
SELECT store_id,store_name,COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS
FROM  PG_CUST_SALES_ORDER_MASTER
GROUP BY 1,2
ORDER BY 3 DESC;

-- TO FIND TOTAL PRICE FOR EVERY CUSTOMER
CREATE TABLE PG_CUST_SALES_ORDER_MASTER_FINAL AS
SELECT *, (quantity * list_price) AS TOTAL_PRICE
FROM  PG_CUST_SALES_ORDER_MASTER;

-- can't we add total price in the current table using alter table.
ALTER TABLE PG_CUST_SALES_ORDER_MASTER
ADD COLUMN TOTAL_PRICE DECIMAL (10, 2) NOT NULL;

SELECT * FROM PG_CUST_SALES_ORDER_MASTER_FINAL;

SET SQL_SAFE_UPDATES = 0;

UPDATE PG_CUST_SALES_ORDER_MASTER
SET TOTAL_PRICE = quantity * list_price
WHERE TOTAL_PRICE = 0.00;

SELECT DISTINCT TOTAL_PRICE FROM PG_CUST_SALES_ORDER_MASTER
ORDER BY TOTAL_PRICE DESC;

-- LETS DECIDE THE TOTAL_PRICE BUCKET
-- LOW_PRICE 0 -5000
-- MEDIUM_PRICE 5000 - 15000
-- HIGH_PRICE > 15000

ALTER TABLE PG_CUST_SALES_ORDER_MASTER
ADD COLUMN PRICE_BUCKET VARCHAR (20) NOT NULL;

SELECT * FROM PG_CUST_SALES_ORDER_MASTER;

UPDATE PG_CUST_SALES_ORDER_MASTER
SET PRICE_BUCKET = 
   CASE 
       WHEN  TOTAL_PRICE <= 5000.00   THEN 'Low'
       WHEN  TOTAL_PRICE > 5000.00 AND TOTAL_PRICE <= 15000.00 THEN 'Medium'
       ELSE 'High' 
   END 
WHERE  PRICE_BUCKET = '';

-- READING NULL VALUES
SELECT * FROM PG_CUST_SALES_ORDER_MASTER WHERE PRICE_BUCKET IS NULL;

-- READING COMPLETELY EMPTY/BLANK ROWS
SELECT * FROM PG_CUST_SALES_ORDER_MASTER WHERE PRICE_BUCKET = '';

CREATE TABLE PG_CUST_SALES_ORDER_MASTER_FINAL_BUCKET_RANGE
SELECT * , 
   CASE 
       WHEN  TOTAL_PRICE <= 5000.00   THEN 'Low'
       WHEN  TOTAL_PRICE > 5000.00 AND TOTAL_PRICE <= 15000.00 THEN 'Medium'
	 -- TOTAL_PRICE BETWEEN 5000.00 and 15000
       ELSE 'High' 
   END AS PRICE_BUCKET
FROM PG_CUST_SALES_ORDER_MASTER_FINAL;
 SELECT * FROM PG_CUST_SALES_ORDER_MASTER_FINAL;

SELECT * FROM sales.staffs;

 SELECT CONCAT(E.FIRST_NAME,' ',E.LAST_NAME)AS EMPLOYEE_NAME,
 CONCAT(M.FIRST_NAME,' ',M.LAST_NAME)AS MANAGER_NAME
 FROM SALES.STAFFS E
 LEFT JOIN SALES.STAFFS M ON M.STAFF_ID = E.MANAGER_ID
 ORDER BY 1 ;
 
 SELECT distinct C1.CITY,
 concat(C1.FIRST_NAME,' ',C1.LAST_NAME) AS CUSTOMER_1,
 concat(C2.FIRST_NAME,' ',C2.LAST_NAME) AS CUSTOMER_2,
 FROM sales.customers C1 , SALES.CUSTOMER C2
 WHERE C1.CUSTOMER_ID > C2.CUSTOMER_ID ;
 ORDER BY 1,2,3; 
 use bikestores;
select * from bikestores;
select * from  sales.staff;
use schema sales;
use  sales;
select * from  sales.staff

select * from  sales.staffs;

select concat(e.first_name,' ',e.last_name) as employee_name,
concat(m.first_name,' ',m.last_name) as manager_name
from sales.staffs as e inner join sales.staff as m on staff_id=manager_id
order by 2;

SELECT * FROM SALES.CUSTOMERS;
SELECT  C1.FIRST_NAME+' '+C1.LAST_NAME AS CUST_NAME, 
C1.CITY,FROM SALES.CUSTOMERS AS C1, SALES.CUSTOMERS C2
WHERE C1.CITY = C2.CITY
ORDER BY 2;
SELECT C1.CITY, C1.FIRST_NAME+' '+C1.LAST_NAME AS CUST_NAME,
        C2.FIRST_NAME+' '+C2.LAST_NAME AS CUST_NAME2
        FROM SALES.CUSTOMERS AS C1, 
        SALES.CUSTOMERS C2
        WHERE C1.CITY = C2.CITY
        ORDER BY 2;
        
SELECT * FROM SALES.CUSTOMERS;

SELECT C1.CITY, C1.FIRST_NAME+' '+C1.LAST_NAME AS CUST_NAME,
        C2.FIRST_NAME+' '+C2.LAST_NAME AS CUST_NAME2
        FROM SALES.CUSTOMERS AS C1
        INNER JOIN SALES.CUSTOMERS AS C2 ON C1.CUSTOMER_ID > C2,CUSTOMER_ID AND C1.CITY=C2.CITY
        ORDER BY 1,2,3;
        
SELECT C1.CITY, CONCAT(C1.FIRST_NAME,' ',C1.LAST_NAME)AS CUST_NAME,
        CONCAT(C2.FIRST_NAME,' ',C2.LAST_NAME) AS CUST_NAME2FROM SALES.CUSTOMERS AS C1INNER 
        JOIN SALES.CUSTOMERS AS C2 ON C1.CUSTOMER_ID , C2.CUSTOMER_ID AND C1.CITY=C2.CITY
        ORDER BY 1,2,3;
        
SELECT C1.CITY, CONCAT(C1.FIRST_NAME,' ',C1.LAST_NAME)AS CUST_NAME, 
       CONCAT(C2.FIRST_NAME,' ',C2.LAST_NAME) AS CUST_NAME2
       FROM SALES.CUSTOMERS AS C1,SALES.CUSTOMERS C2
       WHERE C1.CITY = C2.CITY;
SELECT C1.CITY, CONCAT(C1.FIRST_NAME,' ',C1.LAST_NAME)AS CUST_NAME,
        CONCAT(C2.FIRST_NAME,' ',C2.LAST_NAME) AS CUST_NAME2
        FROM SALES.CUSTOMERS AS C1,SALES.CUSTOMERS C2
        WHERE C1.CITY = C2.CITY
        ORDER BY 1;
SELECT C1.CITY, CONCAT(C1.FIRST_NAME,' ',C1.LAST_NAME)AS CUST_NAME,
        CONCAT(C2.FIRST_NAME,' ',C2.LAST_NAME) AS CUST_NAME2
        FROM SALES.CUSTOMERS AS C1,SALES.CUSTOMERS C2
        WHERE C1.CITY = C2.CITY
        ORDER BY 1,2,3;
SELECT DISTINCT C1.CITY, CONCAT(C1.FIRST_NAME,' ',C1.LAST_NAME)AS CUST_NAME1,
        CONCAT(C2.FIRST_NAME,' ',C2.LAST_NAME) AS CUST_NAME2
        FROM SALES.CUSTOMERS AS C1,SALES.CUSTOMERS C2
        WHERE C1.CUSTOMER_ID>C2.CUSTOMER_ID AND C1.CITY = C2.CITY
        ORDER BY 1,2,3;

SELECT C1.CITY,concat(C1.FIRST_NAME,' ',C1.LAST_NAME)AS CUST_1,
concat(C2.FIRST_NAME,' ',C2.LAST_NAME)AS CUST_2
FROM SALES.CUSTOMERS AS C1 ,SALES.CUSTOMERS C2
WHERE C1.CUSTOMER_ID<>C2.CUSTOMER_ID AND C1.CITY=C2.CITY
ORDER BY C1.CITY; -- INSTEAD OF GREAtER THAN WE CAN ALSO USE USE <> NOT EQUAL TO AND WE WILL GET THE SAME OUTPUT 
				-- BUT THIS IS DUPLICATE OUT PUT SO WE USE GREATER THAN ONLY WHILE COMPARING 
                

SELECT CUSTOMER_ID, CONCAT(FIRST_NAME,' ',LAST_NAME) AS CUSTOMER, CITY
FROM SALES.CUSTOMERS
WHERE CITY = 'Albany';

SELECT CUSTOMER_ID, CONCAT(FIRST_NAME,' ',LAST_NAME) AS CUSTOMER, CITY
FROM SALES.CUSTOMERS
WHERE CITY = 'Albany'order by c;

SELECT CUSTOMER_ID, CONCAT(FIRST_NAME,' ',LAST_NAME) AS CUSTOMER, CITY
FROM SALES.CUSTOMERS
WHERE CITY = 'Albany'order by CUSTOMER;
