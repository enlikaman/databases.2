-- Database Constraints - Laboratory Work
-- Student Name: [Your Name]
-- Student ID: [Your Student ID]
-- PostgreSQL SQL file containing CREATE TABLEs, INSERTs (successful and failed attempts commented out), and test queries.

-- ==========================
-- Part 1: CHECK Constraints
-- ==========================

-- Task 1.1: employees table with CHECK constraints on age and salary
CREATE TABLE IF NOT EXISTS employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2: products_catalog with named CHECK constraint valid_discount
CREATE TABLE IF NOT EXISTS products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- Task 1.3: bookings with multi-column constraints
CREATE TABLE IF NOT EXISTS bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

-- Task 1.4: Testing CHECK constraints
-- Valid inserts for employees (2 rows)
INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES
(1, 'Aida', 'Sultanova', 25, 35000.00),
(2, 'Bulat', 'Zhanibek', 45, 55000.50);

-- Invalid inserts (will fail) - commented out
-- 1) age too low
-- INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES (3, 'Invalid', 'Young', 16, 20000);
-- Violated constraint: CHECK (age BETWEEN 18 AND 65) -> age = 16

-- 2) salary non-positive
-- INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES (4, 'Invalid', 'NoPay', 30, 0);
-- Violated constraint: CHECK (salary > 0) -> salary = 0

-- Valid inserts for products_catalog
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES
(101, 'Smart Lamp', 120.00, 90.00),
(102, 'Bluetooth Speaker', 80.00, 60.00);

-- Invalid inserts (commented out)
-- 1) discount >= regular
-- INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES (103, 'Bad Deal', 50.00, 50.00);
-- Violated: valid_discount (discount_price < regular_price) -> equal prices

-- 2) regular_price <= 0
-- INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES (104, 'Freebie', 0, 0);
-- Violated: valid_discount (regular_price > 0)

-- Valid inserts for bookings
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests) VALUES
(1001, '2025-07-01', '2025-07-05', 2),
(1002, '2025-08-10', '2025-08-12', 4);

-- Invalid inserts (commented out)
-- 1) num_guests out of range
-- INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests) VALUES (1003, '2025-09-01', '2025-09-03', 0);
-- Violated: CHECK (num_guests BETWEEN 1 AND 10)

-- 2) check_out_date before check_in_date
-- INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests) VALUES (1004, '2025-10-05', '2025-10-03', 2);
-- Violated: CHECK (check_out_date > check_in_date)


-- ==========================
-- Part 2: NOT NULL Constraints
-- ==========================

-- Task 2.1: customers table
CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- Task 2.2: inventory table with NOT NULL and CHECK
CREATE TABLE IF NOT EXISTS inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL
-- Valid inserts
INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
(1, 'aida@mail.com', '77001234567', '2024-03-10'),
(2, 'bulat@mail.com', NULL, '2025-01-15'); -- phone can be NULL

-- Invalid inserts (commented out)
-- 1) NULL customer_id
-- INSERT INTO customers (customer_id, email, phone, registration_date) VALUES (NULL, 'noid@mail.com', '77000000000', '2025-02-01');
-- Violated: customer_id NOT NULL

-- 2) NULL email
-- INSERT INTO customers (customer_id, email, phone, registration_date) VALUES (3, NULL, '77001112233', '2025-02-05');
-- Violated: email NOT NULL

-- Valid inserts for inventory
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated) VALUES
(10, 'USB-C Cable', 100, 5.50, now()),
(11, 'Webcam', 25, 45.00, now());

-- Invalid inserts (commented out)
-- 1) negative quantity
-- INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated) VALUES (12, 'Faulty', -5, 10.00, now());
-- Violated: CHECK (quantity >= 0)

-- 2) NULL unit_price
-- INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated) VALUES (13, 'NoPrice', 5, NULL, now());
-- Violated: unit_price NOT NULL


-- ==========================
-- Part 3: UNIQUE Constraints
-- ==========================

-- Task 3.1: users table with UNIQUE on username and email
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

-- Task 3.2: course_enrollments with multi-column UNIQUE
CREATE TABLE IF NOT EXISTS course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT uq_student_course_semester UNIQUE (student_id, course_code, semester)
);

-- Task 3.3: Named UNIQUE constraints on users
ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE (username),
    ADD CONSTRAINT unique_email UNIQUE (email);
-- Note: If username/email already had anonymous UNIQUE, these ALTERs may conflict; this ensures names are set.

-- Testing UNIQUE: valid inserts
INSERT INTO users (user_id, username, email, created_at) VALUES
(1, 'aida25', 'aida@mail.com', now()),
(2, 'bulat45', 'bulat@mail.com', now());

