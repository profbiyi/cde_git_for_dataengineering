SELECT customer_id FROM raw.customers
EXCEPT
SELECT customer_id FROM customer_lifetime_value;
