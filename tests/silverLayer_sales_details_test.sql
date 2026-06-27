-- Testing 'silver_test.sales_details'
SELECT * FROM silver_test.sales_details;


-- Invalid date checks
SELECT 
	sls_order_dt,
    sls_order_dt,
    sls_ship_dt
FROM silver_test.sales_details
WHERE sls_order_dt > NOW()
OR sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt;


-- NULL or Negative amount
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver_test.sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;