-- ============================================
-- Global Workforce Analytics & Layoff Trend Analysis
-- CREATE TABLE Statements (PostgreSQL)
-- ============================================

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS fact_layoffs CASCADE;
DROP TABLE IF EXISTS dim_company CASCADE;
DROP TABLE IF EXISTS dim_location CASCADE;
DROP TABLE IF EXISTS dim_industry CASCADE;

-- Dimension: Company
CREATE TABLE dim_company (
    company_id           SERIAL PRIMARY KEY,
    company_name         VARCHAR(100) NOT NULL,
    stage                VARCHAR(30),
    funds_raised_millions REAL,
    company_size_category VARCHAR(15)
);

-- Dimension: Location
CREATE TABLE dim_location (
    location_id  SERIAL PRIMARY KEY,
    location     VARCHAR(80) NOT NULL,
    country      VARCHAR(60) NOT NULL
);

-- Dimension: Industry
CREATE TABLE dim_industry (
    industry_id   SERIAL PRIMARY KEY,
    industry_name VARCHAR(60) NOT NULL
);

-- Fact: Layoffs
CREATE TABLE fact_layoffs (
    layoff_id          SERIAL PRIMARY KEY,
    company_id         INTEGER REFERENCES dim_company(company_id),
    location_id        INTEGER REFERENCES dim_location(location_id),
    industry_id        INTEGER REFERENCES dim_industry(industry_id),
    total_laid_off     INTEGER,
    percentage_laid_off REAL,
    layoff_date        DATE,
    layoff_year        SMALLINT,
    layoff_month       SMALLINT
);


----------------------------------------------------------------------------------------------------------

-- ============================================
-- Global Workforce Analytics & Layoff Trend Analysis
-- 20 SQL Analytical Queries
-- Database: layoffs_db (PostgreSQL)
-- ============================================


-- ═══════════════════════════════════════════════════════════════
-- Q1: First 15 records of company details.
-- ═══════════════════════════════════════════════════════════════
SELECT company_id, company_name, stage, funds_raised_millions, company_size_category
FROM dim_company
ORDER BY company_id
LIMIT 15;


-- ═══════════════════════════════════════════════════════════════
-- Q2: Post-IPO companies with funds raised exceeding $1,000 million.
-- ═══════════════════════════════════════════════════════════════
SELECT company_id, company_name, stage, funds_raised_millions
FROM dim_company
WHERE stage = 'Post-IPO' AND funds_raised_millions > 1000
ORDER BY funds_raised_millions DESC;


-- ═══════════════════════════════════════════════════════════════
-- Q3: Total number of laid-off employees recorded.
-- ═══════════════════════════════════════════════════════════════
SELECT SUM(total_laid_off) AS total_employees_laid_off
FROM fact_layoffs;


-- ═══════════════════════════════════════════════════════════════
-- Q4: Average percentage of workforce laid off per event.
-- ═══════════════════════════════════════════════════════════════
SELECT ROUND(AVG(percentage_laid_off)::numeric, 4) AS avg_percentage_laid_off
FROM fact_layoffs;


-- ═══════════════════════════════════════════════════════════════
-- Q5: List of unique industries represented.
-- ═══════════════════════════════════════════════════════════════
SELECT DISTINCT industry_name
FROM dim_industry
ORDER BY industry_name;


-- ═══════════════════════════════════════════════════════════════
-- Q6: Maximum number of layoffs recorded in a single event.
-- ═══════════════════════════════════════════════════════════════
SELECT MAX(total_laid_off) AS max_layoffs_single_event
FROM fact_layoffs;


-- ═══════════════════════════════════════════════════════════════
-- Q7: Total number of layoffs grouped by year.
-- ═══════════════════════════════════════════════════════════════
SELECT layoff_year, SUM(total_laid_off) AS total_layoffs
FROM fact_layoffs
GROUP BY layoff_year
ORDER BY layoff_year;


-- ═══════════════════════════════════════════════════════════════
-- Q8: Number of companies in each funding stage.
-- ═══════════════════════════════════════════════════════════════
SELECT stage, COUNT(*) AS company_count
FROM dim_company
GROUP BY stage
ORDER BY company_count DESC;


-- ═══════════════════════════════════════════════════════════════
-- Q9: Total layoffs by industry sector.
-- ═══════════════════════════════════════════════════════════════
SELECT i.industry_name, SUM(f.total_laid_off) AS total_layoffs
FROM fact_layoffs f
JOIN dim_industry i ON i.industry_id = f.industry_id
GROUP BY i.industry_name
ORDER BY total_layoffs DESC;


