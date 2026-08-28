CREATE OR REPLACE VIEW PRODUCT_PERFORMANCE AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(IFF(o.status = 'COMPLETED', oi.quantity, 0)) AS units_sold,
    SUM(IFF(o.status = 'COMPLETED', oi.quantity * oi.unit_price, 0)) AS revenue
FROM CDE_ECOMMERCE.RAW.PRODUCTS AS p
LEFT JOIN CDE_ECOMMERCE.RAW.ORDER_ITEMS AS oi
    ON p.product_id = oi.product_id
LEFT JOIN CDE_ECOMMERCE.RAW.ORDERS AS o
    ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, p.category;