-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

# Check how many companies laid of everyone
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

# Check total_laid_off for each distinct company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

# Check total_laid_off for each distinct industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

# Check total_laid_off for each distinct country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

# Check total_laid_off for each distinct year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

# Sum of total_laid_off based off on months but logically ordered based on years

SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

# Cumulative/Progressive/Rollling Sum of total_laid_off based off on months but logically ordered based on years

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS month_total
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, month_total,
SUM(month_total) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total
;

# Check total_laid_off for each company in each year
SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `year`
ORDER BY company;

WITH company_year (company, `year`, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company
),
company_year_rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE `year` IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5
;