-- ═══════════════════════════════════════════════════════════════
-- Q10: Countries with total layoffs exceeding 1,000.
-- ═══════════════════════════════════════════════════════════════
SELECT l.country, SUM(f.total_laid_off) AS total_layoffs
FROM fact_layoffs f
JOIN dim_location l ON l.location_id = f.location_id
GROUP BY l.country
HAVING SUM(f.total_laid_off) > 1000
ORDER BY total_layoffs DESC;


-- ═══════════════════════════════════════════════════════════════
-- Q11: Company names in lowercase and funding stages in uppercase.
-- ═══════════════════════════════════════════════════════════════
SELECT LOWER(company_name) AS company_lower, UPPER(stage) AS stage_upper
FROM dim_company
ORDER BY company_id
LIMIT 15;


-- ═══════════════════════════════════════════════════════════════
-- Q12: Company name and funding stage combined (e.g., 'Meta (Post-IPO)').
-- ═══════════════════════════════════════════════════════════════
SELECT CONCAT(company_name, ' (', stage, ')') AS company_with_stage
FROM dim_company
ORDER BY company_id
LIMIT 15;


-- ═══════════════════════════════════════════════════════════════
-- Q13: First 5 characters of company size categories.
-- ═══════════════════════════════════════════════════════════════
SELECT company_name, company_size_category, LEFT(company_size_category, 5) AS size_abbrev
FROM dim_company
ORDER BY company_id
LIMIT 15;


-- ═══════════════════════════════════════════════════════════════
-- Q14: Position of the letter 'e' in the company stage strings.
-- ═══════════════════════════════════════════════════════════════
SELECT company_name, stage, POSITION('e' IN stage) AS position_of_e
FROM dim_company
WHERE stage IS NOT NULL
ORDER BY company_id
LIMIT 15;


-- ═══════════════════════════════════════════════════════════════
-- Q15: Location records with 'United States' replaced by 'USA'.
-- ═══════════════════════════════════════════════════════════════
SELECT location_id, location, REPLACE(country, 'United States', 'USA') AS country_replaced
FROM dim_location
ORDER BY location_id
LIMIT 20;


-- ═══════════════════════════════════════════════════════════════
-- Q16: Companies in any 'Series' funding stage (using LIKE).
-- ═══════════════════════════════════════════════════════════════
SELECT company_id, company_name, stage, funds_raised_millions
FROM dim_company
WHERE stage LIKE 'Series%'
ORDER BY company_id
LIMIT 20;


-- ═══════════════════════════════════════════════════════════════
-- Q17: Layoff events for companies in the Crypto industry (using a subquery).
-- ═══════════════════════════════════════════════════════════════
SELECT f.layoff_id, c.company_name, f.total_laid_off, f.percentage_laid_off, f.layoff_date
FROM fact_layoffs f
JOIN dim_company c ON c.company_id = f.company_id
WHERE f.industry_id IN (
    SELECT industry_id FROM dim_industry WHERE industry_name = 'Crypto'
)
ORDER BY f.layoff_date DESC
LIMIT 20;


-- ═══════════════════════════════════════════════════════════════
-- Q18: Company name, country, industry, and total laid off for all events (INNER JOINs).
-- ═══════════════════════════════════════════════════════════════
SELECT c.company_name, l.country, i.industry_name, f.total_laid_off
FROM fact_layoffs f
INNER JOIN dim_company  c ON c.company_id  = f.company_id
INNER JOIN dim_location l ON l.location_id = f.location_id
INNER JOIN dim_industry i ON i.industry_id = f.industry_id
ORDER BY f.total_laid_off DESC NULLS LAST
LIMIT 20;


-- ═══════════════════════════════════════════════════════════════
-- Q19: Layoff details for Enterprise class companies in 2023.
-- ═══════════════════════════════════════════════════════════════
SELECT c.company_name, c.company_size_category, f.total_laid_off,
       f.percentage_laid_off, f.layoff_date
FROM fact_layoffs f
JOIN dim_company c ON c.company_id = f.company_id
WHERE c.company_size_category = 'Enterprise' AND f.layoff_year = 2023
ORDER BY f.total_laid_off DESC NULLS LAST
LIMIT 20;


-- ═══════════════════════════════════════════════════════════════
-- Q20: Companies with funding above the average funds raised (using a CTE).
-- ═══════════════════════════════════════════════════════════════
WITH avg_funds AS (
    SELECT AVG(funds_raised_millions) AS avg_funds_raised
    FROM dim_company
    WHERE funds_raised_millions IS NOT NULL
)
SELECT c.company_id, c.company_name, c.funds_raised_millions,
       ROUND(af.avg_funds_raised::numeric, 2) AS avg_funds
FROM dim_company c, avg_funds af
WHERE c.funds_raised_millions > af.avg_funds_raised
ORDER BY c.funds_raised_millions DESC
LIMIT 20;
