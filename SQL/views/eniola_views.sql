CREATE OR REPLACE VIEW Eniola AS
SELECT
    c.customer_id,
    c.full_name,
    c.country,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS lifetime_value
FROM raw.CUSTOMERS AS c
LEFT JOIN raw.ORDERS AS o
    ON c.customer_id = o.customer_id
    AND o.status = 'COMPLETED'
LEFT JOIN raw.ORDER_ITEMS AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.full_name, c.country;
