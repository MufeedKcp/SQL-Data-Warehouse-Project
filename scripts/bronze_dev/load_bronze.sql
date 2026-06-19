/*

Script Purpose:
    This sql scripts loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `LOAD DATA LOCAL INFILE` command to load data from csv Files to bronze tables.
    - log the each action in 'bronze_dev.load_logs' table


ERROR Handled in local_infile in MySQL:

    - Step 1: Log into your MySQL console as root and run the following command:
        >> SET GLOBAL local_infile = 1;

    - Step 2: Enable on the Client Side (Even if the server allows it, 
        your client terminal or application must explicitly declare that it wants to use the local infile capability.)

        ~ If using the Command Line Client:
        Launch your MySQL command-line connection by adding the:
        >> `--local-infile` flag explicitly: 

        If using MySQL Workbench:
        1. Close your active connection window.
        2. Database menu → **Manage Server Connections**.
        3. Select your connection profile and click on the **Advanced** parameters tab.
        4. In the text box labeled **Others:**, enter this cmd:
            >> OPT_LOCAL_INFILE=1

    - step 3: Click close, and reconnect to your database instance. 

*/

TRUNCATE TABLE bronze_dev.crm_cust_info;

SET @crm_cust_start_load_time = NOW();

LOAD DATA LOCAL INFILE 'C:/Users/biten/Downloads/data_warehouse_pro/sql-data-warehouse-project/datasets/source_crm/cust_info.csv' 
INTO TABLE bronze_dev.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @crm_cust_load_end_time = NOW();
SET @crm_cust_row_counts = (SELECT COUNT(*) FROM bronze_dev.crm_cust_info);
SET @crm_cust_duration = ROUND((UNIX_TIMESTAMP(@crm_cust_load_end_time) - UNIX_TIMESTAMP(@crm_cust_start_load_time)), 3);

INSERT INTO bronze_dev.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('bronze_dev.crm_cust_info', 'Loading data', @crm_cust_row_counts, COALESCE(@crm_cust_duration, 0));

SELECT CONCAT('Loaded ', @crm_cust_row_counts, ' rows into crm_cust_info table in ', ROUND(COALESCE(@crm_cust_duration, 0), 2), 'seconds') AS load_message;

-------------------------------------------------------------------------------------------------------------------------------------------------

TRUNCATE TABLE bronze_dev.crm_prd_info;

SET @crm_prd_start_load_time = NOW();

LOAD DATA LOCAL INFILE 'C:/Users/biten/Downloads/data_warehouse_pro/sql-data-warehouse-project/datasets/source_crm/prd_info.csv' 
INTO TABLE bronze_dev.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @crm_prd_load_end_time = NOW();
SET @crm_prd_row_counts = (SELECT COUNT(*) FROM bronze_dev.crm_prd_info);
SET @crm_prd_duration = ROUND((UNIX_TIMESTAMP(@crm_prd_end_load_time) - UNIX_TIMESTAMP(@crm_prd_start_load_time)), 3);

INSERT INTO bronze_dev.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('bronze_dev.crm_prd_info', 'Loading data', @crm_prd_row_counts, COALESCE(@crm_prd_duration, 0));

SELECT CONCAT('Loaded ', @crm_prd_row_counts, ' rows into crm_prd_info table in ', ROUND(COALESCE(@crm_prd_duration, 0), 2), 'seconds') AS load_message;
-----------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE bronze_dev.crm_sales_details;

SET @crm_sales_start_load_time = NOW();

LOAD DATA LOCAL INFILE 'C:/Users/biten/Downloads/data_warehouse_pro/sql-data-warehouse-project/datasets/source_crm/sales_details.csv' 
INTO TABLE bronze_dev.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @crm_sales_load_end_time = NOW();
SET @crm_sales_row_counts = (SELECT COUNT(*) FROM bronze_dev.crm_sales_details);
SET @crm_sales_duration = ROUND((UNIX_TIMESTAMP(@crm_sales_load_end_time) - UNIX_TIMESTAMP(@crm_sales_start_load_time)), 3);

INSERT INTO bronze_dev.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('bronze_dev.crm_sales_details', 'Loading data', @crm_sales_row_counts, @crm_sales_duration);

SELECT CONCAT('Loaded ', @crm_sales_row_counts, ' rows into crm_sales_details table in ', ROUND(COALESCE(@crm_sales_duration, 0), 2), 'seconds') AS load_message;
-----------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE bronze_dev.erp_cust_az12;

SET @erp_cust_start_load_time = NOW();

LOAD DATA LOCAL INFILE 'C:/Users/biten/Downloads/data_warehouse_pro/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv' 
INTO TABLE bronze_dev.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @erp_cust_load_end_time = NOW();
SET @erp_cust_row_counts = (SELECT COUNT(*) FROM bronze_dev.erp_cust_az12);
SET @erp_cust_duration = ROUND((UNIX_TIMESTAMP(@erp_cust_load_end_time) - UNIX_TIMESTAMP(@erp_cust_start_load_time)), 3);

INSERT INTO bronze_dev.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('bronze_dev.erp_cust_az12', 'Loading data', @erp_cust_row_counts, @erp_cust_duration);

SELECT CONCAT('Loaded ', @erp_cust_row_counts, ' rows into erp_cust_az12 table in ', ROUND(COALESCE(@erp_cust_duration, 0), 2), 'seconds') AS load_message;
-----------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE bronze_dev.erp_loc_a101;

SET @erp_loc_start_load_time = NOW();

LOAD DATA LOCAL INFILE 'C:/Users/biten/Downloads/data_warehouse_pro/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv' 
INTO TABLE bronze_dev.erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @erp_loc_load_end_time = NOW();
SET @erp_loc_row_counts = (SELECT COUNT(*) FROM bronze_dev.erp_loc_a101);
SET @erp_loc_duration = ROUND((UNIX_TIMESTAMP(@erp_loc_load_end_time) - UNIX_TIMESTAMP(@erp_loc_start_load_time)), 3);

INSERT INTO bronze_dev.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('bronze_dev.erp_loc_a101', 'Loading data', @row_counts, COALESCE(@erp_loc_duration, 0));

SELECT CONCAT('Loaded ', @erp_loc_row_counts, ' rows into erp_loc_a101 table in ', ROUND(COALESCE(@erp_loc_duration, 0), 2), 'seconds') AS load_message;
-----------------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE bronze_dev.erp_px_cat_g1v2;

SET @erp_cat_start_load_time = NOW();

LOAD DATA LOCAL INFILE 'C:/Users/biten/Downloads/data_warehouse_pro/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv' 
INTO TABLE bronze_dev.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @erp_cat_load_end_time = NOW();
SET @erp_cat_row_counts = (SELECT COUNT(*) FROM bronze_dev.erp_px_cat_g1v2);
SET @erp_cat_duration = ROUND((UNIX_TIMESTAMP(@erp_cat_load_end_time) - UNIX_TIMESTAMP(@erp_cat_start_load_time)), 3);

INSERT INTO bronze_dev.load_logs(table_name, table_action, row_count, load_duration) 
VALUES('bronze_dev.erp_px_cat_g1v2', 'Loading data', @erp_cat_row_counts, @erp_cat_duration);

SELECT CONCAT('Loaded ', @erp_cat_row_counts, ' rows into erp_px_cat_g1v2 table in ', ROUND(COALESCE(@erp_cat_duration, 0), 2), 'seconds') AS load_message;
