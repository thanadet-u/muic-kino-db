
-- ================================================
-- SQL Functions to Insert Core Entities
-- Schema: Bookstore / Retail System
-- Author: ChatGPT
-- ================================================

-- =================================================
-- 1. Add a New Customer
-- Inserts into contacts, customers, and customer_addresses
-- =================================================
CREATE OR REPLACE FUNCTION add_customer(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_street TEXT,
    p_city VARCHAR,
    p_state VARCHAR,
    p_postal_code VARCHAR,
    p_country VARCHAR,
    p_password_hash VARCHAR DEFAULT NULL,
    p_address_type VARCHAR DEFAULT 'shipping',
    p_is_default BOOLEAN DEFAULT TRUE
)
RETURNS INTEGER AS $$
DECLARE
v_contact_id INTEGER;
    v_customer_id INTEGER;
BEGIN
    -- ========== Input Validation ==========
    IF p_email IS NULL OR NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email address';
END IF;

    IF p_phone IS NULL OR length(p_phone) < 6 THEN
        RAISE EXCEPTION 'Invalid phone number';
END IF;

    IF p_first_name IS NULL OR trim(p_first_name) = '' THEN
        RAISE EXCEPTION 'First name cannot be empty';
END IF;

    IF p_last_name IS NULL OR trim(p_last_name) = '' THEN
        RAISE EXCEPTION 'Last name cannot be empty';
END IF;

    IF p_address_type IS NULL OR p_address_type NOT IN ('shipping', 'billing') THEN
        RAISE EXCEPTION 'Invalid address type: %', p_address_type;
END IF;

    -- ========== Main Logic ==========

    -- Insert into contacts
INSERT INTO contacts (email, phone)
VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

-- Insert into customers
INSERT INTO customers (first_name, last_name, contact_id, password_hash)
VALUES (p_first_name, p_last_name, v_contact_id, p_password_hash)
    RETURNING id INTO v_customer_id;

-- Insert customer address
INSERT INTO customer_addresses (
    customer_id, street, city, state, postal_code, country, address_type, is_default
)
VALUES (
           v_customer_id, p_street, p_city, p_state, p_postal_code, p_country, p_address_type, p_is_default
       );

RETURN v_customer_id;
END;
$$ LANGUAGE plpgsql;


