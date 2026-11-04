CREATE OR REPLACE VIEW DAILY_REVENUE AS
SELECT
    o.order_date,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM raw.ORDERS AS o
JOIN raw.ORDER_ITEMS AS oi
    ON o.order_id = oi.order_id
WHERE o.status = 'COMPLETED'
GROUP BY o.order_date;
