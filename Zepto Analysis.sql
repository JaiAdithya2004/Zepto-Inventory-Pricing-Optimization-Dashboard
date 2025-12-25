USE zepto_analysis;

CREATE TABLE zepto (
  sku_id INT AUTO_INCREMENT PRIMARY KEY,
  category VARCHAR(120),
  name VARCHAR(150) NOT NULL,
  mrp DECIMAL(8,2),
  discountPercent DECIMAL(5,2),
  availableQuantity INT,
  discountedSellingPrice DECIMAL(8,2),
  weightInGms INT,
  outOfStock VARCHAR(10),   -- 0 = FALSE, 1 = TRUE
  quantity INT
);

-- Count of Rows 
select count(*) from zepto;

SELECT *
FROM zepto
LIMIT 10;



-- NULL Value checks
SELECT *
FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;
   
   
-- Checking product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;


-- Product in stock or out-of-stock
SELECT 
  outOfStock,
  COUNT(sku_id) AS product_count
FROM zepto
GROUP BY outOfStock;


-- Product names present multiple times
SELECT 
  name,
  COUNT(sku_id) AS number_of_skus
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY number_of_skus DESC;


-- Products with price = 0 (data cleaning)
SELECT *
FROM zepto
WHERE mrp = 0
   OR discountedSellingPrice = 0;

-- Delete invalid products
DELETE FROM zepto
WHERE sku_id IN (
  SELECT sku_id
  FROM (
    SELECT sku_id
    FROM zepto
    WHERE mrp = 0
  ) AS t
);


-- Convert paise → rupees
UPDATE zepto
SET 
  mrp = mrp / 100,
  discountedSellingPrice = discountedSellingPrice / 100
WHERE sku_id IN (
  SELECT sku_id
  FROM (
    SELECT sku_id
    FROM zepto
    WHERE mrp >= 1000
  ) t
);


-- Verify:
SELECT mrp, discountedSellingPrice
FROM zepto;

-- DATA ANALYSIS 
-- Top 10 best-value products (highest discount)
SELECT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- High-MRP products that are out of stock
SELECT name, mrp
FROM zepto
WHERE outOfStock = 1
  AND mrp > 300
ORDER BY mrp DESC;

-- Estimated revenue per category
SELECT 
  category,
  SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Products with MRP > ₹500 & discount < 10%
SELECT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Top 5 categories with highest average discount
SELECT 
  category,
  ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Price per gram (best value products)
SELECT 
  name,
  weightInGms,
  discountedSellingPrice,
  ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
  AND weightInGms > 0
ORDER BY price_per_gram;

-- Weight-based product classification
SELECT 
  name,
  weightInGms,
  CASE
    WHEN weightInGms < 1000 THEN 'Low'
    WHEN weightInGms < 5000 THEN 'Medium'
    ELSE 'Bulk'
  END AS weight_category
FROM zepto;

-- Total inventory weight per category
SELECT 
  category,
  SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight DESC;

