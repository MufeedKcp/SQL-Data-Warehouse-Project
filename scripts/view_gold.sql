
CREATE VIEW gold_prod.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS maritial_status,
CASE 
	WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
    ELSE COALESCE(cb.gen, 'n/a')
END AS gender,
    cl.cntry AS country,
	cb.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver_test.cust_info ci
LEFT JOIN silver_test.cust_dob cb
	ON ci.cst_key = cb.cid 
LEFT JOIN silver_test.cust_location cl
	ON ci.cst_key = cl.cid;


CREATE OR REPLACE VIEW gold_prod.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
	pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    pi.prd_sales_id AS product_sales_id,
    pi.prd_nm AS product_name,
    pi.cat_id AS category_id,
	pc.cat AS category, 
    pc.subcat AS subcategory,
	pc.maintenance,
    pi.prd_cost AS cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS product_start_date
FROM silver_test.prd_info pi
LEFT JOIN silver_test.prd_category pc
	ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL; /* exclude the historical data */ 


CREATE OR REPLACE VIEW gold_prod.fact_sales AS
SELECT 
	sls_ord_num AS order_number, 
    dp.product_key, 
    dc.customer_key, 
    sls_price AS price,
    sls_quantity AS quantity,
    sls_sales AS sales_amount,
	sls_order_dt AS order_date, 
    sls_ship_dt AS shipping_date, 
    sls_due_dt AS due_date
FROM silver_test.sales_details sd
LEFT JOIN gold_prod.dim_products dp
	ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold_prod.dim_customers dc
	ON sd.sls_cust_id = dc.customer_id