/*
=============================================================
Create Database or Schemas in MySQL
=============================================================
Script Purpose:
    This script creates a new databases or schema named 'bronze_dev', 'silver_test', 'gold_prod' after checking if it already exists. 
*/



-- create schemas

CREATE SCHEMA IF NOT EXISTS bronze_dev;
CREATE SCHEMA IF NOT EXISTS silver_test;
CREATE SCHEMA IF NOT EXISTS gold_prod;


