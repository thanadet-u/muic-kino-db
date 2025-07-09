
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
    p_address_type VARCHAR DEFAULT 'shipping',
    p_is_default BOOLEAN DEFAULT TRUE,
    p_password_hash VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
v_contact_id INTEGER;
    v_customer_id INTEGER;
BEGIN
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
    -- Insert into contacts
INSERT INTO contacts (email, phone)
VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

-- Insert into stores
INSERT INTO stores (name, contact_id)
VALUES (p_name, v_contact_id)
    RETURNING id INTO v_store_id;

-- Insert store address
INSERT INTO store_addresses (store_id, street, city, state, postal_code, country)
VALUES (v_store_id, p_street, p_city, p_state, p_postal_code, p_country);

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

CREATE OR REPLACE FUNCTION add_customer_address(
    p_customer_id INTEGER,
    p_street TEXT,
    p_city TEXT,
    p_state TEXT,
    p_postal_code TEXT,
    p_country TEXT,
    p_address_type VARCHAR DEFAULT 'shipping',
    p_is_default BOOLEAN DEFAULT false
) RETURNS INTEGER AS $$
DECLARE
    v_address_id INTEGER;
BEGIN
    -- If setting this address as default, unset previous defaults of the same type
    IF p_is_default THEN
        UPDATE customer_addresses
        SET is_default = false
        WHERE customer_id = p_customer_id
          AND address_type = p_address_type
          AND is_default = true;
    END IF;

    -- Insert the new address
    INSERT INTO customer_addresses (
        customer_id, street, city, state, postal_code, country, address_type, is_default
    ) VALUES (
                 p_customer_id, p_street, p_city, p_state, p_postal_code, p_country, p_address_type, p_is_default
             ) RETURNING id INTO v_address_id;

    RETURN v_address_id;
END;
$$ LANGUAGE plpgsql;



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
    INSERT INTO contacts (email, phone)
    VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

    INSERT INTO stores (name, contact_id)
    VALUES (p_name, v_contact_id)
    RETURNING id INTO v_store_id;

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
    INSERT INTO contacts (email, phone)
    VALUES (p_email, p_phone)
    RETURNING id INTO v_contact_id;

    INSERT INTO publishers (name, contact_id)
    VALUES (p_name, v_contact_id);
END;
$$ LANGUAGE plpgsql;

-- . Add an author
CREATE OR REPLACE FUNCTION add_author(
    p_first_name TEXT,
    p_last_name TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO authors (first_name, last_name)
    VALUES (p_first_name, p_last_name);
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
    v_store_id INTEGER; -- null for online
    v_cart_item RECORD;
    v_total NUMERIC(10,2) := 0;
BEGIN
    -- Create a new order
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
            VALUES (v_order_id, v_cart_item.product_id, v_cart_item.quantity, v_cart_item.base_price);

            -- Calculate running total
            v_total := v_total + (v_cart_item.quantity * v_cart_item.base_price);
        END LOOP;

    -- Update total price of the order
    UPDATE orders SET total_price = v_total WHERE id = v_order_id;

    -- Clear shopping cart
    DELETE FROM shopping_cart_items WHERE customer_id = p_customer_id;

    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;


CREATE TYPE book_language AS ENUM ('English', 'Japanese', 'Chinese', 'Thai');




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
    -- Step 1: Insert into products
    INSERT INTO products (sku, name, description, product_type, base_price, brand_id)
    VALUES (p_sku, p_name, p_description, 'book', p_base_price, p_brand_id)
    RETURNING id INTO new_product_id;

    -- Step 2: Insert into book_products
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
    -- Step 1: Insert into products
    INSERT INTO products (sku, name, description, product_type, base_price, brand_id)
    VALUES (p_sku, p_name, p_description, 'stationery', p_base_price, p_brand_id)
    RETURNING id INTO new_product_id;

    -- Step 2: Insert into non_book_products
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
) RETURNS VOID AS $$
BEGIN
    -- Try to update existing inventory record by adding quantity
    UPDATE inventory
    SET quantity = quantity + p_quantity,
        restock_threshold = p_restock_threshold
    WHERE store_id = p_store_id
      AND product_id = p_product_id;

    -- If no rows updated, insert new inventory record
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
    SELECT contact_id INTO v_contact_id FROM stores WHERE id = p_store_id;

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
    SELECT contact_id INTO v_contact_id FROM publishers WHERE id = p_publisher_id;

    UPDATE contacts
    SET email = p_email,
        phone = p_phone
    WHERE id = v_contact_id;

    UPDATE publishers
    SET name = p_name
    WHERE id = p_publisher_id;
END;
$$ LANGUAGE plpgsql;

-- 4. Edit Author
CREATE OR REPLACE FUNCTION edit_author(
    p_author_id INTEGER,
    p_first_name TEXT,
    p_last_name TEXT
) RETURNS VOID AS $$
BEGIN
    UPDATE authors
    SET first_name = p_first_name,
        last_name = p_last_name
    WHERE id = p_author_id;
END;
$$ LANGUAGE plpgsql;

-- Edit Book Product
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
BEGIN
    UPDATE products
    SET sku = p_sku,
        name = p_name,
        description = p_description,
        base_price = p_base_price,
        brand_id = p_brand_id
    WHERE id = p_product_id;

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

-- Edit Non-Book Product
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
BEGIN
    UPDATE products
    SET sku = p_sku,
        name = p_name,
        description = p_description,
        base_price = p_base_price,
        brand_id = p_brand_id
    WHERE id = p_product_id;

    UPDATE non_book_products
    SET item_type = p_item_type,
        specifications = p_specifications
    WHERE product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;

-- 7. Edit Inventory Threshold (optional convenience)
CREATE OR REPLACE FUNCTION edit_inventory_threshold(
    p_store_id INTEGER,
    p_product_id INTEGER,
    p_new_threshold INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE inventory
    SET restock_threshold = p_new_threshold
    WHERE store_id = p_store_id AND product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;



-- ================================================
-- Specific Command
-- ================================================



