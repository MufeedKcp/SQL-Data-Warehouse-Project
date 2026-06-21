/*

Script Purpose:
    This SQL query performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.

*/

-- deduplicated PK 
-- exclude PK value 'ZERO'
-- TRIM string values
-- Convert abbreviation value into full value for more understandability
-- converted cst_gndr to cst_gender for readability
INSERT INTO silver_test.cust_info(
	cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date)
SELECT 
	cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
CASE 
	WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'Married'
    WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'Single'
    ELSE 'n/a'
END AS cst_marital_status,
CASE 
	WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Male'
    WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Female'
    ELSE 'n/a'
END AS cst_gender,
	cst_create_date
FROM(
SELECT 
	*,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze_dev.crm_cust_info
) AS t
WHERE flag_last = 1 AND cst_id != 0;


-- derived column from prd_key into 'cat_id & prd_sales_id
-- convert abbreviation value into full value for more understandability
-- derived prd_end_dt from prd_start_dt by setting Start_date of the next record using `LEAD()` also minus 1 day
-- deduplicated PK 

INSERT INTO silver_test.prd_info(
	prd_id ,
    prd_key,
    cat_id,
    prd_sales_id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
	prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, CHAR_LENGTH(prd_key)) AS prd_sales_id,
    prd_nm,
	prd_cost,
CASE UPPER(TRIM(prd_line))
	WHEN 'M' THEN 'Mainstream'
    WHEN 'S' THEN 'Specialty'
    WHEN 'T' THEN 'Trial'
    WHEN 'R' THEN 'Retail'
    ELSE 'n/a'
END AS prd_line,
	prd_start_dt,
    DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY) AS prd_end_dt
FROM bronze_dev.crm_prd_info;