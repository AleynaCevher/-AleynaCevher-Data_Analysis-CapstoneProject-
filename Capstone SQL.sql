
SELECT*FROM customers;--customer_id,companyname,contactname,contacttitle,address,city,region,postalcode,country,phone,fax
SELECT*FROM employees;--employeeid,firstname,lastname,title,titleofcourtesy,birthdate,hiredate,address,city,
                      --region,postalcode,country,homephone,extension,photo,notes
SELECT*FROM categories;--categoryid,categoryname,description,picture
SELECT*FROM customercustomerdemo;
SELECT*FROM products;--productid,productname,supplierid,categoryid,quantityperunit,unitprice,unitinstock,unitonorder,reorderlevel,
                    --discontinued
SELECT*FROM orders; --orderid,customerid,employeeid,orderdate,requireddate,shippeddate,shipvia,freight,shipname,shipaddress,shipcity
					--shipregion,shippostalcode,shipcountry
SELECT*FROM order_details; --orderid,productid,unitprice,quantity,discount
SELECT*FROM employeeterritories; --employeeid,territoryid
SELECT*FROM region; --region_id,regiondescription

---CUSTOMER ANALYSIS

--1- Find the total number of customers.
SELECT COUNT(customer_id) as customer_count FROM customers;

--2- Find the total number of orders placed by customers.
SELECT customer_id,COUNT(order_id) as totalorders
FROM orders
GROUP BY customer_id
ORDER BY totalorders DESC;


--3- Find the total spending of customers.
SELECT customer_id,o.order_id,ROUND(SUM(unit_price*quantity)) AS TotalSpent FROM orders o,order_details od 
WHERE o.order_id=od.order_id 
GROUP BY 1,2 ORDER BY 3 DESC;

--4- Calculate which products each customer has purchased and the total amount they paid.
*customers,orders,orderdetails,product
SELECT c.customer_id,
ROUND(SUM(od.unit_price*od.quantity)) as totalprice,
p.product_name
FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id 
LEFT JOIN order_details od ON od.order_id=o.order_id
LEFT JOIN products p ON p.product_id=od.product_id 
GROUP BY 1,3 ORDER BY 2 DESC;

--5-Find the total number of products ordered by customers each year.

SELECT EXTRACT(YEAR FROM o.order_date) AS order_year,SUM(od.quantity) AS total_quantity
FROM orders o LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY 1 ORDER BY 1;


--6- List the number of orders placed by customers and their spending each year, and identify the countries to which the products were shipped.
**sıralama:orders orderdetails product 
SELECT customer_id,COUNT(customer_id), EXTRACT(YEAR FROM o.order_date)::date,ship_city,product_name FROM orders o 
LEFT JOIN order_details od ON o.order_id=od.order_id 
LEFT JOIN products p ON p.product_id=od.product_id 
GROUP BY 1,3,4,5 ORDER BY 3;

SELECT 
    TO_CHAR(order_date, 'YYYY') AS order_year,
    SUM(od.quantity) AS total_quantity
FROM 
    orders o
LEFT JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    TO_CHAR(order_date, 'YYYY')
ORDER BY 
    order_year;


--7- Segment customers based on their total spending.
SELECT customer_id, totalspent,
       CASE WHEN totalspent < 1000 THEN 'Low'
            WHEN totalspent BETWEEN 1000 AND 10000 THEN 'Medium'
            WHEN totalspent > 10000 THEN 'High'
       END as segment
FROM (SELECT c.customer_id, ROUND(SUM(od.unit_price * od.quantity)) as totalspent
      FROM customers c
      LEFT JOIN orders o ON c.customer_id = o.customer_id
      LEFT JOIN order_details od ON o.order_id = od.order_id
      GROUP BY c.customer_id) as customerspent 
	  ORDER BY totalspent DESC;

--8- List the top 10 customers who spend the most and the employees who served them.
SELECT c.customer_id,ROUND(SUM((unit_price*quantity))) totalspent,CONCAT(e.first_name,' ',e.last_name) emp_name 
FROM orders o LEFT JOIN order_details od ON o.order_id=od.order_id 
LEFT JOIN customers c ON c.customer_id=o.customer_id
LEFT JOIN employees e ON e.employee_id=o.employee_id 
GROUP BY 1,3 ORDER BY 2 DESC LIMIT 10;

