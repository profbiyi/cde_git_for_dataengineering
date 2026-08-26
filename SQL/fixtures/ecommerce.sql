CREATE TABLE CDE_ECOMMERCE.RAW.CUSTOMERS (
    customer_id INTEGER PRIMARY KEY,
    full_name VARCHAR NOT NULL,
    country VARCHAR NOT NULL
);

CREATE TABLE CDE_ECOMMERCE.RAW.PRODUCTS (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR NOT NULL,
    category VARCHAR NOT NULL
);

CREATE TABLE CDE_ECOMMERCE.RAW.ORDERS (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR NOT NULL
);

CREATE TABLE CDE_ECOMMERCE.RAW.ORDER_ITEMS (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL
);

INSERT INTO CDE_ECOMMERCE.RAW.CUSTOMERS VALUES
    (1, 'Ada Okafor', 'Nigeria'),
    (2, 'Kwame Mensah', 'Ghana'),
    (3, 'Amina Diallo', 'Senegal'),
    (4, 'Lerato Mokoena', 'South Africa'),
    (5, 'David Mwangi', 'Kenya');

INSERT INTO CDE_ECOMMERCE.RAW.PRODUCTS VALUES
    (101, 'Wireless Headphones', 'Electronics'),
    (102, 'Mechanical Keyboard', 'Electronics'),
    (103, 'Laptop Stand', 'Office'),
    (104, 'Data Engineering Handbook', 'Books');

INSERT INTO CDE_ECOMMERCE.RAW.ORDERS VALUES
    (1001, 1, DATE '2026-08-01', 'COMPLETED'),
    (1002, 2, DATE '2026-08-01', 'COMPLETED'),
    (1003, 1, DATE '2026-08-02', 'CANCELLED'),
    (1004, 3, DATE '2026-08-03', 'COMPLETED'),
    (1005, 4, DATE '2026-08-03', 'PENDING'),
    (1006, 5, DATE '2026-08-04', 'COMPLETED');

INSERT INTO CDE_ECOMMERCE.RAW.ORDER_ITEMS VALUES
    (1001, 101, 1, 89.99),
    (1001, 103, 1, 39.50),
    (1002, 102, 2, 75.00),
    (1003, 104, 1, 45.00),
    (1004, 103, 2, 39.50),
    (1004, 104, 1, 45.00),
    (1005, 101, 1, 89.99),
    (1006, 104, 3, 45.00);
