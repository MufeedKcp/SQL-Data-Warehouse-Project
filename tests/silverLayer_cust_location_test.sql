-- Testing 'silver_test.cust_location'
SELECT * FROM silver_test.cust_location;

-- Data Standardization & Consistency
SELECT 
	DISTINCT cntry
FROM silver_test.cust_location;
