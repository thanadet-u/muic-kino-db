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
    p_is_default BOOLEAN DEFAULT TRUE
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
INSERT INTO customers (first_name, last_name, contact_id)
VALUES (p_first_name, p_last_name, v_contact_id)
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




-- ===========================================
-- INSERT FUNCTIONS FOR MAIN ENTITIES
-- ===========================================

-- 1. Add a new customer with contact and address
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

-- 2. Add a new store with contact and address
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

-- 4. Add an author
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

-- 5. Add item to shopping cart
CREATE OR REPLACE FUNCTION add_to_cart(
    p_customer_id INTEGER,
    p_product_id INTEGER,
    p_quantity INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO shopping_cart_items (customer_id, product_id, quantity)
    VALUES (p_customer_id, p_product_id, p_quantity)
    ON CONFLICT (customer_id, product_id)
        DO UPDATE SET quantity = shopping_cart_items.quantity + EXCLUDED.quantity;
END;
$$ LANGUAGE plpgsql;

-- 6. Place an order
CREATE OR REPLACE FUNCTION place_order(
    p_customer_id INTEGER,
    p_store_id INTEGER,
    p_payment_method TEXT,
    p_transaction_id TEXT
) RETURNS INTEGER AS $$
DECLARE
    v_order_id INTEGER;
BEGIN
    INSERT INTO orders (customer_id, store_id, payment_method, transaction_id)
    VALUES (p_customer_id, p_store_id, p_payment_method, p_transaction_id)
    RETURNING id INTO v_order_id;

    -- Assume order details and cart handling are done outside this function
    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

-- 7. Restock inventory
CREATE OR REPLACE FUNCTION restock_inventory(
    p_store_id INTEGER,
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_restocked_by TEXT,
    p_notes TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO restocks (store_id, product_id, quantity, restocked_by, notes)
    VALUES (p_store_id, p_product_id, p_quantity, p_restocked_by, p_notes);

    UPDATE inventory
    SET quantity = quantity + p_quantity
    WHERE store_id = p_store_id AND product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;



--8 Create Order From Shopping Cart

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

