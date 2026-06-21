/*
=============================================================
Create TABLE for Silver Layer
=============================================================
Script Purpose:
    This script creates TABLES for 'silver_test' (also log table) after checking if it already exists. 
*/


CREATE TABLE IF NOT EXISTS silver_test.cust_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME DEFAULT NOW()
);


CREATE TABLE IF NOT EXISTS silver_test.prd_info(
    prd_id INT,
    prd_key	VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS silver_test.sales_details(
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS silver_test.cust_dob(
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50),
    dwh_create_date DATETIME DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS silver_test.cust_location(
    cid	VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date DATETIME DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS silver_test.prd_category(
    id VARCHAR(50),
	cat VARCHAR(50),
    subcat VARCHAR(50),
	maintenance VARCHAR(50),
    dwh_create_date DATETIME DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS silver_test.Load_Logs(
    logs_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    table_action VARCHAR(50),
    row_count INT DEFAULT 0,
    load_duration DATETIME,
    load_date DATETIME DEFAULT NOW()
);