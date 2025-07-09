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

----------

CREATE OR REPLACE FUNCTION check_availability(p_product_id INT)
    RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    total_qty INT;
BEGIN
    SELECT COALESCE(SUM(quantity),0)
    INTO total_qty
    FROM inventory
    WHERE product_id = p_product_id;
    RETURN total_qty;
END;
$$;


-- 2. Product detail reader
CREATE OR REPLACE FUNCTION read_product_detail(p_product_id INT)
    RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT to_jsonb(p.*)
    INTO result
    FROM products p
    WHERE p.id = p_product_id;
    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION check_membership(p_membership_id INT)
    RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    valid BOOLEAN;
BEGIN
    SELECT (expiry_date >= CURRENT_DATE)
    INTO valid
    FROM memberships
    WHERE id = p_membership_id;
    RAISE NOTICE 'Checking membership ID: %, valid: %', p_membership_id, valid;
    RETURN COALESCE(valid, false);
END;
$$;

CREATE OR REPLACE FUNCTION apply_promo_code(
    p_customer_id INT,
    p_discount_id INT
)
    RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO product_discounts(product_id, discount_id)
    SELECT sci.product_id, p_discount_id
    FROM shopping_cart_items sci
    WHERE sci.customer_id = p_customer_id
    ON CONFLICT DO NOTHING;
END;
$$;


-- 6. Product searches
CREATE OR REPLACE FUNCTION search_products_by_isbn(p_isbn CHAR)
    RETURNS SETOF book_products LANGUAGE sql AS $$
SELECT * FROM book_products WHERE isbn = $1;
$$;

CREATE OR REPLACE FUNCTION search_products_advanced(
    p_title         TEXT DEFAULT NULL,
    p_category_id   INT DEFAULT NULL,
    p_author_id     INT DEFAULT NULL,
    p_publisher_id  INT DEFAULT NULL,
    p_from_year     INT DEFAULT NULL,
    p_from_month    INT DEFAULT NULL,
    p_to_year       INT DEFAULT NULL,
    p_to_month      INT DEFAULT NULL
)
    RETURNS TABLE (
                      product_id     INT,
                      sku            VARCHAR,
                      title          VARCHAR,
                      author_id      INT,
                      publisher_id   INT,
                      category_id    INT,
                      publication_date DATE,
                      available_qty  INT
                  ) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.id,
            p.sku,
            p.name,
            bp.author_id,
            bp.publisher_id,
            sc.category_id,
            bp.publication_date,
            SUM(i.quantity)::INTEGER AS available_qty
        FROM products p
                 JOIN book_products bp ON bp.product_id = p.id
                 JOIN sub_categories sc ON sc.id = bp.sub_category_id
                 JOIN inventory i ON i.product_id = p.id
        WHERE (p_title IS NULL OR p.name ILIKE '%' || p_title || '%')
          AND (p_category_id IS NULL OR sc.category_id = p_category_id)
          AND (p_author_id IS NULL OR bp.author_id = p_author_id)
          AND (p_publisher_id IS NULL OR bp.publisher_id = p_publisher_id)
          AND (
            (p_from_year IS NULL AND p_to_year IS NULL)
                OR (
                bp.publication_date >= make_date(COALESCE(p_from_year, 1), COALESCE(p_from_month, 1), 1)
                    AND bp.publication_date <  make_date(COALESCE(p_to_year, 9999), COALESCE(p_to_month, 12), 1) + INTERVAL '1 month'
                )
            )
        GROUP BY p.id, bp.author_id, bp.publisher_id, sc.category_id, bp.publication_date
        HAVING SUM(i.quantity) > 0;
END;
$$;


CREATE OR REPLACE FUNCTION search_books_category(p_category_id INT)
    RETURNS SETOF book_products LANGUAGE sql AS $$
SELECT bp.*
FROM book_products bp
         JOIN sub_categories sc ON sc.id = bp.sub_category_id
WHERE sc.category_id = p_category_id;
$$;

CREATE OR REPLACE FUNCTION filter_product(
    p_type       product_type,
    p_subcat_id  INT DEFAULT NULL,
    p_publisher  INT DEFAULT NULL
)
    RETURNS SETOF products LANGUAGE sql AS $$
SELECT *
FROM products p
WHERE p.product_type = p_type
  AND (p_subcat_id IS NULL OR p.id IN (
    SELECT product_id FROM book_products WHERE sub_category_id = p_subcat_id))
  AND (p_publisher IS NULL OR p.id IN (
    SELECT product_id FROM book_products WHERE publisher_id = p_publisher));
$$;

CREATE OR REPLACE FUNCTION list_category()
    RETURNS SETOF categories LANGUAGE sql AS $$
SELECT * FROM categories;
$$;
