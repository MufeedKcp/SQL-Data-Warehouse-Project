-- Testing 'gold_prod.fact_sales.'
SELECT * FROM gold_prod.fact_sales;

-- Check for NULLs or Duplicates in Primary Key in fact table
SELECT * 
FROM gold_prod.fact_sales fs
LEFT JOIN gold_prod.dim_customers dc
	ON fs.customer_key = dc.customer_key
LEFT JOIN gold_prod.dim_products dp
	ON fs.product_key = dp.product_key
WHERE dp.product_key IS NULL OR dc.customer_key IS NULL


-- Check for NULLs or Duplicates in Primary Key in DIM CUSTOMERS
SELECT 
    customer_key,
    COUNT(*)
FROM gold_prod.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1 OR customer_key IS NULL;


-- Check for NULLs or Duplicates in Primary Key in DIM PRODUCTS
SELECT 
    product_key,
    COUNT(*)
FROM gold_prod.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1 OR product_key IS NULL;