--9- List each customer’s total spending by product category.
*category,products,orderdetails,orders

SELECT o.customer_id,ROUND(SUM((od.unit_price*od.quantity))) totalspent,c.category_name 
FROM categories c LEFT JOIN products p ON c.category_id=p.category_id 
LEFT JOIN order_details od ON od.product_id=p.product_id 
LEFT JOIN orders o ON o.order_id=od.order_id 
GROUP BY 1,3 ORDER BY 2 DESC;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

SELECT*FROM customers;--customer_id,companyname,contactname,contacttitle,address,city,region,postalcode,country,phone,fax
SELECT*FROM employees;--employeeid,firstname,lastname,title,titleofcourtesy,birthdate,hiredate,address,city,
                      --region,postalcode,country,homephone,extension,photo,notes
SELECT*FROM categories;--categoryid,categoryname,description,picture
SELECT*FROM customercustomerdemo;
SELECT*FROM products;--productid,productname,supplierid,categoryid,quantityperunit,unitprice,unitinstock,unitonorder,reorderlevel,
                    --discontinued
SELECT*FROM orders; --orderid,customerid,employeeid,orderdate,requireddate,shippeddate,shipvia,freight,shipname,shipaddress,shipcity
					--shipregion,shippostalcode,shipcountry
SELECT*FROM order_details; --orderid,productid,unitprice,quantity,discount
SELECT*FROM employeeterritories; --employeeid,territoryid
SELECT*FROM region; --region_id,regiondescription


2--ORDER ANALYSIS

--1- Find the total number of orders.
SELECT COUNT(*) as totalorders FROM orders;

--2- Retrieve the number of orders placed by each customer along with their respective companies.

SELECT COUNT(order_id) ordercount,c.customer_id,company_name FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
GROUP BY 2,3 ORDER BY 1 DESC;

--3- Find the sales quantity for each product and retrieve the relevant categories.
**products,orderdetails,categories

SELECT p.product_id,SUM(od.quantity) as quantitysold, product_name,category_name FROM products p 
LEFT JOIN order_details od ON p.product_id=od.product_id 
LEFT JOIN categories c ON c.category_id=p.category_id 
GROUP BY 1,3,4 ORDER BY 2 DESC;

--4-Retrieve the average order and discount amount per customer.

SELECT customer_id,ROUND(AVG(o.order_id)) avg_order,AVG(od.discount) avg_discount 
FROM orders o LEFT JOIN order_details od ON o.order_id=od.order_id
GROUP BY 1 ORDER BY 2;

--5- Get the top 10 best-selling products and the categories they belong to.
SELECT product_name,SUM(od.quantity) totalsold FROM products p 
LEFT JOIN order_details od ON p.product_id=od.product_id
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

--6- Get the 10 least-selling products and the categories they belong to.
SELECT product_name,SUM(od.quantity) totalsold FROM products p 
LEFT JOIN order_details od ON p.product_id=od.product_id
GROUP BY 1 ORDER BY 2 ASC LIMIT 10;

--7- Retrieve the average prices and total discount amounts by category.
**products,categories,orderdetails

SELECT c.category_id,category_name,ROUND(AVG(od.unit_price*quantity)) avg_price,SUM(od.discount) total_discount 
FROM categories c LEFT JOIN products p ON c.category_id=p.category_id 
LEFT JOIN order_details od ON p.product_id=od.product_id 
GROUP BY 1,2 ORDER BY 1;

--8- Segment stock levels and ordered products based on the reorder level.
SELECT product_id, product_name, unit_in_stock, unit_on_order, reorder_level,
    CASE WHEN (unit_in_stock + unit_on_order) < reorder_level THEN 'Hemen Sipariş Ver'
         WHEN (unit_in_stock + unit_on_order) = reorder_level THEN 'Sipariş Düşünülebilir'
         WHEN (unit_in_stock + unit_on_order) > reorder_level THEN 'İhtiyaç Yok'
         ELSE ' '
    	END AS stokkontrol FROM products;
		
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
SELECT*FROM customers;--customer_id,companyname,contactname,contacttitle,address,city,region,postalcode,country,phone,fax
SELECT*FROM employees;--employeeid,firstname,lastname,title,titleofcourtesy,birthdate,hiredate,address,city,
                      --region,postalcode,country,homephone,extension,photo,notes
