-- Check for Unwanted Spaces
SELECT 
	cat,
    subcat,
    maintenance
FROM silver_test.prd_category
WHERE cat != TRIM(cat) 
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);



-- Data Standardization & Consistency for maintenance
SELECT 
	DISTINCT maintenance
FROM silver_test.prd_category;
