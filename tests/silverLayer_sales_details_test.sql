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
SELECT 
	sls_ord_num,
	sls_sales
FROM silver_test.sales_details
WHERE sls_sales < 0 OR sls_sales IS NULL;