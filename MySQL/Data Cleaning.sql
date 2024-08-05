-- Data Cleaning


SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove any Columns


-- 1. Remove Duplicates

# Create a staging database by copying the structure of the raw database
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

# Copy all the data of the original database into the staging database
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

# Assign a row number to selected columns to identify unique and duplicate rows

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

# Confirm a duplicate
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

# Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- 2. Standardizing Data

SELECT company, TRIM(company)
FROM layoffs_staging2;

# Trimming company names
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

# Standardize all Crypto related industry names (i.e. Crypto, Crypto Currency, CryptoCurrency) to 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# Confirm upadte
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

# Standardizing country names
SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

# Remove any trailing full stops from the country name
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

# Confirm update
SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

# Format the text in the date column to look like the default date format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

# Confirm update
SELECT `date`
FROM layoffs_staging2;

# Convert the datatype of the date column from text to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. Null Values or Blank Values

# Handling records with null or blank values under the industry column

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

# Check all null values of the industry column of a company with coresponding company-based records with a non null value under the industry column

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry is NOT NULL;

# Standardize all blank an null values to all be null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

# Update all null values of the industry column of a company with the value of the industry cloumn of another record that has a non null value
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry is NOT NULL; 


-- 4. Remove any unnecessary Columns or/and rows

# Retrieve records where the total_laid_off and percentage_laid_off columns has null values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Delete all records where the total_laid_off and percentage_laid_off columns has null values
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Drop the row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;










