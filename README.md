# SQL Data Warehouse — Medallion Architecture on MySQL

> A production-style data warehouse that ingests raw ERP and CRM data, transforms it through a three-layer Medallion Architecture, and delivers analytics-ready Star Schema views — fully automated with Docker.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Medallion Layer Design](#medallion-layer-design)
4. [Features](#features)
5. [Project Structure](#project-structure)
6. [Architecture Diagram](#architecture-diagram)
7. [Getting Started — User (Docker)](#getting-started--user-docker)
8. [Getting Started — Developer](#getting-started--developer)
9. [Prerequisites](#prerequisites)
10. [Known Issues & Implementation Notes](#known-issues--implementation-notes)
11. [Contributing](#contributing)
12. [Support the Journey](#support-the-journey)
13. [License](#license)

---

## Project Overview

This project implements a **SQL-based Data Warehouse** using the **Medallion Architecture** (Bronze → Silver → Gold) on **MySQL 8.0**. Raw data from two source systems (ERP and a CRM) is ingested, cleaned, standardized, and modelled into a Star Schema optimised for analytical queries.

The entire pipeline is fully automated via **Docker Compose**: a single command spins up a fresh MySQL instance, creates all schemas, loads raw data, applies transformations, and exposes Gold layer views ready for querying.

**Source systems:** CRM (customer, product, sales) · ERP (customer demographics, location, product category)  
**Output:** 1 Fact view + 2 Dimension views in a Star Schema  
**Database:** MySQL 8.0.46 · **Automation:** Docker Compose

---

## Architecture Diagram


<img src="/SQL-Data-Warehouse-Project/docs/1st-architecture.drawio" width="300" alt="My Architecture Diagram">

> Medallion flow diagram — Bronze ingestion → Silver transformation → Gold Star Schema


<img src="/SQL-Data-Warehouse-Project/docs/Data_Model.drawio" width="300" alt="My Architecture Diagram">

> Star schema ERD — fact_sales_details with dim_customers and dim_products

<img src="/SQL-Data-Warehouse-Project/docs/SQL-dwh-architecture.drawio" width="300" alt="My Architecture Diagram">

---

## Medallion Layer Design

| Layer | Schema | Purpose | Objects |
|---|---|---|---|
| **Bronze** | `bronze_dev` | Raw ingestion — no transformations | 6 tables |
| **Silver** | `silver_test` | Cleansed, standardised, business-rule-enforced | 6 tables |
| **Gold** | `gold_prod` | Analytics-ready Star Schema | 3 views |

### Bronze — Raw Ingestion

Data is loaded directly from CSV files using MySQL `LOAD DATA INFILE`. Tables mirror the source structure with no transformation applied. The `IGNORE INTO TABLE` flag is used to handle duplicate key conflicts on reload.

### Silver — Transformation & Quality

All six source tables are cleansed and conformed before loading into Silver:

- **String hygiene:** leading/trailing whitespace trimmed across all text columns.
- **Date standardisation:** all date fields normalised to a consistent format.
- **Temporal consistency:** `end_date` is derived from the next record's `start_date` using `LEAD()` minus one day; records where `end_date` precedes `start_date` are corrected.
- **Sales integrity:**
  - `Sales = Quantity × Price` is enforced.
  - Negative, zero, or null sales values are recalculated as `Quantity × Price`.
  - Null or zero price is derived as `Sales ÷ Quantity`.
  - Negative price values are converted to their absolute value.
- **Duplicate handling:** managed at load time via the chosen ingestion strategy.

### Gold — Star Schema Views

Three views expose the final analytical model:

| View | Type | Description |
|---|---|---|
| `gold_prod.dim_customers` | Dimension | Unified customer profile (demographics + location) |
| `gold_prod.dim_products` | Dimension | Product master with category |
| `gold_prod.fact_sales_details` | Fact | Sales transactions with keys to both dimensions |

---

## Features

- **Zero-touch pipeline** — `docker compose up -d` runs the entire warehouse end-to-end
- **Medallion Architecture** — clear separation of raw, cleansed, and modelled data
- **Star Schema** — Gold layer structured for direct use in BI tools
- **Business rule enforcement** — sales, price, and date logic applied in Silver
- **Temporal SCD handling** — `end_date` derived with `LEAD()` window function
- **Data quality tests** — SQL test scripts for Silver and Gold layers
- **Containerised MySQL** — reproducible environment, no local MySQL installation required
- **Least-privilege access** — dedicated DB user `MufeedKcp` granted only required permissions

---

## Project Structure

```
SQL-DWH-PROJECT/
├── SQL-Data-Warehouse-Project/
│   ├── datasets/
│   │   ├── source_crm/          # Raw CRM CSV files
│   │   └── source_erp/          # Raw ERP CSV files
│   ├── docs/                    # Supporting documentation & diagrams
│   ├── scripts/                 # SQL scripts (auto-executed by Docker)
│   │   ├── ddl_bronze.sql       # Bronze, silver, gold schema + table definitions
│   │   ├── load_bronze.sql      # LOAD DATA INFILE ingestion
│   │   ├── silver_ddl.sql       # Table definitions
│   │   ├── silver_load.sql      # Silver transformation & load logic
│   │   ├── view_gold.sql        # View definitions
│   │   └── garnt_permission.sql # User permissions grant
│   ├── tests/
│   │   ├── gold_layer_test.sql
│   │   ├── silverLayer_cust_dob_test.sql
│   │   ├── silverLayer_cust_info_test.sql
│   │   ├── silverLayer_cust_location_test.sql
│   │   ├── silverLayer_prd_category_test.sql
│   │   ├── silverLayer_prd_info_test.sql
│   │   └── silverLayer_sales_details_test.sql
│   ├── docker-compose.yml
│   ├── LICENSE
│   └── README.md
├── .env                         # Environment variables, not committed
└── .gitignore                   # Environment variables, not committed
```

---

## Getting Started — User (Docker)

> **No local MySQL installation needed.** Docker handles everything.

### 1. Clone the repository

```bash
git clone https://github.com/MufeedKcp/sql-data-warehouse-project-1
cd SQL-DWH-PROJECT/SQL-Data-Warehouse-Project
```

### 2. Start the warehouse

```bash
docker compose up -d
```

Docker will automatically:

1. Start a MySQL 8.0.46 container on port `3307`
2. Create `bronze_dev`, `silver_test`, and `gold_prod` schemas
3. Define all Bronze tables and load raw CSV data
4. Apply Silver transformations and load cleansed data
5. Create Gold layer Star Schema views
6. Grant permissions to user `MufeedKcp`

> The first startup may take 1–2 minutes while all scripts execute in sequence.

### 3. Connect and query

```bash
mysql -h 127.0.0.1 -P 3307 -u MufeedKcp -pMufeedKcp12345
```

```sql
-- Example: query the Gold layer
SELECT * FROM gold_prod.fact_sales_details LIMIT 10;
SELECT * FROM gold_prod.dim_customers LIMIT 10;
SELECT * FROM gold_prod.dim_products LIMIT 10;
```

### 4. Tear down

```bash
docker compose down          # Stop containers, preserve data volume
docker compose down -v       # Stop containers and delete all data
```

---

## Getting Started — Developer

### Modify SQL scripts

All pipeline scripts live in `scripts/` and are mounted read-only into the container at `/docker-entrypoint-initdb.d`. MySQL executes them in alphabetical order on first container initialisation.

To iterate on a script:

```bash
# Tear down the existing container (including volume) to force re-execution
docker compose down -v

# Edit your target script
vim scripts/silver_load.sql

# Restart — all scripts re-run from scratch
docker compose up -d
```

### Docker Compose configuration

```yaml
# Key settings from docker-compose.yml
service:   mysql:8.0.46
port:      3307:3306
user:      MufeedKcp
volumes:
  ./scripts  → /docker-entrypoint-initdb.d  (read-only)
  ./datasets → /datasets                    (read-only)
  mysql-data → /var/lib/mysql               (persistent)
mysqld flag: --secure-file-priv=            # Required for LOAD DATA INFILE
```

---

## Prerequisites

| Requirement | Version | Notes |
|---|---|---|
| Docker | 20.10+ | Required |
| Docker Compose | v2+ | Included with Docker Desktop |
| MySQL client | Any | Optional — for CLI querying |

No local MySQL installation is required. All database infrastructure is containerised.

---

## Known Issues & Implementation Notes

### `IGNORE INTO TABLE` on Bronze load

Bronze data is loaded using `LOAD DATA INFILE ... IGNORE INTO TABLE`. The `IGNORE` keyword silently skips rows that violate unique key constraints rather than raising an error. This means duplicate keys in source files are dropped without visibility.

**Implication:** Bronze tables may not reflect 100% of the source rows if duplicates exist. This is a known trade-off of the current approach.

**Best practice recommendation:** Loading into a dedicated staging table first (then merging into the target) is the safer pattern — it preserves rejected rows for inspection and avoids silent data loss.

### Schema naming conventions

The schema names `bronze_dev`, `silver_test`, and `gold_prod` reflect environment suffixes from the development lifecycle. Conceptually they represent the **Bronze**, **Silver**, and **Gold** layers of the Medallion Architecture respectively. In a production deployment, these would typically be named `bronze`, `silver`, and `gold` or aligned with your organisation's naming standards.

### No Bronze-layer data quality tests

Data quality tests currently cover the Silver and Gold layers only. Bronze tables are intentionally untested — they represent raw source data as-is. Validation begins at Silver where business rules are applied.

---

## Contributing

Contributions are welcome. Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes with a clear message: `git commit -m "feat: describe your change"`
4. Push to your fork: `git push origin feature/your-feature-name`
5. Open a Pull Request against `main`

Please ensure any new SQL scripts are tested and any schema changes are reflected in the relevant test files under `tests/`.

For bug reports or suggestions, open an issue with a clear description and steps to reproduce.

---

## Support the Journey

If this project was useful or saved you time, consider supporting it:

⭐ **Star this repository** if it helped you — it makes the project easier to find for others.

---

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file included in this repository.