USE `walmart_sales`;

SELECT * FROM sales;


-- Data Wrangling
-- Search Duplicate Value
WITH search_duplicate AS(
SELECT
	*,
    ROW_NUMBER() OVER 
		(PARTITION BY 
			invoice_id,
            branch, city, 
            customer_type, 
            gender, 
            product_line, 
            unit_price, 
            quantity, 
            `tax 5%`, 
            total, `date`, 
            `time`, 
            payment, 
            cogs, 
            gross_margin_percentage, 
            gross_income, 
            rating) AS row_num
FROM sales)
SELECT * FROM search_duplicate
WHERE row_num > 1;

-- SEARCHING NULL VALUE
SELECT * FROM sales
WHERE
			invoice_id IS NULL OR
			branch IS NULL OR
			city IS NULL OR 
            customer_type IS NULL OR
            gender IS NULL OR
            product_line IS NULL OR
            unit_price IS NULL OR
            quantity IS NULL OR
            `tax 5%` IS NULL OR
            total IS NULL OR
            `date` IS NULL OR
            `time` IS NULL OR
            payment IS NULL OR
            cogs IS NULL OR
            gross_margin_percentage IS NULL OR
            gross_income IS NULL OR
            rating IS NULL;
            
-- SEARCHING Blank VALUE
SELECT * FROM sales
WHERE
			invoice_id = '' OR
			branch = '' OR
			city = '' OR 
            customer_type = '' OR
            gender = '' OR
            product_line = '' OR
            payment = '';
            
-- Check column kategori adakah yang typo 
SELECT DISTINCT branch FROM sales ORDER BY branch ASC;
SELECT DISTINCT city FROM sales ORDER BY city ASC;
SELECT DISTINCT customer_type FROM sales ORDER BY customer_type ASC;
SELECT DISTINCT product_line FROM sales ORDER BY product_line ASC;
SELECT DISTINCT payment FROM sales ORDER BY payment ASC;

-- Feature Enginerining

-- Add time_of_day (Open 10.00 - 21.00)

