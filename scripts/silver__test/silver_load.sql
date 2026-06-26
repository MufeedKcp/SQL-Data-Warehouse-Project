/*

Script Purpose:
    This SQL query performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.

*/

TRUNCATE TABLE silver_test.cust_info;

INSERT INTO silver_test.load_logs(table_name, table_action) 
VALUES('silver_test.cust_info', 'Truncate table');

SET @cust_info_silver_start_load_time = NOW();

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

SET @cust_info_silver_load_end_time = NOW();
SET @cust_info_silver_row_counts = (SELECT COUNT(*) FROM silver_test.cust_info);
SET @cust_info_silver_duration = ROUND((UNIX_TIMESTAMP(@cust_info_silver_load_end_time) - UNIX_TIMESTAMP(@cust_info_silver_start_load_time)), 3);

INSERT INTO silver_test.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('silver_test.cust_info', 'Loading data', @cust_info_silver_row_counts, @cust_info_silver_duration);

-----
 
TRUNCATE TABLE silver_test.prd_info;
INSERT INTO silver_test.load_logs(table_name, table_action) 
VALUES('silver_test.prd_info', 'Truncate table');

SET @prd_info_silver_start_load_time = NOW();

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

SET @prd_info_silver_load_end_time = NOW();
SET @prd_info_silver_row_counts = (SELECT COUNT(*) FROM silver_test.prd_info);
SET @prd_info_silver_duration = ROUND((UNIX_TIMESTAMP(@prd_info_silver_load_end_time) - UNIX_TIMESTAMP(@prd_info_silver_start_load_time)), 3);

INSERT INTO silver_test.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('silver_test.prd_info', 'Loading data', @prd_info_silver_row_counts, @prd_info_silver_duration);

-----

TRUNCATE TABLE silver_test.sales_details;
INSERT INTO silver_test.load_logs(table_name, table_action) 
VALUES('silver_test.sales_details', 'Truncate table');

SET @sales_details_silver_start_load_time = NOW();

INSERT INTO silver_test.sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price 
)
SELECT 
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
CASE
	WHEN sls_order_dt = 0 OR CHAR_LENGTH(sls_order_dt) != 8 THEN NULL
	ELSE CAST(sls_order_dt AS DATE)
END AS sls_order_dt,
CASE
	WHEN sls_ship_dt = 0 OR CHAR_LENGTH(sls_ship_dt) != 8 THEN NULL
	ELSE CAST(sls_ship_dt AS DATE)
END AS sls_ship_dt,
CASE
	WHEN sls_due_dt = 0 OR CHAR_LENGTH(sls_due_dt) != 8 THEN NULL
	ELSE CAST(sls_due_dt AS DATE)
END AS sls_due_dt,
    CASE 
	WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_quantity) * ABS(sls_price) THEN ABS(sls_price) * sls_quantity
    ELSE sls_sales
END AS new_sls_sales,
    sls_quantity,
    CASE 
    WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS new_sls_price
FROM bronze_dev.crm_sales_details;

SET @sales_details_silver_load_end_time = NOW();
SET @sales_details_silver_row_counts = (SELECT COUNT(*) FROM silver_test.sales_details);
SET @sales_details_silver_duration = ROUND((UNIX_TIMESTAMP(@sales_details_silver_load_end_time) - UNIX_TIMESTAMP(@sales_details_silver_start_load_time)), 3);

INSERT INTO silver_test.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('silver_test.sales_details', 'Loading data', @sales_details_silver_row_counts, @sales_details_silver_duration);
------

TRUNCATE TABLE silver_test.cust_dob;
INSERT INTO silver_test.load_logs(table_name, table_action) 
VALUES('silver_test.cust_dob', 'Truncate table');

SET @cust_dob_silver_start_load_time = NOW();

INSERT INTO silver_test.cust_dob(
    cst_id,
    birth_date,
    gender
)
SELECT 
CASE 
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, CHAR_LENGTH(cid)) 
    ELSE cid
END AS cst_id,
CASE 
	WHEN bdate > NOW() THEN NULL
    ELSE bdate
END AS birth_date,
CASE
	WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
    WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(gen)) = 'Female' THEN 'Female'
    WHEN UPPER(TRIM(gen)) = 'Male' THEN 'Male'
    ELSE 'n/a'
END AS cust_gender
FROM bronze_dev.erp_cust_az12;

SET @cust_dob_silver_load_end_time = NOW();
SET @cust_dob_silver_row_counts = (SELECT COUNT(*) FROM silver_test.cust_dob);
SET @cust_dob_silver_duration = ROUND((UNIX_TIMESTAMP(@cust_dob_silver_load_end_time) - UNIX_TIMESTAMP(@cust_dob_silver_start_load_time)), 3);

INSERT INTO silver_test.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('silver_test.cust_dob', 'Loading data', @cust_dob_silver_row_counts, @cust_dob_silver_duration);

-------

TRUNCATE TABLE silver_test.cust_location;
INSERT INTO silver_test.load_logs(table_name, table_action) 
VALUES('silver_test.cust_location', 'Truncate table');

SET @cust_location_silver_start_load_time = NOW();

INSERT INTO silver_test.cust_location(
	cid,
    cntry
)
SELECT 
	REPLACE(cid, '-', '') AS cst_key,
CASE
	WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
    WHEN TRIM(UPPER(cntry)) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    ELSE TRIM(cntry)
END AS cst_country
FROM bronze_dev.erp_loc_a101
ORDER BY cntry;

SET @cust_location_silver_load_end_time = NOW();
SET @cust_location_silver_row_counts = (SELECT COUNT(*) FROM silver_test.cust_location);
SET @cust_location_silver_duration = ROUND((UNIX_TIMESTAMP(@cust_location_silver_load_end_time) - UNIX_TIMESTAMP(@cust_location_silver_start_load_time)), 3);

INSERT INTO silver_test.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('silver_test.cust_location', 'Loading data', @cust_location_silver_row_counts, @cust_location_silver_duration);

------

TRUNCATE TABLE silver_test.prd_category;
INSERT INTO silver_test.load_logs(table_name, table_action) 
VALUES('silver_test.prd_category', 'Truncate table');

SET @prd_category_silver_start_load_time = NOW();

INSERT INTO silver_test.prd_category(
	id,
    cat,
    subcat,
    maintenance)
SELECT 
	id,
    cat,
    subcat,
    maintenance
FROM bronze_dev.erp_px_cat_g1v2 ORDER BY id;

SET @prd_category_silver_load_end_time = NOW();
SET @prd_category_silver_row_counts = (SELECT COUNT(*) FROM silver_test.cust_location);
SET @prd_category_silver_duration = ROUND((UNIX_TIMESTAMP(@prd_category_silver_load_end_time) - UNIX_TIMESTAMP(@prd_category_silver_start_load_time)), 3);

INSERT INTO silver_test.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('silver_test.prd_category', 'Loading data', @prd_category_silver_row_counts, @prd_category_silver_duration);