-- =================================================
-- 2. Add a New Store
-- Inserts into contacts, stores, and store_addresses
-- =================================================
CREATE OR REPLACE FUNCTION add_store(
    p_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_street TEXT,
    p_city VARCHAR,
    p_state VARCHAR,
    p_postal_code VARCHAR,
    p_country VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
v_contact_id INTEGER;
    v_store_id INTEGER;
BEGIN
    -- ========= Input Validation =========
    IF p_name IS NULL OR trim(p_name) = '' THEN
        RAISE EXCEPTION 'Store name cannot be empty';
END IF;

    IF p_email IS NULL OR NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email address';
END IF;

    IF p_phone IS NULL OR length(p_phone) < 6 THEN
        RAISE EXCEPTION 'Invalid phone number';
END IF;

    IF p_street IS NULL OR trim(p_street) = '' THEN
        RAISE EXCEPTION 'Street cannot be empty';
END IF;

    IF p_city IS NULL OR trim(p_city) = '' THEN
        RAISE EXCEPTION 'City cannot be empty';
END IF;

    IF p_state IS NULL OR trim(p_state) = '' THEN
        RAISE EXCEPTION 'State cannot be empty';
END IF;

    IF p_postal_code IS NULL OR trim(p_postal_code) = '' THEN
        RAISE EXCEPTION 'Postal code cannot be empty';
END IF;

    IF p_country IS NULL OR trim(p_country) = '' THEN
        RAISE EXCEPTION 'Country cannot be empty';
END IF;

    -- ========= Main Logic ==========

    -- Insert into contacts
INSERT INTO contacts (email, phone)
VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

-- Insert into stores
INSERT INTO stores (name, contact_id)
VALUES (p_name, v_contact_id)
    RETURNING id INTO v_store_id;

-- Insert store address
INSERT INTO store_addresses (
    store_id, street, city, state, postal_code, country
)
VALUES (
           v_store_id, p_street, p_city, p_state, p_postal_code, p_country
       );

RETURN v_store_id;
END;
$$ LANGUAGE plpgsql;


-- =================================================
-- 3. Add a New Publisher
-- Inserts into contacts and publishers
-- =================================================
CREATE OR REPLACE FUNCTION add_publisher(
    p_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
v_contact_id INTEGER;
    v_publisher_id INTEGER;
BEGIN
    -- ========= Input Validation =========
    IF p_name IS NULL OR trim(p_name) = '' THEN
        RAISE EXCEPTION 'Publisher name cannot be empty';
END IF;

    IF p_email IS NULL OR NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email address';
END IF;

    IF p_phone IS NULL OR length(p_phone) < 6 THEN
        RAISE EXCEPTION 'Invalid phone number';
END IF;

    -- ========= Main Logic ==========

    -- Insert into contacts
INSERT INTO contacts (email, phone)
VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

-- Insert into publishers
INSERT INTO publishers (name, contact_id)
VALUES (p_name, v_contact_id)
    RETURNING id INTO v_publisher_id;

RETURN v_publisher_id;
END;
$$ LANGUAGE plpgsql;


-- =================================================
-- 4. Add a New Author
-- Simple insert into authors table
-- =================================================
CREATE OR REPLACE FUNCTION add_author(
    p_first_name VARCHAR,
    p_last_name VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
v_author_id INTEGER;
BEGIN
    -- ========= Input Validation =========
    IF p_first_name IS NULL OR trim(p_first_name) = '' THEN
        RAISE EXCEPTION 'Author first name cannot be empty';
END IF;

    IF p_last_name IS NULL OR trim(p_last_name) = '' THEN
        RAISE EXCEPTION 'Author last name cannot be empty';
END IF;

    -- ========= Main Logic ==========

INSERT INTO authors (first_name, last_name)
VALUES (p_first_name, p_last_name)
    RETURNING id INTO v_author_id;

RETURN v_author_id;
END;
$$ LANGUAGE plpgsql;


-- =================================================
-- 5. Add a New Author
-- Simple insert into authors table
-- =================================================



-- ===========================================
-- INSERT FUNCTIONS FOR MAIN ENTITIES
-- ===========================================

-- Add a new customer with contact and address
CREATE OR REPLACE FUNCTION add_customer(
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT,
    p_phone TEXT,
    p_street TEXT,
    p_city TEXT,
    p_state TEXT,
    p_postal_code TEXT,
    p_country TEXT,
    p_address_type TEXT DEFAULT 'shipping',
    p_is_default BOOLEAN DEFAULT true
) RETURNS VOID AS $$
DECLARE
    v_contact_id INTEGER;
    v_customer_id INTEGER;
BEGIN
    INSERT INTO contacts (email, phone)
    VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

    INSERT INTO customers (first_name, last_name, contact_id)
    VALUES (p_first_name, p_last_name, v_contact_id)
    RETURNING id INTO v_customer_id;

    INSERT INTO customer_addresses (
        customer_id, street, city, state, postal_code, country, address_type, is_default
    ) VALUES (
                 v_customer_id, p_street, p_city, p_state, p_postal_code, p_country, p_address_type, p_is_default
             );
END;
$$ LANGUAGE plpgsql;

-- Add a new store with contact and address
CREATE OR REPLACE FUNCTION add_store(
    p_name TEXT,
    p_email TEXT,
    p_phone TEXT,
    p_street TEXT,
    p_city TEXT,
    p_state TEXT,
    p_postal_code TEXT,
    p_country TEXT
) RETURNS VOID AS $$
DECLARE
v_contact_id INTEGER;
    v_store_id INTEGER;
BEGIN
    -- Input Validation
    IF p_name IS NULL OR trim(p_name) = '' THEN
        RAISE EXCEPTION 'Store name cannot be empty';
END IF;

    IF p_email IS NULL OR NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email address';
END IF;

    IF p_phone IS NULL OR length(p_phone) < 6 THEN
        RAISE EXCEPTION 'Invalid phone number';
END IF;

    -- Insert contact
INSERT INTO contacts (email, phone)
VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

-- Insert store
INSERT INTO stores (name, contact_id)
VALUES (p_name, v_contact_id)
    RETURNING id INTO v_store_id;

-- Insert address
INSERT INTO store_addresses (
    store_id, street, city, state, postal_code, country
) VALUES (
             v_store_id, p_street, p_city, p_state, p_postal_code, p_country
         );
END;
$$ LANGUAGE plpgsql;






-- 3. Add a publisher with contact
CREATE OR REPLACE FUNCTION add_publisher(
    p_name TEXT,
    p_email TEXT,
    p_phone TEXT
) RETURNS VOID AS $$
DECLARE
v_contact_id INTEGER;
BEGIN
    -- Input Validation
    IF p_name IS NULL OR trim(p_name) = '' THEN
        RAISE EXCEPTION 'Publisher name cannot be empty';
END IF;

    IF p_email IS NULL OR NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email address';
END IF;

    IF p_phone IS NULL OR length(p_phone) < 6 THEN
        RAISE EXCEPTION 'Invalid phone number';
END IF;

    -- Insert contact
INSERT INTO contacts (email, phone)
VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

-- Insert publisher
INSERT INTO publishers (name, contact_id)
VALUES (p_name, v_contact_id);
END;
$$ LANGUAGE plpgsql;


-- ===========================================
-- CORE FUNCTIONALITY FUNCTIONS
-- ===========================================





-- Create Order From Shopping Cart

CREATE OR REPLACE FUNCTION create_order_from_cart(p_customer_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
v_order_id INTEGER;
    v_cart_item RECORD;
    v_total NUMERIC(10,2) := 0;
    v_cart_empty BOOLEAN;
BEGIN
    -- Check if customer exists
    IF NOT EXISTS (
        SELECT 1 FROM customers WHERE id = p_customer_id
    ) THEN
        RAISE EXCEPTION 'Customer with ID % does not exist', p_customer_id;
END IF;

    -- Check if cart has items
SELECT NOT EXISTS (
    SELECT 1 FROM shopping_cart_items WHERE customer_id = p_customer_id
) INTO v_cart_empty;

IF v_cart_empty THEN
        RAISE EXCEPTION 'Shopping cart is empty for customer ID %', p_customer_id;
END IF;

    -- Create a new order (store_id is NULL for online)
INSERT INTO orders(customer_id, store_id, payment_method, total_price)
VALUES (p_customer_id, NULL, 'pending', 0)
    RETURNING id INTO v_order_id;

-- Loop over cart items
FOR v_cart_item IN
SELECT sci.*, p.base_price
FROM shopping_cart_items sci
         JOIN products p ON p.id = sci.product_id
WHERE sci.customer_id = p_customer_id
    LOOP
-- Insert into order_details
INSERT INTO order_details(order_id, product_id, quantity, unit_price)
VALUES (
    v_order_id,
    v_cart_item.product_id,
    v_cart_item.quantity,
    v_cart_item.base_price
    );

-- Update total
v_total := v_total + (v_cart_item.quantity * v_cart_item.base_price);
END LOOP;

    -- Update order total
UPDATE orders
SET total_price = v_total
WHERE id = v_order_id;

-- Clear shopping cart
DELETE FROM shopping_cart_items
WHERE customer_id = p_customer_id;

RETURN v_order_id;
END;






-- Add Product

CREATE OR REPLACE FUNCTION add_book_product(
    p_sku VARCHAR,
    p_name VARCHAR,
    p_description TEXT,
    p_base_price NUMERIC,
    p_brand_id INTEGER,
    p_isbn CHAR(13),
    p_author_id INTEGER,
    p_publisher_id INTEGER,
    p_pub_date DATE,
    p_language VARCHAR,
    p_sub_category_id INTEGER
)
RETURNS VOID AS $$
DECLARE
new_product_id INTEGER;
BEGIN
    -- Validate base price
    IF p_base_price <= 0 THEN
        RAISE EXCEPTION 'Base price must be positive';
END IF;

    -- Validate ISBN format (basic check: 13 digits)
    IF p_isbn IS NULL OR p_isbn !~ '^\d{13}$' THEN
        RAISE EXCEPTION 'Invalid ISBN: must be 13 numeric digits';
END IF;

    -- Check SKU uniqueness
    IF EXISTS (SELECT 1 FROM products WHERE sku = p_sku) THEN
        RAISE EXCEPTION 'SKU % already exists', p_sku;
END IF;

    -- Check foreign key existence
    IF NOT EXISTS (SELECT 1 FROM brands WHERE id = p_brand_id) THEN
        RAISE EXCEPTION 'Brand with ID % does not exist', p_brand_id;
END IF;

    IF NOT EXISTS (SELECT 1 FROM authors WHERE id = p_author_id) THEN
        RAISE EXCEPTION 'Author with ID % does not exist', p_author_id;
END IF;

    IF NOT EXISTS (SELECT 1 FROM publishers WHERE id = p_publisher_id) THEN
        RAISE EXCEPTION 'Publisher with ID % does not exist', p_publisher_id;
END IF;

    IF NOT EXISTS (SELECT 1 FROM sub_categories WHERE id = p_sub_category_id) THEN
        RAISE EXCEPTION 'Sub-category with ID % does not exist', p_sub_category_id;
END IF;

    -- Insert into products
INSERT INTO products (sku, name, description, product_type, base_price, brand_id)
VALUES (p_sku, p_name, p_description, 'book', p_base_price, p_brand_id)
    RETURNING id INTO new_product_id;

-- Insert into book_products
INSERT INTO book_products (
    product_id, isbn, author_id, publisher_id, publication_date, sub_category_id, language
)
VALUES (
           new_product_id, p_isbn, p_author_id, p_publisher_id, p_pub_date, p_sub_category_id, p_language
       );
END;
$$ LANGUAGE plpgsql;





-- Add Non Book Product

CREATE OR REPLACE FUNCTION add_non_book_product(
    p_sku VARCHAR,
    p_name VARCHAR,
    p_description TEXT,
    p_base_price NUMERIC,
    p_brand_id INTEGER,
    p_item_type VARCHAR,
    p_specifications JSONB
)
RETURNS VOID AS $$
DECLARE
new_product_id INTEGER;
BEGIN
    -- Validate SKU uniqueness
    IF EXISTS (SELECT 1 FROM products WHERE sku = p_sku) THEN
        RAISE EXCEPTION 'SKU % already exists', p_sku;
END IF;

    -- Validate base price
    IF p_base_price IS NULL OR p_base_price <= 0 THEN
        RAISE EXCEPTION 'Base price must be a positive number';
END IF;

    -- Validate brand existence
    IF NOT EXISTS (SELECT 1 FROM brands WHERE id = p_brand_id) THEN
        RAISE EXCEPTION 'Brand with ID % does not exist', p_brand_id;
END IF;

    -- Validate item_type
    IF p_item_type IS NULL OR LENGTH(TRIM(p_item_type)) = 0 THEN
        RAISE EXCEPTION 'Item type must not be empty';
END IF;

    -- Insert into products
INSERT INTO products (sku, name, description, product_type, base_price, brand_id)
VALUES (p_sku, p_name, p_description, 'stationery', p_base_price, p_brand_id)
    RETURNING id INTO new_product_id;

-- Insert into non_book_products
INSERT INTO non_book_products (
    product_id, item_type, specifications
)
VALUES (
           new_product_id, p_item_type, p_specifications
       );
END;
$$ LANGUAGE plpgsql;





-- adding stock to inventory

CREATE OR REPLACE FUNCTION add_product_to_inventory(
    p_store_id INTEGER,
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_restock_threshold INTEGER DEFAULT 10
)
RETURNS VOID AS $$
BEGIN
    -- Validate store existence
    IF NOT EXISTS (SELECT 1 FROM stores WHERE id = p_store_id) THEN
        RAISE EXCEPTION 'Store with ID % does not exist', p_store_id;
END IF;

    -- Validate product existence
    IF NOT EXISTS (SELECT 1 FROM products WHERE id = p_product_id) THEN
        RAISE EXCEPTION 'Product with ID % does not exist', p_product_id;
END IF;

    -- Validate quantity
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity must be greater than zero';
END IF;

    -- Validate restock threshold
    IF p_restock_threshold IS NULL OR p_restock_threshold < 0 THEN
        RAISE EXCEPTION 'Restock threshold must be a non-negative integer';
END IF;

    -- Try to update existing inventory record
UPDATE inventory
SET quantity = quantity + p_quantity,
    restock_threshold = p_restock_threshold
WHERE store_id = p_store_id
  AND product_id = p_product_id;

-- Insert new if not found
IF NOT FOUND THEN
        INSERT INTO inventory (store_id, product_id, quantity, restock_threshold)
        VALUES (p_store_id, p_product_id, p_quantity, p_restock_threshold);
END IF;
END;
$$ LANGUAGE plpgsql;



-- create / add store

CREATE OR REPLACE FUNCTION create_store(
    p_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_street TEXT,
    p_city VARCHAR,
    p_state VARCHAR,
    p_postal_code VARCHAR,
    p_country VARCHAR
) RETURNS INTEGER AS $$
DECLARE
v_contact_id INTEGER;
    v_store_id INTEGER;
BEGIN
    -- ====== VALIDATION ======

    -- Store name must not be empty
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
        RAISE EXCEPTION 'Store name must not be empty';
END IF;

    -- Validate email format
    IF p_email IS NULL OR NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email address: %', p_email;
END IF;

    -- Validate phone length
    IF p_phone IS NULL OR LENGTH(p_phone) < 6 THEN
        RAISE EXCEPTION 'Invalid phone number: must be at least 6 characters';
END IF;

    -- Validate address fields
    IF p_street IS NULL OR LENGTH(TRIM(p_street)) = 0 THEN
        RAISE EXCEPTION 'Street address is required';
END IF;

    IF p_city IS NULL OR LENGTH(TRIM(p_city)) = 0 THEN
        RAISE EXCEPTION 'City is required';
END IF;

    IF p_state IS NULL OR LENGTH(TRIM(p_state)) = 0 THEN
        RAISE EXCEPTION 'State is required';
END IF;

    IF p_postal_code IS NULL OR LENGTH(TRIM(p_postal_code)) = 0 THEN
        RAISE EXCEPTION 'Postal code is required';
END IF;

    IF p_country IS NULL OR LENGTH(TRIM(p_country)) = 0 THEN
        RAISE EXCEPTION 'Country is required';
END IF;

    -- ====== INSERTION ======

    -- Insert into contacts
INSERT INTO contacts(email, phone)
VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

-- Insert into stores
INSERT INTO stores(name, contact_id)
VALUES (p_name, v_contact_id)
    RETURNING id INTO v_store_id;

-- Insert into store_addresses
INSERT INTO store_addresses(store_id, street, city, state, postal_code, country)
VALUES (v_store_id, p_street, p_city, p_state, p_postal_code, p_country);

RETURN v_store_id;
END;
$$ LANGUAGE plpgsql;




-- ================================================
-- SQL Update (Edit) Functions for Bookstore System
-- ================================================






-- Edit Store
CREATE OR REPLACE FUNCTION edit_store(
    p_store_id INTEGER,
    p_name TEXT,
    p_email TEXT,
    p_phone TEXT,
    p_street TEXT,
    p_city TEXT,
    p_state TEXT,
    p_postal_code TEXT,
    p_country TEXT
) RETURNS VOID AS $$
DECLARE
v_contact_id INTEGER;
BEGIN
    IF p_store_id IS NULL THEN
        RAISE EXCEPTION 'Store ID must not be null';
END IF;

    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
        RAISE EXCEPTION 'Store name must not be empty';
END IF;

    IF p_email IS NULL OR NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email address: %', p_email;
END IF;

    IF p_phone IS NULL OR LENGTH(p_phone) < 6 THEN
        RAISE EXCEPTION 'Invalid phone number';
END IF;

    IF p_street IS NULL OR LENGTH(TRIM(p_street)) = 0 OR
       p_city IS NULL OR LENGTH(TRIM(p_city)) = 0 OR
       p_state IS NULL OR LENGTH(TRIM(p_state)) = 0 OR
       p_postal_code IS NULL OR LENGTH(TRIM(p_postal_code)) = 0 OR
       p_country IS NULL OR LENGTH(TRIM(p_country)) = 0 THEN
        RAISE EXCEPTION 'All address fields must be provided';
END IF;

SELECT contact_id INTO v_contact_id FROM stores WHERE id = p_store_id;

IF NOT FOUND THEN
        RAISE EXCEPTION 'Store with ID % not found', p_store_id;
END IF;

UPDATE contacts
SET email = p_email,
    phone = p_phone
WHERE id = v_contact_id;

UPDATE stores
SET name = p_name
WHERE id = p_store_id;

UPDATE store_addresses
SET street = p_street,
    city = p_city,
    state = p_state,
    postal_code = p_postal_code,
    country = p_country
WHERE store_id = p_store_id;
END;
$$ LANGUAGE plpgsql;








-- Edit Publisher
CREATE OR REPLACE FUNCTION edit_publisher(
    p_publisher_id INTEGER,
    p_name TEXT,
    p_email TEXT,
    p_phone TEXT
) RETURNS VOID AS $$
DECLARE
v_contact_id INTEGER;
BEGIN
    IF p_publisher_id IS NULL THEN
        RAISE EXCEPTION 'Publisher ID must not be null';
END IF;

    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
        RAISE EXCEPTION 'Publisher name must not be empty';
END IF;

    IF p_email IS NULL OR NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email address: %', p_email;
END IF;

    IF p_phone IS NULL OR LENGTH(p_phone) < 6 THEN
        RAISE EXCEPTION 'Invalid phone number';
END IF;

SELECT contact_id INTO v_contact_id FROM publishers WHERE id = p_publisher_id;

IF NOT FOUND THEN
        RAISE EXCEPTION 'Publisher with ID % not found', p_publisher_id;
END IF;

UPDATE contacts
SET email = p_email,
    phone = p_phone
WHERE id = v_contact_id;

UPDATE publishers
SET name = p_name
WHERE id = p_publisher_id;
END;
$$ LANGUAGE plpgsql;








-- Edit Book Product
-- Edit Book Product with validation and existence check
CREATE OR REPLACE FUNCTION edit_book_product(
    p_product_id INTEGER,
    p_sku VARCHAR,
    p_name VARCHAR,
    p_description TEXT,
    p_base_price NUMERIC,
    p_brand_id INTEGER,
    p_isbn CHAR(13),
    p_author_id INTEGER,
    p_publisher_id INTEGER,
    p_pub_date DATE,
    p_language VARCHAR,
    p_sub_category_id INTEGER
) RETURNS VOID AS $$
DECLARE
v_exists BOOLEAN;
BEGIN
    -- Check product exists
SELECT EXISTS(SELECT 1 FROM products WHERE id = p_product_id) INTO v_exists;
IF NOT v_exists THEN
        RAISE EXCEPTION 'Product with ID % does not exist', p_product_id;
END IF;

    -- Update products table
UPDATE products
SET sku = p_sku,
    name = p_name,
    description = p_description,
    base_price = p_base_price,
    brand_id = p_brand_id
WHERE id = p_product_id;

-- Check book_products entry exists
SELECT EXISTS(SELECT 1 FROM book_products WHERE product_id = p_product_id) INTO v_exists;
IF NOT v_exists THEN
        RAISE EXCEPTION 'Book product details for product ID % do not exist', p_product_id;
END IF;

    -- Update book_products table
UPDATE book_products
SET isbn = p_isbn,
    author_id = p_author_id,
    publisher_id = p_publisher_id,
    publication_date = p_pub_date,
    language = p_language,
    sub_category_id = p_sub_category_id
WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;




-- Edit Non-Book Product with validation and existence check
CREATE OR REPLACE FUNCTION edit_non_book_product(
    p_product_id INTEGER,
    p_sku VARCHAR,
    p_name VARCHAR,
    p_description TEXT,
    p_base_price NUMERIC,
    p_brand_id INTEGER,
    p_item_type VARCHAR,
    p_specifications JSONB
) RETURNS VOID AS $$
DECLARE
v_exists BOOLEAN;
BEGIN
    -- Check product exists
SELECT EXISTS(SELECT 1 FROM products WHERE id = p_product_id) INTO v_exists;
IF NOT v_exists THEN
        RAISE EXCEPTION 'Product with ID % does not exist', p_product_id;
END IF;

    -- Update products table
UPDATE products
SET sku = p_sku,
    name = p_name,
    description = p_description,
    base_price = p_base_price,
    brand_id = p_brand_id
WHERE id = p_product_id;

-- Check non_book_products entry exists
SELECT EXISTS(SELECT 1 FROM non_book_products WHERE product_id = p_product_id) INTO v_exists;
IF NOT v_exists THEN
        RAISE EXCEPTION 'Non-book product details for product ID % do not exist', p_product_id;
END IF;

    -- Update non_book_products table
UPDATE non_book_products
SET item_type = p_item_type,
    specifications = p_specifications
WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;





-- Edit Inventory Threshold (with existence check)
CREATE OR REPLACE FUNCTION edit_inventory_threshold(
    p_store_id INTEGER,
    p_product_id INTEGER,
    p_new_threshold INTEGER
) RETURNS VOID AS $$
DECLARE
v_exists BOOLEAN;
BEGIN
SELECT EXISTS(SELECT 1 FROM inventory WHERE store_id = p_store_id AND product_id = p_product_id) INTO v_exists;

IF NOT v_exists THEN
        RAISE EXCEPTION 'Inventory entry for store % and product % does not exist', p_store_id, p_product_id;
END IF;

UPDATE inventory
SET restock_threshold = p_new_threshold
WHERE store_id = p_store_id AND product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- Check if all products in customer's cart have sufficient inventory
CREATE OR REPLACE FUNCTION check_product_availabilities(
    p_customer_id INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
v_item RECORD;
    v_store_qty INTEGER;
    v_remaining_qty INTEGER;
BEGIN
FOR v_item IN
SELECT product_id, quantity
FROM shopping_cart_items
WHERE customer_id = p_customer_id
    LOOP
        v_remaining_qty := v_item.quantity;

FOR v_store_qty IN
SELECT quantity
FROM inventory
WHERE product_id = v_item.product_id AND quantity > 0
ORDER BY quantity DESC
    LOOP
            EXIT WHEN v_remaining_qty <= 0;
v_remaining_qty := v_remaining_qty - LEAST(v_remaining_qty, v_store_qty);
END LOOP;

        IF v_remaining_qty > 0 THEN
            -- Not enough stock to fulfill this product's quantity
            RETURN FALSE;
END IF;
END LOOP;

    -- All products can be fulfilled
RETURN TRUE;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION calculate_order_total(
    p_customer_id INTEGER
) RETURNS NUMERIC(10,2) AS $$
DECLARE
    v_item RECORD;
    v_discount_price NUMERIC(10,2);
    v_total NUMERIC(10,2) := 0;
BEGIN
    FOR v_item IN
        SELECT sci.product_id, sci.quantity, p.base_price
        FROM shopping_cart_items sci
                 JOIN products p ON p.id = sci.product_id
        WHERE sci.customer_id = p_customer_id
        LOOP
            SELECT COALESCE(pd.final_price, v_item.base_price)
            INTO v_discount_price
            FROM product_discounts pd
            WHERE pd.product_id = v_item.product_id
            LIMIT 1;

            v_total := v_total + (v_item.quantity * v_discount_price);
        END LOOP;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS check_membership(INTEGER);

CREATE OR REPLACE FUNCTION check_membership(p_customer_id INTEGER)
    RETURNS BOOLEAN AS $$
DECLARE
    v_valid BOOLEAN;
BEGIN
    SELECT expiry_date > CURRENT_DATE
    INTO v_valid
    FROM memberships
    WHERE customer_id = p_customer_id
    LIMIT 1;

    RETURN COALESCE(v_valid, FALSE);
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION place_order(
    p_customer_id INTEGER,
    p_status order_status,
    p_payment_method TEXT,
    p_transaction_id TEXT
) RETURNS INTEGER AS $$
DECLARE
v_order_id INTEGER;
    v_item RECORD;
    v_store RECORD;
    v_discount_price NUMERIC(10,2);
    v_remaining_qty INTEGER;
    v_fulfilled_qty INTEGER;
    v_total_price NUMERIC(10,2);
BEGIN
    -- Check availability
    IF NOT check_product_availabilities(p_customer_id) THEN
        RAISE EXCEPTION 'Not enough inventory to fulfill the order';
END IF;

    -- Calculate total price with membership discount
    v_total_price := calculate_order_total(p_customer_id);
    IF check_membership(p_customer_id) THEN
        v_total_price := v_total_price * 0.9;
END IF;

    -- Create the order record
INSERT INTO orders (customer_id, status, payment_method, transaction_id, total_price)
VALUES (p_customer_id, p_status, p_payment_method, p_transaction_id, v_total_price)
    RETURNING id INTO v_order_id;

-- Loop through each cart item to fulfill from inventories
FOR v_item IN
SELECT sci.product_id, sci.quantity, p.base_price
FROM shopping_cart_items sci
         JOIN products p ON p.id = sci.product_id
WHERE sci.customer_id = p_customer_id
    LOOP
        v_remaining_qty := v_item.quantity;

FOR v_store IN
SELECT * FROM inventory
WHERE product_id = v_item.product_id AND quantity > 0
ORDER BY quantity DESC
    LOOP
            EXIT WHEN v_remaining_qty <= 0;

v_fulfilled_qty := LEAST(v_remaining_qty, v_store.quantity);

            -- Get discount price or fallback to base price
SELECT COALESCE(MIN(pd.final_price), v_item.base_price)
INTO v_discount_price
FROM product_discounts pd
WHERE pd.product_id = v_item.product_id;

-- Insert order details
INSERT INTO order_details (
    order_id, product_id, quantity, unit_price, store_id
) VALUES (
             v_order_id, v_item.product_id, v_fulfilled_qty, v_discount_price, v_store.store_id
         );

-- Deduct inventory only if order status requires it
IF p_status IN ('pending', 'processing', 'delivered') THEN
UPDATE inventory
SET quantity = quantity - v_fulfilled_qty
WHERE store_id = v_store.store_id AND product_id = v_item.product_id;
END IF;

            v_remaining_qty := v_remaining_qty - v_fulfilled_qty;
END LOOP;
END LOOP;

    -- Clear customer's shopping cart
DELETE FROM shopping_cart_items WHERE customer_id = p_customer_id;

RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;


-- ================================================
-- 1. Edit Order Status: Restore Inventory if Cancelled
-- ================================================
CREATE OR REPLACE FUNCTION edit_order_status(
    p_order_id INTEGER,
    p_new_status order_status
) RETURNS VOID AS $$
DECLARE
v_current_status order_status;
    v_item RECORD;
BEGIN
    -- Get current status
SELECT status INTO v_current_status FROM orders WHERE id = p_order_id;
IF NOT FOUND THEN
        RAISE EXCEPTION 'Order ID % not found', p_order_id;
END IF;

    IF v_current_status = 'delivered' AND p_new_status = 'cancelled' THEN
        RAISE EXCEPTION 'Cannot cancel a delivered order';
END IF;

    -- If cancelling and not delivered, restore inventory
    IF p_new_status = 'cancelled' AND v_current_status != 'delivered' THEN
        FOR v_item IN
SELECT * FROM order_details WHERE order_id = p_order_id
    LOOP
UPDATE inventory
SET quantity = quantity + v_item.quantity
WHERE store_id = v_item.store_id AND product_id = v_item.product_id;
END LOOP;
END IF;

    -- Update order status
UPDATE orders SET status = p_new_status WHERE id = p_order_id;
END;
$$ LANGUAGE plpgsql;


-- ================================================
-- 2. Delete Product by ID with Subtype Handling
-- ================================================
CREATE OR REPLACE FUNCTION delete_product_by_id(p_product_id INTEGER)
    RETURNS TEXT AS $$
DECLARE
v_product_type TEXT;
BEGIN
    -- Get product type
SELECT product_type INTO v_product_type
FROM products
WHERE id = p_product_id;

IF NOT FOUND THEN
        RAISE EXCEPTION 'Product with ID % not found', p_product_id;
END IF;

    -- Delete from subtype table
    IF v_product_type = 'book' THEN
DELETE FROM book_products WHERE product_id = p_product_id;
ELSIF v_product_type = 'stationery' THEN
DELETE FROM non_book_products WHERE product_id = p_product_id;
ELSE
        RAISE EXCEPTION 'Unsupported product type: %', v_product_type;
END IF;

    -- Delete from main products table
DELETE FROM products WHERE id = p_product_id;

RETURN format('Deleted product %s (type: %s)', p_product_id, v_product_type);
END;
$$ LANGUAGE plpgsql;


-- ================================================
-- 3. List All Products with Inventory and Details
-- ================================================
CREATE OR REPLACE FUNCTION list_products_all()
    RETURNS TABLE (
        product_id INTEGER,
        sku VARCHAR,
        name VARCHAR,
        product_type VARCHAR,
        base_price NUMERIC,
        brand_id INTEGER,
        brand_name VARCHAR,
        isbn CHAR(13),
        language VARCHAR,
        item_type VARCHAR,
        specifications JSONB,
        store_id INTEGER,
        store_name VARCHAR,
        inventory_quantity INTEGER
    ) AS $$
BEGIN
RETURN QUERY
SELECT
    p.id,
    p.sku,
    p.name,
    p.product_type::VARCHAR,
    p.base_price,
    p.brand_id,
    b.name,
    bp.isbn,
    bp.language,
    nbp.item_type,
    nbp.specifications,
    i.store_id,
    s.name,
    i.quantity
FROM products p
         LEFT JOIN brands b ON p.brand_id = b.id
         LEFT JOIN book_products bp ON p.id = bp.product_id
         LEFT JOIN non_book_products nbp ON p.id = nbp.product_id
         LEFT JOIN inventory i ON p.id = i.product_id
         LEFT JOIN stores s ON i.store_id = s.id
ORDER BY p.id, i.store_id;
END;
$$ LANGUAGE plpgsql;


-- ================================================
-- 4. Restock Trigger Function and Trigger
-- ================================================
CREATE OR REPLACE FUNCTION trigger_restock_alert_and_restock()
    RETURNS TRIGGER AS $$
DECLARE
v_restock_qty INTEGER := 20;
BEGIN
    IF NEW.quantity < NEW.restock_threshold THEN
        -- Avoid duplicate unresolved alerts for this inventory
        IF NOT EXISTS (
            SELECT 1 FROM restock_alerts
            WHERE inventory_id = NEW.id AND resolved = FALSE
        ) THEN
            -- Log trigger firing
            RAISE NOTICE 'Trigger fired: quantity (%) < threshold (%)', NEW.quantity, NEW.restock_threshold;

            -- Insert alert
INSERT INTO restock_alerts (
    inventory_id, product_id, store_id, quantity, restock_threshold, alert_message, resolved
)
VALUES (
           NEW.id, NEW.product_id, NEW.store_id, NEW.quantity,
           NEW.restock_threshold, 'Stock below restock threshold.', FALSE
       );

-- Perform restock
RAISE NOTICE 'Trigger performing restock of % units for inventory_id = %', v_restock_qty, NEW.id;

            PERFORM create_restock(
                NEW.id, v_restock_qty, 'system', 'Auto restock triggered by low inventory'
            );
END IF;
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Drop existing trigger if any
DROP TRIGGER IF EXISTS trg_restock_alert ON inventory;

-- Create trigger
CREATE TRIGGER trg_restock_alert
    AFTER UPDATE ON inventory
    FOR EACH ROW
    WHEN (OLD.quantity IS DISTINCT FROM NEW.quantity)
EXECUTE FUNCTION trigger_restock_alert_and_restock();
