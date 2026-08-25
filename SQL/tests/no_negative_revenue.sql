-- A data-quality test passes when it returns zero rows.
SELECT *
FROM DAILY_REVENUE
WHERE revenue < 0;