-- Invalid inserts (commented out)
-- 1) duplicate username
-- INSERT INTO users (user_id, username, email, created_at) VALUES (3, 'aida25', 'aida2@mail.com', now());
-- Violated: unique_username on username

-- 2) duplicate email
-- INSERT INTO users (user_id, username, email, created_at) VALUES (4, 'newuser', 'aida@mail.com', now());
-- Violated: unique_email on email


-- ==========================
-- Part 4: PRIMARY KEY Constraints
-- ==========================

-- Task 4.1: departments with single-column PRIMARY KEY
CREATE TABLE IF NOT EXISTS departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

-- Insert departments (3 rows)
INSERT INTO departments (dept_id, dept_name, location) VALUES
(1, 'Human Resources', 'Building A'),
(2, 'Research', 'Building B'),
(3, 'Sales', 'Building C');

-- Invalid attempts (commented out)
-- 1) duplicate dept_id
-- INSERT INTO departments (dept_id, dept_name, location) VALUES (1, 'Duplicate', 'Nowhere');
-- Violated: primary key uniqueness on dept_id

-- 2) NULL dept_id
-- INSERT INTO departments (dept_id, dept_name, location) VALUES (NULL, 'NoId', 'Nowhere');
-- Violated: PRIMARY KEY cannot be NULL

-- Task 4.2: student_courses with composite PRIMARY KEY
CREATE TABLE IF NOT EXISTS student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- Insert valid composite PK rows
INSERT INTO student_courses (student_id, course_id, enrollment_date, grade) VALUES
(100, 200, '2025-02-01', 'A'),
(101, 200, '2025-02-02', 'B');

-- Task 4.3: Comparison Exercise (documented as SQL comment)
-- 1. Difference between UNIQUE and PRIMARY KEY:
--    - PRIMARY KEY enforces uniqueness and NOT NULL on the column(s). A table can have only one PRIMARY KEY.
--    - UNIQUE enforces uniqueness but allows NULLs (unless explicitly declared NOT NULL). A table can have multiple UNIQUE constraints.
-- 2. Single-column vs composite PRIMARY KEY:
--    - Use single-column PK when a single attribute uniquely identifies a row (e.g., auto-increment id).
--    - Use composite PK when uniqueness requires the combination of multiple columns (e.g., student_id + course_id in enrollment table).
-- 3. Why only one PRIMARY KEY but multiple UNIQUE constraints:
--    - By definition a table has one primary key (the main identifier). UNIQUE constraints are additional uniqueness rules for other columns.


-- ==========================
-- Part 5: FOREIGN KEY Constraints
-- ==========================

-- Task 5.1: employees_dept referencing departments
CREATE TABLE IF NOT EXISTS employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

-- Insert valid employee referencing existing dept_id
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES
(5001, 'Dana Karim', 1, '2024-05-01'),
(5002, 'Erkin Nur', 2, '2025-01-10');

-- Invalid insert (commented out)
-- 1) non-existent dept_id
-- INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES (5003, 'Ghost', 99, '2025-03-03');
-- Violated: foreign key constraint - dept_id 99 does not exist in departments

-- Task 5.2: Library system with multiple foreign keys
CREATE TABLE IF NOT EXISTS authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE IF NOT EXISTS publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE IF NOT EXISTS books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

-- Sample inserts for authors and publishers
INSERT INTO authors (author_id, author_name, country) VALUES
(1, 'Orhan Pamuk', 'Turkey'),
(2, 'Gabriel Garcia Marquez', 'Colombia'),
(3, 'Chingiz Aitmatov', 'Kyrgyzstan');

INSERT INTO publishers (publisher_id, publisher_name, city) VALUES
(10, 'BigBooks', 'Almaty'),
(11, 'WorldPub', 'Istanbul');

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES
(10001, 'Book One', 1, 10, 2001, 'ISBN-0001'),
(10002, 'Book Two', 2, 11, 1985, 'ISBN-0002');

-- Task 5.3: ON DELETE behaviors
CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

-- Sample data for categories/products/orders/order_items
INSERT INTO categories (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Books');

INSERT INTO products_fk (product_id, product_name, category_id) VALUES
(2001, 'Smartphone X', 1),
(2002, 'Novel Y', 2);

INSERT INTO orders (order_id, order_date) VALUES
(9001, '2025-06-10'),
(9002, '2025-06-12');

INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES
(1, 9001, 2001, 1),
(2, 9001, 2002, 2),
(3, 9002, 2002, 1);

-- Tests for ON DELETE behaviors (commented instructions):
-- 1) Try to delete a category that has products (should fail due to RESTRICT)
-- DELETE FROM categories WHERE category_id = 1; -- will fail because products_fk row references category_id=1 and ON DELETE RESTRICT

-- 2) Delete an order and observe CASCADE on order_items
-- DELETE FROM orders WHERE order_id = 9001; -- this will delete order_id=9001; matching rows in order_items (item_id 1 and 2) will be automatically deleted due to ON DELETE CASCADE

