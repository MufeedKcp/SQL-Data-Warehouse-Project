-- Testing 'silver_test.prd_info'
SELECT * FROM silver_test.prd_info;

-- Check for NULLs or Duplicates in Primary Key
SELECT
	prd_id,
    count(*)
FROM silver_test.prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- product line abbriviation checks
SELECT DISTINCT prd_line
FROM silver_test.prd_info;


-- Null or Negative amount
SELECT 
    prd_cost 
FROM silver_test.prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- invalid date checker
SELECT *
FROM silver_test.prd_info
WHERE prd_end_dt < prd_start_dt;


-- Check for Unwanted Spaces
SELECT 
	prd_key,
	cat_id,
    prd_nm,
    prd_line
FROM silver_test.prd_info
WHERE prd_key != TRIM(prd_key)
OR cat_id != TRIM(cat_id)
OR prd_nm != TRIM(prd_nm)
OR prd_line != TRIM(prd_line);