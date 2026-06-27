-- Testing 'silver_test.cust_info'
SELECT * FROM silver_test.cust_info;

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) 
FROM silver_test.cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
SELECT 
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr
FROM silver_test.cust_info
WHERE cst_key != TRIM(cst_key)
OR cst_firstname != TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname)
OR cst_marital_status != TRIM(cst_marital_status)
OR cst_gndr != TRIM(cst_gndr);


-- Data Standardization & Consistency
SELECT DISTINCT
    cst_marital_status
FROM silver_test.cust_info;

SELECT DISTINCT
    cst_gndr
FROM silver_test.cust_info;