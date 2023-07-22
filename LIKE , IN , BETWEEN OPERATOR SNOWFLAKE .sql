--SELECT * FROM "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF10TCL"."ITEM"
---LIMIT 1000;

--DATA IN TABLES ARE ALWAYS CASE SENSITIVE BUT YOUR SQL QUERIES ARE CASE INSENSITIVE

CREATE WAREHOUSE DEMO_WAREHOUSE WITH WAREHOUSE_SIZE = 'MEDIUM' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 600 
AUTO_RESUME = TRUE 
COMMENT = 'DEMO WAREHOUSE FOR PRACTICING';

use warehouse DEMO_WAREHOUSE;
CREATE DATABASE DEMO_DATABASE;

USE DATABASE DEMO_DATABASE;

CREATE or replace table AJ_CONSUMER_COMPLAINTS

(    DATE_RECEIVED STRING,
     PRODUCT_NAME VARCHAR2(50),
     SUB_PRODUCT VARCHAR2(100),
     ISSUE VARCHAR2(100),
     SUB_ISSUE VARCHAR2(100),
     CONSUMER_COMPLAINT_NARRATIVE string,
     Company_Public_Response STRING,
     Company VARCHAR(100),
     State_Name CHAR(20),
     Zip_Code string,
     Tags VARCHAR(40),
     Consumer_Consent_Provided CHAR(40),
     Submitted_via STRING,
     Date_Sent_to_Company STRING,
     Company_Response_to_Consumer VARCHAR(40),
     Timely_Response CHAR(20),
     CONSUMER_DISPUTED CHAR(20),
     COMPLAINT_ID NUMBER(12,0) NOT NULL PRIMARY KEY
);

DESCRIBE TABLE AJ_CONSUMER_COMPLAINTS;

select * from AJ_CONSUMER_COMPLAINTS LIMIT 100; --TOP WORKS IN MYSQL

SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS;


--SYNTAX : SELECT DISTINCT COL_NAME FROM TABLE_NAME
SELECT DISTINCT PRODUCT_NAME FROM AJ_CONSUMER_COMPLAINTS;
SELECT DISTINCT SUB_PRODUCT FROM AJ_CONSUMER_COMPLAINTS;

SELECT DISTINCT ISSUE FROM AJ_CONSUMER_COMPLAINTS;

select distinct COMPANY from AJ_CONSUMER_COMPLAINTS;
SELECT DISTINCT SUBMITTED_VIA  from AJ_CONSUMER_COMPLAINTS;

----------LIKE KEYWORD ----=HIGHLY USED IN SQL --------------------
-- % represents zero,one,or multiple characters
-- _ underscore represnts one,singe chracter
/*

a% - any values that starts with a
%a - any values that ends with a
%word% - any values that has word in any position

_a% - any values that has a in teh second position
a_% - any values that starts with "a" and are atleast 2 chracters in length
a__% - any values that starts with "a" and are atleast 3 chracters in length
a%r - any values that starts with a and ends with r

ab%cd%de%f - any values that starts with ab followed by any characters and then cd and then followed by any characters 
and then de followed by any charcaters and ending with f

*/
---a% - any values that starts with a
SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME LIKE 'Bank%'; --- bank at the start followed by any character % AT THE END MEANS Bank followed by any sequence of character

--%word% - any values that has word in any position
SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME LIKE '%account%'; --anywhere word 'account' appearing in the data 
SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME LIKE '%Credit%'; --anywhere credit

--%a - any values that ends with a
SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME LIKE '%account'; -- AT THE END I NEED ACCOUNT as product name 
SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME LIKE '%loan';  -- at the end i need loan keyword to be there
SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME LIKE '%loan';

--_a% - any values that has a in the second position
select * from AJ_CONSUMER_COMPLAINTS where company like '_a%';

--a_% - any values that starts with "a" and are atleast 2 chracters in length
select * from AJ_CONSUMER_COMPLAINTS where SUBMITTED_VIA like 'F_%'; 

--a__% - any values that starts with "a" and are atleast 3 chracters in length
SELECT * FROM AJ_CONSUMER_COMPLAINTS WHERE CONSUMER_COMPLAINT_NARRATIVE LIKE 'a__%';


--a%r - any values that starts with a and ends with r
SELECT * FROM AJ_CONSUMER_COMPLAINTS WHERE SUB_PRODUCT LIKE 'C%t';
select * from AJ_CONSUMER_COMPLAINTS where ISSUE like 'M%e';


create or replace table like_ex(subject varchar(20));
insert into like_ex values
    ('John  Dddoe'),
    ('Joe   Doe'),
    ('John_down'),
    ('Joe down'),
    ('Elaine'),
    (''),    -- empty string
    (null);

SELECT * FROM like_ex;
select subject from like_ex where subject like '%Jo%oe%' ;
--order by subject;

------------------------------------------------------------IN KEYWORD-----------------------------------
SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS;

SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME IN ('Consumer Loan','Mortgage','Debt collection');

SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME = 'Consumer Loan' OR 
PRODUCT_NAME = 'Mortage' OR PRODUCT_NAME = 'Debt collection';


SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS 
WHERE COMPANY IN ('Wells Fargo & Company','Citibank','
Bank of America');

SELECT DISTINCT * FROM AJ_CONSUMER_COMPLAINTS WHERE DATE_RECEIVED BETWEEN '2013-07-29' AND '2013-07-31'; 
--or BETWEEN '29-07-2013' AND '31-07-2013';
SELECT TO_DATE(DATE_RECEIVED , 'DD-MM-YYYY') FROM AJ_CONSUMER_COMPLAINTS AS DATE_RC;
--
SELECT * FROM AJ_CONSUMER_COMPLAINTS
WHERE DATE_RC BETWEEN '29-07-2013' AND '31-07-2013' ;


DESCRIBE TABLE AJ_CONSUMER_COMPLAINTS;