SELECT*FROM categories;--*categoryid,categoryname,description,picture
SELECT*FROM customercustomerdemo;
SELECT*FROM products;--productid,productname,supplierid,*categoryid,quantityperunit,unitprice,unitinstock,unitonorder,reorderlevel,
                    --discontinued
SELECT*FROM orders; --orderid,customerid,employeeid,orderdate,requireddate,shippeddate,shipvia,freight,shipname,shipaddress,shipcity
					--shipregion,shippostalcode,shipcountry
SELECT*FROM order_details; --orderid,productid,unitprice,quantity,discount
SELECT*FROM employeeterritories; --employeeid,territoryid
SELECT*FROM region; --region_id,regiondescription


3--EMPLOYEE ANALYSIS

--1- Find the total number of employees.
SELECT COUNT(*) as employeecount FROM employees;

--2- Find the total number of orders processed by each employee and the total value of those orders.
SELECT e.employee_id,CONCAT(e.first_name,' ',e.last_name) employee_names,COUNT(o.order_id) ordercount,
ROUND(SUM(od.unit_price*od.quantity)) totalprice
FROM employees e LEFT JOIN orders o ON e.employee_id=o.employee_id
LEFT JOIN order_details od ON od.order_id=o.order_id
GROUP BY 1 ORDER BY 1;

--3-Find the average discount rate for the orders processed by each employee.

SELECT e.employee_id,AVG(od.discount) avg_discount,CONCAT(e.first_name,' ',e.last_name) employee_names
FROM employees e LEFT JOIN orders o ON e.employee_id=o.employee_id
LEFT JOIN order_details od ON od.order_id=o.order_id
GROUP BY 1,3 ORDER BY 1

--4- Determine which products each employee processed the most orders for.

WITH EmployeeProductOrders AS (
    SELECT e.employee_id,CONCAT(e.first_name, ' ', e.last_name) AS employee_names,p.product_name,COUNT(o.order_id) AS ordercount
    FROM employees e
    LEFT JOIN orders o ON e.employee_id = o.employee_id
    LEFT JOIN order_details od ON o.order_id = od.order_id
    LEFT JOIN products p ON p.product_id = od.product_id
    GROUP BY e.employee_id, e.first_name, e.last_name, p.product_name
),
EmployeeMaxProduct AS (
    SELECT employee_id,employee_names,product_name,ordercount,
    RANK() OVER (PARTITION BY employee_id ORDER BY ordercount DESC) AS rank
    FROM EmployeeProductOrders
)
SELECT employee_id,employee_names,product_name,ordercount
FROM EmployeeMaxProduct
WHERE rank = 1 ORDER BY employee_id;

--5-Find the top 5 employees with the highest sales.

SELECT e.employee_id,CONCAT(e.first_name,' ',e.last_name) employee_names,ROUND(SUM(od.unit_price*od.quantity)) totalprice
FROM employees e LEFT JOIN orders o ON e.employee_id=o.employee_id 
LEFT JOIN order_details od ON o.order_id=od.order_id
GROUP BY 1 ORDER BY 3 DESC LIMIT 5;

--6-Show the sales performance of each employee by the product categories they sold.
**employees,orders,orderdetails,products,categories

SELECT e.employee_id,CONCAT(e.first_name,' ',e.last_name) employee_names,COUNT(o.order_id) ordercount,c.category_name 
FROM employees e LEFT JOIN orders o ON e.employee_id=o.employee_id
LEFT JOIN order_details od ON o.order_id=od.order_id
LEFT JOIN products p ON p.product_id=od.product_id 
LEFT JOIN categories c ON c.category_id=p.category_id
GROUP BY 1,4 ORDER BY 1;


--7- List the employees who received the most orders from each customer.

SELECT customer_id,employee_name,MAX(order_count) as order_count
FROM (SELECT o.customer_id,CONCAT(e.first_name, ' ', e.last_name) as employee_name,
       COUNT(o.order_id) as order_count FROM orders o LEFT JOIN employees e ON e.employee_id = o.employee_id 
	  GROUP BY o.customer_id, employee_name) as customer_orders
GROUP BY 1,2 ORDER BY 3 DESC;

--8- Find out which country employees sent the most orders to.

