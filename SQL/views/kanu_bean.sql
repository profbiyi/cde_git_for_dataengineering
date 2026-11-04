CREATE OR REPLACE VIEW KANU_BEAN AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(CASE WHEN o.status = 'COMPLETED' THEN oi.quantity ELSE 0 END) AS units_sold,
    SUM(CASE WHEN o.status = 'COMPLETED' THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue
FROM raw.PRODUCTS AS p
LEFT JOIN raw.ORDER_ITEMS AS oi
    ON p.product_id = oi.product_id
LEFT JOIN raw.ORDERS AS o
    ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, p.category;
