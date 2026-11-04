SELECT customer_id FROM customer_lifetime_value
GROUP BY customer_id HAVING COUNT(*) > 1;