-- Document what happens (as comments):
-- - Deleting category with products: RESTRICT prevents deletion because dependent rows exist in products_fk.
-- - Deleting order: CASCADE will remove related order_items automatically.


-- ==========================
-- Part 6: Practical Application - E-commerce
-- ==========================

-- Task 6.1: E-commerce Database Design
-- customers, products, orders, order_details with constraints

CREATE TABLE IF NOT EXISTS ecustomers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS eproducts (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE IF NOT EXISTS eorders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES ecustomers(customer_id) ON DELETE SET NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE IF NOT EXISTS order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES eorders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES eproducts(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- Insert at least 5 sample records per table
-- ecustomers (5 rows)
INSERT INTO ecustomers (customer_id, name, email, phone, registration_date) VALUES
(1, 'Aida Sultanova', 'aida.s@example.com', '77001234567', '2024-01-10'),
(2, 'Bulat Zhanibek', 'bulat.z@example.com', '77007654321', '2024-02-20'),
(3, 'Dana Karim', 'dana.k@example.com', NULL, '2025-03-05'),
(4, 'Erkin Nur', 'erkin.n@example.com', '77009998877', '2025-04-11'),
(5, 'Gulnar Ab', 'gulnar.a@example.com', NULL, '2025-05-22');

-- eproducts (5 rows)
INSERT INTO eproducts (product_id, name, description, price, stock_quantity) VALUES
(301, 'Wireless Mouse', 'Ergonomic wireless mouse', 15.99, 120),
(302, 'Mechanical Keyboard', 'RGB mechanical keyboard', 89.50, 40),
(303, '27" Monitor', 'QHD monitor', 199.00, 15),
(304, 'USB Hub', '4-port USB 3.0 hub', 12.00, 200),
(305, 'Laptop Stand', 'Aluminum laptop stand', 29.99, 60);

-- eorders (5 rows)
INSERT INTO eorders (order_id, customer_id, order_date, total_amount, status) VALUES
(7001, 1, '2025-06-01', 45.98, 'pending'),
(7002, 2, '2025-06-02', 119.50, 'processing'),
(7003, 3, '2025-06-03', 199.00, 'shipped'),
(7004, 4, '2025-06-04', 29.99, 'delivered'),
(7005, 5, '2025-06-05', 149.49, 'cancelled');

-- order_details (5 rows)
INSERT INTO order_details (order_detail_id, order_id, product_id, quantity, unit_price) VALUES
(90001, 7001, 301, 2, 15.99),
(90002, 7002, 302, 1, 89.50),
(90003, 7003, 303, 1, 199.00),
(90004, 7004, 305, 1, 29.99),
(90005, 7005, 304, 5, 12.00);

-- Test queries demonstrating constraints
-- 1) UNIQUE email test (commented out): duplicate email should fail
-- INSERT INTO ecustomers (customer_id, name, email, phone, registration_date) VALUES (6, 'Clone', 'aida.s@example.com', NULL, '2025-07-01');
-- Violated: UNIQUE constraint on email

-- 2) CHECK price non-negative (commented out)
-- INSERT INTO eproducts (product_id, name, description, price, stock_quantity) VALUES (306, 'BadPrice', 'Negative price', -5.00, 10);
-- Violated: CHECK (price >= 0)

-- 3) CHECK stock_quantity non-negative (commented out)
-- INSERT INTO eproducts (product_id, name, description, price, stock_quantity) VALUES (307, 'BadStock', 'Negative stock', 10.00, -2);
-- Violated: CHECK (stock_quantity >= 0)

-- 4) Order status allowed values (commented out)
-- INSERT INTO eorders (order_id, customer_id, order_date, total_amount, status) VALUES (7006, 1, '2025-07-01', 10.00, 'unknown');
-- Violated: CHECK (status IN (...))

-- 5) order_details quantity positive (commented out)
-- INSERT INTO order_details (order_detail_id, order_id, product_id, quantity, unit_price) VALUES (90006, 7001, 301, 0, 15.99);
-- Violated: CHECK (quantity > 0)

-- 6) ON DELETE behavior tests (commented instructions):
-- - Deleting an eorder should delete order_details rows with that order_id due to ON DELETE CASCADE.
-- - Deleting a customer: ecustomers referenced by eorders uses ON DELETE SET NULL, so customer_id in eorders becomes NULL (preserves order history).


-- ==========================
-- Submission notes
-- ==========================
-- This file contains:
-- 1) All CREATE TABLE statements with comments
-- 2) INSERT statements (successful and failed attempts commented out)
-- 3) Comments explaining what each constraint does
-- 4) Test queries documented as SQL comments
-- 5) Student Name and Student ID at the top (replace placeholders)

-- End of file
