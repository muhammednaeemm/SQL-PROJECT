# Global Workforce Analytics & Layoff Trend Analysis

## Overview
An end-to-end SQL database setup and analytics project analyzing global technology layoffs from 2020 to 2024. This repository covers the design of a PostgreSQL relational database (using a star-schema), loading data, and running 20 analytical queries to uncover key layoff trends by industry, year, country, and funding stage.

## Project Structure
The repository is organized according to the course guidelines:
* **`docs/`**
  * `Student_2_Layoffs_Project_Guide.pdf` — The complete project guide & requirements document.
* **`project_data/`** — Normalized database tables provided in CSV format:
  * `dim_company.csv` — Dimension table for company details (names, stage, funding, size category).
  * `dim_location.csv` — Dimension table for locations (city, country).
  * `dim_industry.csv` — Dimension table for industry sectors.
  * `fact_layoffs.csv` — Fact table documenting individual layoff events.
* **`sql/`**
  * [create_tables.sql](file:///c:/Users/Nabeel/Desktop/SQL%20PROJECTTTT/sql/create_tables.sql) — DDL statements to drop and recreate the tables.
  * [queries.sql](file:///c:/Users/Nabeel/Desktop/SQL%20PROJECTTTT/sql/queries.sql) — Solutions to all 20 course analytical tasks.
* **`setup_and_analyze.py`** — An automated script to set up the database, load CSV data, and execute all 20 queries, outputting formatted results.

---

## Database Schema Design (Star Schema)
The database structure is normalized into a star schema for efficient workforce trend analysis:

```
                  dim_company
             (company_id - SERIAL PK)
                        │
                        │ 1
                        │
                        │ M
                   fact_layoffs
             (layoff_id - SERIAL PK)
             (company_id - FK dim_company)
             (location_id - FK dim_location)
             (industry_id - FK dim_industry)
                        │
         ┌──────────────┴──────────────┐
         │ M                           │ M
         │                             │
         │ 1                           │ 1
    dim_location                  dim_industry
(location_id - SERIAL PK)     (industry_id - SERIAL PK)
```

### Table Structure Summary
1. **`dim_company`**: `company_id` (PK), `company_name`, `stage`, `funds_raised_millions`, `company_size_category`
2. **`dim_location`**: `location_id` (PK), `location`, `country`
3. **`dim_industry`**: `industry_id` (PK), `industry_name`
4. **`fact_layoffs`**: `layoff_id` (PK), `company_id` (FK), `location_id` (FK), `industry_id` (FK), `total_laid_off`, `percentage_laid_off`, `layoff_date`, `layoff_year`, `layoff_month`

---

## How to Run

### Method A: Automated Python Setup & Execution
An automation script is provided to handle database creation, DDL execution, CSV loading, and query execution out-of-the-box.

1. **Pre-requisites**:
   * PostgreSQL server running locally on port `5432` with username `postgres` and password `12345678` (credentials configured in script).
   * Install dependencies: `pip install psycopg2`

2. **Run the script**:
   ```bash
   python setup_and_analyze.py
   ```
   *This will automatically drop `layoffs_db` if it exists, create a fresh database, build the tables, load the data from `project_data/` using efficient transaction blocks, and execute & print the results of all 20 analytical queries.*

### Method B: Manual Setup in pgAdmin
1. Connect to your local PostgreSQL server in **pgAdmin 4**.
2. Open the **Query Tool** (Tools -> Query Tool).
3. Open and run [create_tables.sql](file:///c:/Users/Nabeel/Desktop/SQL%20PROJECTTTT/sql/create_tables.sql) to build the database schema.
4. Import the CSV files into tables in the following exact order (right-click each table -> **Import/Export Data...** -> Import -> select CSV path, header = YES, delimiter = `,`):
   1. `dim_company` (from `project_data/dim_company.csv`)
   2. `dim_location` (from `project_data/dim_location.csv`)
   3. `dim_industry` (from `project_data/dim_industry.csv`)
   4. `fact_layoffs` (from `project_data/fact_layoffs.csv`)
5. Open and run queries from [queries.sql](file:///c:/Users/Nabeel/Desktop/SQL%20PROJECTTTT/sql/queries.sql) to perform the analysis.

---

## SQL Queries Summary (20 Analytical Tasks)
The SQL queries in [queries.sql](file:///c:/Users/Nabeel/Desktop/SQL%20PROJECTTTT/sql/queries.sql) execute analysis using aggregations, joins, string manipulations, CTEs, and subqueries:

| Task | Description | Key Insight / Result |
| :--- | :--- | :--- |
| **Q1** | First 15 company records | Verifies company records (Atlassian, SiriusXM, etc.) |
| **Q2** | Post-IPO companies with funds > $1B | Netflix ($121.9B), Meta ($26B), Uber ($24.7B) lead |
| **Q3** | Total workforce laid off | **383,659 employees** |
| **Q4** | Avg % laid off per event | **20.33%** |
| **Q5** | Unique industries | **31 industries** represented |
| **Q6** | Max single-event layoffs | **12,000** (Google, Jan 2023) |
| **Q7** | Total layoffs by year | 2020: 80,968 \| 2021: 15,623 \| 2022: 160,865 \| 2023: 125,703 |
| **Q8** | Companies by funding stage | Post-IPO (297), Unknown (285), Series B (238) |
| **Q9** | Total layoffs by industry sector | Retail, Consumer, Transportation, Finance lead |
| **Q10** | Countries with total layoffs > 1,000 | United States leads significantly, followed by India, Netherlands |
| **Q11** | Lower/Upper casing functions | Normalizes names and stage strings |
| **Q12** | Concatenation of company + stage | formats as `Company (Stage)` |
| **Q13** | First 5 characters of size category | Substrings size groupings (e.g., 'Growt' for Growth) |
| **Q14** | Position of letter 'e' in stage | String position analysis |
| **Q15** | Replace 'United States' with 'USA' | Location record cleanup |
| **Q16** | Series-stage companies filter | Identifies early-to-late venture stages (Series A-H) |
| **Q17** | Subquery on Crypto industry | Lists events specifically for Crypto-related firms |
| **Q18** | Multi-table INNER JOINs | Connects facts with company name, country, and industry |
| **Q19** | Enterprise class layoffs in 2023 | Ericsson (8,500), SAP (3,000), Wayfair (1,750) lead |
| **Q20** | CTE to find above-avg funded companies | Average funding = $570.21M; lists higher-funded firms |
