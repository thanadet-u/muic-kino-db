-- Add item to shopping cart
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





-- Restock inventory
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


















-- Delete Customer Address
CREATE OR REPLACE FUNCTION delete_customer_address(
    p_address_id INTEGER
) RETURNS VOID AS $$
BEGIN
DELETE FROM customer_addresses WHERE id = p_address_id;
END;
$$ LANGUAGE plpgsql;







-- Set address

CREATE OR REPLACE FUNCTION set_customer_default_address(
    p_address_id INTEGER
) RETURNS VOID AS $$
DECLARE
v_customer_id INTEGER;
    v_address_type VARCHAR;
BEGIN
    -- Get customer_id and address_type of the target address
SELECT customer_id, address_type
INTO v_customer_id, v_address_type
FROM customer_addresses
WHERE id = p_address_id;

-- Unset any existing default of this type for the customer
UPDATE customer_addresses
SET is_default = false
WHERE customer_id = v_customer_id
  AND address_type = v_address_type;

-- Set this one as default
UPDATE customer_addresses
SET is_default = true
WHERE id = p_address_id;
END;
$$ LANGUAGE plpgsql;


   -- Set Customer Address as Default

CREATE OR REPLACE FUNCTION set_customer_default_address(
    p_address_id INTEGER
) RETURNS VOID AS $$
DECLARE
v_customer_id INTEGER;
    v_address_type VARCHAR;
BEGIN
    -- Get customer_id and address_type of the target address
SELECT customer_id, address_type
INTO v_customer_id, v_address_type
FROM customer_addresses
WHERE id = p_address_id;

-- Unset any existing default of this type for the customer
UPDATE customer_addresses
SET is_default = false
WHERE customer_id = v_customer_id
  AND address_type = v_address_type;

-- Set this one as default
UPDATE customer_addresses
SET is_default = true
WHERE id = p_address_id;
END;
$$ LANGUAGE plpgsql;



-- Edit Customer Address

CREATE OR REPLACE FUNCTION edit_customer_address(
    p_address_id INTEGER,
    p_street TEXT,
    p_city TEXT,
    p_state TEXT,
    p_postal_code TEXT,
    p_country TEXT,
    p_is_default BOOLEAN DEFAULT false
) RETURNS VOID AS $$
DECLARE
v_customer_id INTEGER;
    v_address_type VARCHAR;
BEGIN
SELECT customer_id, address_type
INTO v_customer_id, v_address_type
FROM customer_addresses
WHERE id = p_address_id;

-- If default, unset previous default first
IF p_is_default THEN
UPDATE customer_addresses
SET is_default = false
WHERE customer_id = v_customer_id
  AND address_type = v_address_type;
END IF;

    -- Update the address
UPDATE customer_addresses
SET street = p_street,
    city = p_city,
    state = p_state,
    postal_code = p_postal_code,
    country = p_country,
    is_default = p_is_default
WHERE id = p_address_id;
END;
$$ LANGUAGE plpgsql;







-- Edit Customer (update contact, customer info incl. password, and optionally address)
CREATE OR REPLACE FUNCTION edit_customer(
    p_customer_id INTEGER,
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT,
    p_phone TEXT,
    p_password_hash TEXT DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
v_contact_id INTEGER;
BEGIN
    -- Get the contact_id associated with the customer
SELECT contact_id INTO v_contact_id
FROM customers
WHERE id = p_customer_id;

-- Update contact info
UPDATE contacts
SET email = p_email,
    phone = p_phone
WHERE id = v_contact_id;

-- Update customer info
IF p_password_hash IS NOT NULL THEN
UPDATE customers
SET first_name = p_first_name,
    last_name = p_last_name,
    password_hash = p_password_hash
WHERE id = p_customer_id;
ELSE
UPDATE customers
SET first_name = p_first_name,
    last_name = p_last_name
WHERE id = p_customer_id;
END IF;
END;
$$ LANGUAGE plpgsql;

