-- Testing 'silver_test.cust_dob'
SELECT * FROM silver_test.cust_dob;

-- Identify Out-of-Range Dates
SELECT 
	cst_id
FROM silver_test.cust_dob
WHERE birth_date > NOW()
OR birth_date < '1900-01-01';


-- Data Standardization & Consistency
SELECT 
	DISTINCT gender
FROM silver_test.cust_dob