WITH EmployeeOrders AS (
    SELECT e.employee_id,CONCAT(e.first_name, ' ', e.last_name) AS employee_name,o.ship_country,
	COUNT(o.order_id) AS ordercount
    FROM employees e
    LEFT JOIN orders o ON e.employee_id = o.employee_id
    GROUP BY 1,2,3
),
RankedEmployeeOrders AS (
    SELECT employee_id,employee_name,ship_country,ordercount,
    RANK() OVER (PARTITION BY employee_id ORDER BY ordercount DESC) AS rank
    FROM EmployeeOrders
)
SELECT employee_id,employee_name,ship_country,ordercount
FROM RankedEmployeeOrders
WHERE rank = 1
ORDER BY 1;



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT*FROM customers;--customer_id,companyname,contactname,contacttitle,address,city,region,postalcode,country,phone,fax
SELECT*FROM employees;--employeeid,firstname,lastname,title,titleofcourtesy,birthdate,hiredate,address,city,
                      --region,postalcode,country,homephone,extension,photo,notes
SELECT*FROM categories;--categoryid,categoryname,description,picture
SELECT*FROM customercustomerdemo;
SELECT*FROM products;--productid,productname,supplierid,categoryid,quantityperunit,unitprice,unitinstock,unitonorder,reorderlevel,
                    --discontinued
SELECT*FROM orders; --orderid,customerid,employeeid,orderdate,requireddate,shippeddate,shipvia,freight,shipname,shipaddress,shipcity
					--shipregion,shippostalcode,shipcountry
SELECT*FROM order_details; --orderid,productid,unitprice,quantity,discount
SELECT*FROM employeeterritories; --employeeid,territoryid
SELECT*FROM region; --region_id,regiondescription


4--PRICE ANALYSIS

--1-Her bir ürünün ortalama satış fiyatını bulunuz.

SELECT p.product_id,p.product_name,ROUND(AVG(od.unit_price)) AS avg_price
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name ORDER BY 1;

--2-Her bir ürünün minimum, maksimum ve ortalama fiyatlarını bulunuz.

SELECT p.product_id,p.product_name,
       ROUND(MIN(od.unit_price)) AS min_price,
       ROUND(MAX(od.unit_price)) AS max_price,
       ROUND(AVG(od.unit_price)) AS avg_price
FROM products p LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY 1,2 ORDER BY 5 DESC;

--3- Her bir kategorinin ortalama ürün fiyatını bulunuz.

SELECT c.category_id,c.category_name,
       ROUND(AVG(od.unit_price)) AS avg_price
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY 1,2 ORDER BY 1;

--4- Her bir kategoride ortalama indirim tutarını getiriniz.
**categories,products,orderdetails

SELECT c.category_id,category_name,AVG(od.discount) 
FROM categories c LEFT JOIN products p ON c.category_id=p.category_id
LEFT JOIN order_details od ON p.product_id=od.product_id
GROUP BY 1,2 ORDER BY 1

--5- En pahalı ilk 10 ürünü getiriniz.

SELECT p.product_id, p.product_name,
       ROUND(MAX(od.unit_price)) AS max_price
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY 1,2 ORDER BY 3 DESC LIMIT 10;

--6- En ucuz ilk 10 ürünü getiriniz.

SELECT p.product_id,p.product_name,
       ROUND(MIN(od.unit_price)) AS min_price
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY 3 ASC LIMIT 10;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT*FROM customers;--customer_id,companyname,contactname,contacttitle,address,city,region,postalcode,country,phone,fax
SELECT*FROM employees;--employeeid,firstname,lastname,title,titleofcourtesy,birthdate,hiredate,address,city,
                      --region,postalcode,country,homephone,extension,photo,notes
SELECT*FROM categories;--categoryid,categoryname,description,picture
SELECT*FROM customercustomerdemo;
SELECT*FROM products;--productid,productname,supplierid,categoryid,quantityperunit,unitprice,unitinstock,unitonorder,reorderlevel,
                    --discontinued
SELECT*FROM orders; --orderid,customerid,employeeid,orderdate,requireddate,shippeddate,shipvia,freight,shipname,shipaddress,shipcity
					--shipregion,shippostalcode,shipcountry
SELECT*FROM order_details; --orderid,productid,unitprice,quantity,discount
SELECT*FROM employeeterritories; --employeeid,territoryid
SELECT*FROM region; --region_id,regiondescription

5--TARİH ANALİZİ


