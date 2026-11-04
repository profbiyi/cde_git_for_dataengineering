-- Instructor-only bootstrap. Existing rows are preserved on subsequent runs.
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id integer PRIMARY KEY,
    full_name text NOT NULL,
    country text NOT NULL
);
CREATE TABLE IF NOT EXISTS raw.products (
    product_id integer PRIMARY KEY,
    product_name text NOT NULL,
    category text NOT NULL
);
CREATE TABLE IF NOT EXISTS raw.orders (
    order_id integer PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES raw.customers,
    order_date date NOT NULL,
    status text NOT NULL CHECK (status IN ('COMPLETED', 'PENDING', 'CANCELLED'))
);
CREATE TABLE IF NOT EXISTS raw.order_items (
    order_id integer NOT NULL REFERENCES raw.orders,
    product_id integer NOT NULL REFERENCES raw.products,
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO raw.customers VALUES
    (1, 'Ada Okafor', 'Nigeria'), (2, 'Tunde Bello', 'Nigeria'),
    (3, 'Amara Mensah', 'Ghana'), (4, 'Fatima Diallo', 'Senegal')
ON CONFLICT DO NOTHING;
INSERT INTO raw.products VALUES
    (1, 'Keyboard', 'Electronics'), (2, 'Notebook', 'Stationery'),
    (3, 'Mouse', 'Electronics'), (4, 'Backpack', 'Accessories')
ON CONFLICT DO NOTHING;
INSERT INTO raw.orders VALUES
    (1, 1, '2026-01-05', 'COMPLETED'), (2, 2, '2026-01-05', 'COMPLETED'),
    (3, 1, '2026-01-06', 'COMPLETED'), (4, 3, '2026-01-06', 'CANCELLED'),
    (5, 2, '2026-01-07', 'PENDING')
ON CONFLICT DO NOTHING;
INSERT INTO raw.order_items VALUES
    (1, 1, 1, 50), (1, 2, 2, 5), (2, 3, 2, 20),
    (3, 2, 3, 5), (4, 1, 1, 50), (5, 3, 1, 20)
ON CONFLICT DO NOTHING;
