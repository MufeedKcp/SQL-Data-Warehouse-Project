/*
=============================================================
Create Database & table in MySQL
=============================================================
Script Purpose:
    This script creates tables and a new databases named 'bronze_dev', 'silver_test', 'gold_prod' after checking if it already exists. 
*/

-- create schemas

CREATE SCHEMA IF NOT EXISTS bronze_dev;

CREATE SCHEMA IF NOT EXISTS silver_test;

CREATE SCHEMA IF NOT EXISTS gold_prod;


-- create tables

CREATE TABLE bronze_dev.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);


CREATE TABLE bronze_dev.crm_prd_info(
    prd_id INT,
    prd_key	VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);

CREATE TABLE bronze_dev.crm_sales_details(
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

CREATE TABLE bronze_dev.erp_cust_az12(
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);

CREATE TABLE bronze_dev.erp_loc_a101(
    cid	VARCHAR(50),
    cntry VARCHAR(50)
);

CREATE TABLE bronze_dev.erp_px_cat_g1v2(
    id VARCHAR(50),
	cat VARCHAR(50),
    subcat VARCHAR(50),
	maintenance VARCHAR(50)
);


-- create table for logs 

CREATE TABLE IF NOT EXISTS bronze_dev.Load_Log_Table(
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    table_action VARCHAR(50),
    row_count INT DEFAULT 0,
    load_duration DATETIME
);