CREATE TABLE `sales_step1` (
  `invoice_id` text,
  `branch` text,
  `city` text,
  `customer_type` text,
  `gender` text,
  `product_line` text,
  `unit_price` double DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `tax 5%` double DEFAULT NULL,
  `total` double DEFAULT NULL,
  `date` text,
  `time` text,
  `payment` text,
  `cogs` double DEFAULT NULL,
  `gross_margin_percentage` double DEFAULT NULL,
  `gross_income` double DEFAULT NULL,
  `rating` double DEFAULT NULL,
  `time_of_day` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM sales_step1;

INSERT INTO sales_step1 
SELECT 
	*,
	CASE
		WHEN TIME(`time`) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(`time`) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;

-- Ubah tiper daya date (String to Date)
SELECT
	*,
  STR_TO_DATE(date, '%m/%d/%Y') AS `new_date`,
  MONTHNAME(STR_TO_DATE(date, '%m/%d/%Y')) AS month_name,
  DAYNAME(STR_TO_DATE(date, '%m/%d/%Y')) AS day_name
FROM sales_step2;



SELECT * FROM sales_step2;

CREATE TABLE `sales_step2` (
  `invoice_id` text,
  `branch` text,
  `city` text,
  `customer_type` text,
  `gender` text,
  `product_line` text,
  `unit_price` double DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `tax 5%` double DEFAULT NULL,
  `total` double DEFAULT NULL,
  `date` text,
  `time` text,
  `payment` text,
  `cogs` double DEFAULT NULL,
  `gross_margin_percentage` double DEFAULT NULL,
  `gross_income` double DEFAULT NULL,
  `rating` double DEFAULT NULL,
  `time_of_day` text DEFAULT NULL,
  `new_date` date DEFAULT NULL,
  `month_name` text,
  `day_name` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM sales_step2;

INSERT INTO sales_step2
SELECT
	*,
  STR_TO_DATE(date, '%m/%d/%Y') AS `new_date`,
  MONTHNAME(STR_TO_DATE(date, '%m/%d/%Y')) AS month_name,
  DAYNAME(STR_TO_DATE(date, '%m/%d/%Y')) AS day_name
FROM sales_step1;

SELECT * FROM sales_step2;

-- EDA

SELECT * FROM sales_step2;

-- Generic
-- Unique City
SELECT COUNT(DISTINCT city) AS total_city FROM sales_step2;   
SELECT DISTINCT city FROM sales_step2;

-- Product
-- Berapa banyak Lini product unique
SELECT DISTINCT product_line FROM sales_step2;
SELECT COUNT(DISTINCT product_line) AS `Count Of Product Line` FROM sales_step2; 

-- Metode pembayaran yang paling sering digunakan
SELECT
	payment,
    COUNT(payment) AS total
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;



-- Lini product yang paling banyak terjual
SELECT
	product_line,
    SUM(quantity) AS total_sold
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;

-- Revenue Per Bulan
SELECT
	month_name,
	ROUND(SUM(total),2) AS total_revenue
FROM sales_step2
GROUP BY month_name ORDER BY FIELD(month_name, 'January', 'February', 'March');

-- Bulan dengan COGS terbesar
SELECT 
	month_name,
    ROUND(SUM(cogs),2) As total_cogs
FROM sales_step2
GROUP BY month_name ORDER BY FIELD(month_name, 'January', 'February', 'March');

-- Lini produk dengan pendapatan terbesar
SELECT
	product_line,
	ROUND(SUM(total),2) AS total_revenue
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;

-- Kota dengan pendapatan terbesar
SELECT 
	city,
    ROUND(SUM(total), 2) AS total_revenue
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;

-- Lini product yang menyumbang VAT terbesar 
SELECT
	product_line,
    ROUND(SUM(`tax 5%`),2) AS total_vat
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;

-- Peforma lini product berdasarkan total revenue dibanding rata rata keseluruhan penjualan product 
WITH total_revenue AS (
SELECT
	product_line,
    ROUND(SUM(total),2) AS total_revenue
FROM sales_step2
GROUP BY 1
ORDER BY 2 DESC
),
avg_total AS (
SELECT
	ROUND(AVG(total_revenue),2) AS avg_revenue
FROM total_revenue
)
SELECT
	product_line,
    total_revenue,
    CASE 
		WHEN total_revenue > avg_revenue THEN 'Good'
        ELSE 'Bad'
	END AS `Status`
FROM total_revenue JOIN avg_total;

-- Cabang mana yang menjual lebih banyak daripada rata rata
WITH total_product AS (
SELECT
	branch,
    SUM(quantity) AS total_product_sold
FROM sales_step2  
GROUP BY 1
), avg_product AS (
SELECT
	AVG(total_product_sold) AS avg_product_sold
FROM total_product
)
SELECT
	branch,
    total_product_sold,
    CASE
		WHEN total_product_sold > avg_product_sold THEN 'More Than AVG'
        ELSE 'Less Then Average'
    END AS `status`,
    avg_product_sold
FROM total_product JOIN avg_product;

-- Lini product yang paling sering dibeli berdasarkan gender
SELECT
	gender,
    product_line,
    SUM(quantity) AS total_sold,
    RANK() OVER(PARTITION BY gender ORDER BY SUM(quantity) DESC) AS rank_product_sold
FROM sales_step2
GROUP BY gender, product_line;

-- Rata rata rating setiap lini product
SELECT 
	product_line,
	SUM(`rating`) AS `total_rating`,
    COUNT(product_line) AS total_product_sold,
    SUM(`rating`) / COUNT(product_line) AS avg_rating
FROM sales_step2 GROUP BY 1 ORDER BY 4 DESC;

SELECT * FROM sales_step2;

-- Sales
 
 SELECT
	day_name,
    time_of_day,
	ROUND(SUM(total),2) AS total_penjualan
FROM sales_step2
GROUP BY 1,2
ORDER BY 	FIELD(day_name, 'Monday', 'Thursday', 'Wednesday', 'Tuesday', 'Friday', 'Saturday'),
			FIELD(time_of_day, 'Morning','Evening','Afternoon');
            
 -- Penjualan berdarakan jenis pelanggan
 SELECT
	customer_type,
    ROUND(SUM(total),2) AS total_revenue
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;

-- Kota yang memiliki rata rata VAT terbesar
SELECT 
	city,
    ROUND(AVG((`tax 5%` / total) * 100),2) AS `percentage VAT`
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;

-- Pelanggan mana yang menyumbang VAT terbesar
SELECT
	customer_type,
    ROUND(SUM(`tax 5%`),2) AS total_revenue
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;

SELECT * FROM sales_step2;

-- Customer

-- Berapa jenis pelanggan unik 
SELECT DISTINCT(customer_type) FROM sales_step2;
SELECT COUNT(DISTINCT(customer_type)) AS total_unique_customer_type FROM sales_step2;

-- Berapa jenis pembayaran unik
SELECT DISTINCT(payment) FROM sales_step2;
SELECT COUNT(DISTINCT(payment)) AS total_unique_customer_type FROM sales_step2;

-- Jenis pelanggan umum
SELECT
	customer_type,
    COUNT(customer_type) AS `Total Transaction`
FROM sales_step2
GROUP BY 1;

-- Jenis pelanggan yang paling banyak membeli
SELECT
	customer_type,
    SUM(quantity) AS `Total Product Sold`
FROM sales_step2
GROUP BY 1;

-- Jenis kelamin terbanyak
SELECT
	gender,
    COUNT(gender) AS `Total Buyer By Gender`
FROM sales_step2
GROUP BY 1;

-- Distribusi kelamin disetiap cabang
SELECT
	branch,
    gender,
    COUNT(gender) AS `Count Of Gender`
FROM sales_step2
GROUP BY 1,2 ORDER BY 1 ASC;

-- Pada waktu apa dalam sehari pelanggan paling banyak memberikan rating?
SELECT
	time_of_day,
    COUNT(rating) AS `Rating`
FROM sales_step2
GROUP BY 1 ORDER BY 2 DESC;

-- Pada waktu apa dalam sehari pelanggan paling banyak memberikan rating di setiap cabang? 
SELECT
	branch,
	time_of_day,
    COUNT(rating) AS `Rating`
FROM sales_step2
GROUP BY 1,2 ORDER BY 	FIELD(branch, 'A','B','C'),
						FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening');
                        

--  Hari apa dalam seminggu yang memiliki rata-rata rating terbaik?
SELECT
	day_name,
	ROUND(SUM(rating) / COUNT(rating),2) AS AVG
FROM sales_step2 GROUP BY 1 ORDER BY 2 DESC;

--  Hari apa dalam seminggu yang memiliki rata-rata rating terbaik di setiap cabang?
SELECT
	day_name,
    branch,
	ROUND(SUM(rating) / COUNT(rating),2) AS AVG
FROM sales_step2 GROUP BY 1,2 ORDER BY 3 DESC;








	




	


	










 


    
 













