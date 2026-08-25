-- A data-quality test passes when it returns zero rows.
SELECT *
FROM CUSTOMER_LIFETIME_VALUE
WHERE customer_id IS NULL;
