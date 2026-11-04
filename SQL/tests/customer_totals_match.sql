WITH expected AS (
    SELECT c.customer_id, COUNT(DISTINCT o.order_id) AS completed_orders,
           COALESCE(SUM(i.quantity * i.unit_price), 0) AS lifetime_value
    FROM raw.customers c
    LEFT JOIN raw.orders o ON o.customer_id = c.customer_id AND o.status = 'COMPLETED'
    LEFT JOIN raw.order_items i ON i.order_id = o.order_id
    GROUP BY c.customer_id
)
SELECT customer_id, completed_orders, lifetime_value FROM expected
EXCEPT
SELECT customer_id, completed_orders, lifetime_value FROM customer_lifetime_value;
