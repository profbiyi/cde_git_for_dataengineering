-- Also fails when daily_revenue is empty despite completed source orders.
SELECT 1 AS revenue_mismatch
WHERE COALESCE((SELECT SUM(revenue) FROM daily_revenue), 0)
    <> COALESCE((SELECT SUM(i.quantity * i.unit_price)
                 FROM raw.orders o JOIN raw.order_items i USING (order_id)
                 WHERE o.status = 'COMPLETED'), 0);
