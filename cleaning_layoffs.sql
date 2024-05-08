-- Overview about the data
SELECT *
FROM layoffs;

-- Steps for cleaning the data
-- 1- Removing Duplicates
-- 2- Standardiza Data (Fixing spelling problems)
-- 3- Dealing with null or Blank Values
-- 4- Removing any unnecessary columns or rows

-- Creating another copy of the table to work on to have another one if anything goes wrong
--SELECT * 
--INTO layoffs_staging
--FROM layoffs;

-- Overview about the new data
SELECT *
FROM layoffs_staging;

-- 1- Removing Duplicates
WITH duplicates AS
(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions ORDER BY(SELECT NULL)) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicates
WHERE row_num > 1;

-- 2- Standardiza Data (Fixing issues)
-- Fixing spaces in 'company'
UPDATE layoffs_staging
SET company = TRIM(company);

-- Fixing names in 'industry'
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Fixing names in 'country'
UPDATE layoffs_staging
SET country = 'United States'
WHERE country = 'United States.';

-- Modifying 'date' column
ALTER TABLE layoffs_staging
ALTER COLUMN date DATE;

-- 3- Dealing with null or Blank Values
SELECT *
FROM layoffs_staging
WHERE industry IS NULL;

SELECT t1.industry, t2.industry
FROM layoffs_staging AS t1
INNER JOIN layoffs_staging AS t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging AS t1
INNER JOIN layoffs_staging AS t2 ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4- Removing Any Rows or Columns
DELETE
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL

ALTER TABLE layoffs_staging
ALTER COLUMN percentage_laid_off FLOAT;