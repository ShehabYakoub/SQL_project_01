-- Overview about the data
SELECT *
FROM layoffs_staging;

-- Total laid offs range
SELECT MIN(total_laid_off) min_laid_offs, MAX(total_laid_off) max_laid_offs
FROM layoffs_staging;

-- Date range
SELECT MIN(date) AS [start], MAX(date) AS [end]
FROM layoffs_staging

-- Total laid offS per country
SELECT country, SUM(total_laid_off) total_laid_off
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC;

-- Total laid offS per company
SELECT company, SUM(total_laid_off) total_laid_off
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC;

-- Total laid offs per year
SELECT YEAR(date) [Year], SUM(total_laid_off) total_laid_off
FROM layoffs_staging
WHERE YEAR(date) IS NOT NULL
GROUP BY YEAR(date)
ORDER BY 1;

-- Rolling total per month
WITH rolling_sum AS
(
SELECT CONVERT(VARCHAR(7), date, 120) AS month, SUM(total_laid_off) AS tlo_per_month
FROM layoffs_staging
WHERE date IS NOT NULL
GROUP BY CONVERT(VARCHAR(7), date, 120)
)
SELECT month, tlo_per_month, SUM(tlo_per_month) OVER(ORDER BY month) AS rolling_total
FROM rolling_sum;

-- Top 5 laid offs per year
WITH laid_offs_ranking AS
(
SELECT company, YEAR(date) [Year], SUM(total_laid_off) AS total_laid_off, DENSE_RANK() OVER(PARTITION BY YEAR(date) ORDER BY SUM(total_laid_off) DESC) ranking
FROM layoffs_staging
WHERE YEAR(date) IS NOT NULL
GROUP BY company, YEAR(date)
)
SELECT *
FROM laid_offs_ranking
WHERE ranking <= 5;