--1-Get the total number of orders for each year.

SELECT EXTRACT(YEAR FROM order_date) as order_year,
COUNT(order_id) as total_orders
FROM orders GROUP BY 1 ORDER BY 1;

--2- Retrieve the orders on a quarterly basis for each year.

SELECT EXTRACT(YEAR FROM order_date) as order_year,
    EXTRACT(QUARTER FROM order_date) as order_quarter,
    COUNT(order_id) as total_orders
FROM orders GROUP BY 1,2 ORDER BY 1,2;

--3-Find the number of orders made by each customer on a monthly basis for each year.

SELECT customer_id,
COUNT(customer_id) as number_of_order,
EXTRACT(YEAR FROM order_date) as years,
EXTRACT(MONTH FROM order_date) as months 
FROM orders GROUP BY 1,3,4 ORDER BY 3;

--4- List the customers with the most orders between '1996-09-15' and '1998-01-12' and display their companies.
SELECT MIN(order_date) FROM orders:"1996-07-04"
SELECT MAX(order_date) FROM orders:"1998-05-06"

SELECT c.customer_id,c.contact_name,COUNT(order_id) as order_count,c.company_name FROM orders o
LEFT JOIN customers c ON c.customer_id=o.customer_id
WHERE order_date BETWEEN '1996-09-15' AND '1998-01-12'
GROUP BY 1,2,4 ORDER BY 3 DESC;

--5- Find the number of repeat customers by year.

SELECT EXTRACT(YEAR FROM first_order_date) AS order_year,
    COUNT(DISTINCT customer_id) AS repeat_customer_count
FROM(SELECT customer_id,MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
) AS customer_first_orders
GROUP BY 1 ORDER BY 1;

--6- Retrieve the first and last order dates for each year.

SELECT EXTRACT(YEAR FROM order_date) AS order_year,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders GROUP BY 1 ORDER BY 1;






-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT*FROM customers;--customer_id,companyname,contactname,contacttitle,address,city,region,postalcode,country,phone,fax
SELECT*FROM employees;--employeeid,firstname,lastname,title,titleofcourtesy,birthdate,hiredate,address,city,
                      --region,postalcode,country,homephone,extension,photo,notes
SELECT*FROM categories;--categoryid,categoryname,description,picture
SELECT*FROM customercustomerdemo;
SELECT*FROM products;--productid,productname,supplierid,categoryid,quantityperunit,unitprice,unitinstock,unitonorder,reorderlevel,
                    --discontinued
SELECT*FROM orders; --orderid,customerid,employeeid,orderdate,requireddate,shippeddate,shipvia,freight,shipname,shipaddress,shipcity
					--shipregion,shippostalcode,shipcountry
SELECT*FROM order_details; --orderid,productid,unitprice,quantity,discount
SELECT*FROM employeeterritories; --employeeid,territoryid
SELECT*FROM region; --region_id,regiondescription


6--REGION ANALYSIS

--1- Get the number of customers by city.

SELECT city,
    COUNT(customer_id) AS customer_count
FROM customers GROUP BY city ORDER BY 2 DESC;

--2-Get the total number of orders by country.

SELECT country,
    COUNT(order_id) AS total_sales
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY country ORDER BY 2 DESC;

--3-Get the total order amount by country and city.

SELECT country,city,
    ROUND(SUM(od.quantity*od.unit_price)) total_order_amount
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_details od ON od.order_id=o.order_id
GROUP BY 1,2 ORDER BY 3 DESC;

--4-Compare the average order amounts across different countries.
SELECT country,
    ROUND(AVG(order_id)) AS avg_order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY 1 ORDER BY 2 DESC;

--5-Find out which product categories are preferred in each city.

SELECT city,c.category_name,
    COUNT(od.order_id) AS total_orders
FROM customers cust
LEFT JOIN orders o ON cust.customer_id = o.customer_id
LEFT JOIN order_details od ON o.order_id = od.order_id
LEFT JOIN products p ON od.product_id = p.product_id
LEFT JOIN categories c ON p.category_id = c.category_id
GROUP BY 1,2 ORDER BY 3 DESC;

--6- Get the total discount amounts by country.

SELECT country,
    SUM(discount) AS total_discount
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_details od ON o.order_id=od.order_id
GROUP BY 1 ORDER BY 2 DESC;
















