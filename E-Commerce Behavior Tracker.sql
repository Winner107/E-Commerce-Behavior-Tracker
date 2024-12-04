-- user table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    join_date DATE
);

-- products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2)
);

-- user interactions table (purchases, views, etc.)
CREATE TABLE interactions (
    interaction_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    product_id INT REFERENCES products(product_id),
    interaction_type VARCHAR(50),  -- 'view', 'purchase', 'cart'
    interaction_time TIMESTAMP
);

-- Insert users
INSERT INTO users (first_name, last_name, email, join_date) VALUES
('John', 'Doe', 'john.doe@email.com', '2023-01-15'),
('Jane', 'Smith', 'jane.smith@email.com', '2023-06-01'),
('Alice', 'Johnson', 'alice.johnson@email.com', '2023-03-05'),
('Bob', 'Williams', 'bob.williams@email.com', '2023-04-12'),
('Charlie', 'Brown', 'charlie.brown@email.com', '2023-08-22'),
('David', 'Miller', 'david.miller@email.com', '2023-05-18'),
('Emma', 'Davis', 'emma.davis@email.com', '2023-02-11'),
('Frank', 'Wilson', 'frank.wilson@email.com', '2023-07-03'),
('Grace', 'Moore', 'grace.moore@email.com', '2023-09-17'),
('Helen', 'Taylor', 'helen.taylor@email.com', '2023-11-21'),
('Ivy', 'Anderson', 'ivy.anderson@email.com', '2023-01-29'),
('Jack', 'Thomas', 'jack.thomas@email.com', '2023-04-14'),
('Kate', 'Jackson', 'kate.jackson@email.com', '2023-06-27'),
('Leo', 'White', 'leo.white@email.com', '2023-10-10'),
('Mia', 'Harris', 'mia.harris@email.com', '2023-03-02'),
('Nina', 'Martin', 'nina.martin@email.com', '2023-08-18'),
('Oscar', 'Lee', 'oscar.lee@email.com', '2023-09-30'),
('Paul', 'Walker', 'paul.walker@email.com', '2023-02-22'),
('Quincy', 'Young', 'quincy.young@email.com', '2023-12-01');


-- Insert products
INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 899.99),
('Shoes', 'Apparel', 59.99),
('Coffee Maker', 'Appliances', 49.99),
('Smartphone', 'Electronics', 699.99),
('Washing Machine', 'Home Appliances', 499.99),
('T-shirt', 'Apparel', 19.99),
('Headphones', 'Electronics', 199.99),
('Microwave', 'Home Appliances', 89.99),
('Smartwatch', 'Electronics', 299.99),
('Refrigerator', 'Home Appliances', 799.99),
('Desk', 'Furniture', 129.99),
('Sofa', 'Furniture', 499.99),
('Blender', 'Appliances', 39.99),
('Smart TV', 'Electronics', 599.99),
('Table Lamp', 'Furniture', 45.99),
('Toaster', 'Appliances', 24.99),
('Waffle Maker', 'Appliances', 49.99),
('Chair', 'Furniture', 79.99),
('Air Purifier', 'Home Appliances', 149.99),
('Jacket', 'Apparel', 89.99);


-- Insert interactions (views and purchases)
INSERT INTO interactions (user_id, product_id, interaction_type, interaction_time) VALUES
(1, 1, 'view', '2023-12-01 10:15:00'),
(1, 1, 'purchase', '2023-12-01 10:30:00'),
(2, 2, 'view', '2023-12-01 11:15:00'),
(2, 2, 'purchase', '2023-12-01 11:45:00'),
(3, 3, 'view', '2023-12-02 14:00:00'),
(3, 1, 'view', '2023-12-02 14:30:00'),
(4, 4, 'view', '2023-12-05 09:45:00'),
(4, 4, 'purchase', '2023-12-05 10:00:00'),
(5, 5, 'view', '2023-12-06 15:10:00'),
(5, 5, 'view', '2023-12-06 15:15:00'),
(6, 6, 'purchase', '2023-12-07 17:20:00'),
(2, 6, 'view', '2023-12-07 17:35:00'),
(3, 5, 'view', '2023-12-07 17:40:00'),
(1, 5, 'purchase', '2023-12-08 18:05:00'),
(6, 2, 'purchase', '2023-12-09 12:30:00'),
(1, 7, 'view', '2023-12-01 12:00:00'),
(7, 7, 'purchase', '2023-12-02 13:15:00'),
(8, 8, 'view', '2023-12-03 14:00:00'),
(9, 9, 'purchase', '2023-12-04 15:05:00'),
(10, 10, 'view', '2023-12-05 16:20:00');



-- Most Popular Products (by Views)
SELECT 
    p.product_name, COUNT(i.interaction_id) AS total_views
FROM interactions i
JOIN products p ON i.product_id = p.product_id
WHERE 
    i.interaction_type = 'view'
GROUP BY 
    p.product_name
ORDER BY total_views DESC;


-- Conversion Rate for Products (Views to Purchases)
SELECT 
    p.product_name,
    COUNT(CASE WHEN i.interaction_type = 'purchase' THEN 1 END) AS total_purchases,
    COUNT(CASE WHEN i.interaction_type = 'view' THEN 1 END) AS total_views,
    (COUNT(CASE WHEN i.interaction_type = 'purchase' THEN 1 END) * 100.0 / 
     NULLIF(COUNT(CASE WHEN i.interaction_type = 'view' THEN 1 END), 0)) AS conversion_rate
FROM interactions i
JOIN 
    products p ON i.product_id = p.product_id
GROUP BY p.product_name;



-- Average Time Between Views and Purchases
SELECT 
    p.product_name, 
    AVG(EXTRACT(EPOCH FROM (purchase_time - view_time))/3600) AS avg_hours_between
FROM (
    SELECT 
        i.user_id, 
        i.product_id, 
        MAX(CASE WHEN i.interaction_type = 'view' THEN i.interaction_time END) AS view_time,
        MAX(CASE WHEN i.interaction_type = 'purchase' THEN i.interaction_time END) AS purchase_time
    FROM 
        interactions i
    GROUP BY 
        i.user_id, i.product_id
) AS product_interactions
JOIN 
    products p ON product_interactions.product_id = p.product_id
GROUP BY 
    p.product_name;
