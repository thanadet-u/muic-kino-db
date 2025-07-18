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



CREATE OR REPLACE FUNCTION edit_cart_item_quantity(
    p_customer_id INTEGER,
    p_product_id INTEGER,
    p_new_quantity INTEGER
) RETURNS VOID AS $$
BEGIN
    IF p_new_quantity > 0 THEN
        UPDATE shopping_cart_items
        SET quantity = p_new_quantity
        WHERE customer_id = p_customer_id AND product_id = p_product_id;

        IF NOT FOUND THEN
            RAISE NOTICE 'Item not found in cart, nothing updated.';
        END IF;
    ELSE
        -- Delete if quantity is zero or less
        DELETE FROM shopping_cart_items
        WHERE customer_id = p_customer_id AND product_id = p_product_id;

        RAISE NOTICE 'Quantity was zero or less, item removed from cart.';
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION remove_item_from_cart(
    p_customer_id INTEGER,
    p_product_id INTEGER
) RETURNS VOID AS $$
BEGIN
DELETE FROM shopping_cart_items
WHERE customer_id = p_customer_id AND product_id = p_product_id;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION clear_cart(
    p_customer_id INTEGER
) RETURNS VOID AS $$
BEGIN
DELETE FROM shopping_cart_items
WHERE customer_id = p_customer_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cart_items(p_customer_id INT)
    RETURNS TABLE (
        product_id INT,
        sku VARCHAR,
        name VARCHAR,
        quantity INT,
        unit_price NUMERIC,
        total_price NUMERIC,
        discount_applied BOOLEAN
    ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.id,
            p.sku,
            p.name,
            sci.quantity,
            COALESCE(pd.final_price, p.base_price) AS unit_price,
            COALESCE(pd.final_price, p.base_price) * sci.quantity AS total_price,
            (pd.final_price IS NOT NULL AND d.is_active) AS discount_applied
        FROM shopping_cart_items sci
        JOIN products p ON p.id = sci.product_id
        LEFT JOIN product_discounts pd ON pd.product_id = p.id
        LEFT JOIN discounts d ON pd.discount_id = d.id AND d.is_active = true
        WHERE sci.customer_id = p_customer_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION calculate_cart_total(p_customer_id INT)
    RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC := 0;
BEGIN
    SELECT
        SUM(sci.quantity * COALESCE(pd.final_price, p.base_price))
    INTO v_total
    FROM shopping_cart_items sci
             JOIN products p ON sci.product_id = p.id
             LEFT JOIN product_discounts pd ON pd.product_id = p.id
    WHERE sci.customer_id = p_customer_id;

    RETURN COALESCE(ROUND(v_total, 2), 0);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION apply_promo_code(
    p_customer_id INT,
    p_discount_id INT
) RETURNS VOID AS $$
BEGIN
    -- Ensure discount is active
    IF NOT EXISTS (
        SELECT 1 FROM discounts
        WHERE id = p_discount_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Discount code % is not active or does not exist.', p_discount_id;
    END IF;

    -- Apply to all items in cart (ignore duplicates)
    INSERT INTO product_discounts(product_id, discount_id)
    SELECT sci.product_id, p_discount_id
    FROM shopping_cart_items sci
    WHERE sci.customer_id = p_customer_id
    ON CONFLICT (product_id, discount_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_product_availabilities(
    p_customer_id INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
v_item RECORD;
    v_store RECORD;
    v_remaining_qty INTEGER;
BEGIN
FOR v_item IN
SELECT product_id, quantity
FROM shopping_cart_items
WHERE customer_id = p_customer_id
    LOOP
        v_remaining_qty := v_item.quantity;

FOR v_store IN
SELECT quantity
FROM inventory
WHERE product_id = v_item.product_id AND quantity > 0
ORDER BY quantity DESC
    LOOP
            EXIT WHEN v_remaining_qty <= 0;
v_remaining_qty := v_remaining_qty - LEAST(v_remaining_qty, v_store.quantity);
END LOOP;

        IF v_remaining_qty > 0 THEN
            RETURN FALSE; -- Cannot fulfill this item
END IF;
END LOOP;

RETURN TRUE;
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
    RETURNS TABLE(store_id INT, store_name TEXT, quantity INT) LANGUAGE sql AS $$
SELECT
    i.store_id,
    s.name AS store_name,
    i.quantity
FROM inventory i
         JOIN stores s ON i.store_id = s.id
WHERE i.product_id = p_product_id
  AND i.quantity > 0;
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


CREATE OR REPLACE FUNCTION list_category()
    RETURNS SETOF categories LANGUAGE sql AS $$
SELECT * FROM categories;
$$;

CREATE OR REPLACE FUNCTION list_book_categories()
    RETURNS TABLE(sub_category_id INT, sub_category_name TEXT, category_name TEXT) LANGUAGE sql AS $$
SELECT sc.id, sc.name, c.name
FROM sub_categories sc
         JOIN categories c ON sc.category_id = c.id;
$$;

CREATE OR REPLACE FUNCTION list_book_category_by_language(p_language TEXT)
    RETURNS TABLE(sub_category_id INT, sub_category_name TEXT, category_name TEXT) LANGUAGE sql AS $$
SELECT DISTINCT sc.id, sc.name, c.name
FROM book_products bp
         JOIN sub_categories sc ON bp.sub_category_id = sc.id
         JOIN categories c ON sc.category_id = c.id
WHERE bp.language = p_language;
$$;

CREATE OR REPLACE FUNCTION search_book_by_language(p_language TEXT)
    RETURNS SETOF book_products LANGUAGE sql AS $$
SELECT * FROM book_products WHERE language = p_language;
$$;

CREATE OR REPLACE FUNCTION search_products_by_name(p_title TEXT)
    RETURNS TABLE (
        product_id INT,
        sku VARCHAR,
        title TEXT,
        product_type product_type,
        brand_id INT,
        base_price NUMERIC,
        description TEXT
    ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            p.id,
            p.sku,
            p.name::TEXT,
            p.product_type,
            p.brand_id,
            p.base_price,
            p.description
        FROM products p
        WHERE p.name ILIKE '%' || p_title || '%';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_order_detail(p_order_id INTEGER)
    RETURNS TABLE (
                      order_id INTEGER,
                      product_id INTEGER,
                      product_name VARCHAR,
                      quantity INTEGER,
                      unit_price NUMERIC,
                      discount_id INTEGER,
                      store_id INTEGER
                  ) AS $$
BEGIN
    RETURN QUERY
        SELECT
            od.order_id,
            od.product_id,
            p.name,
            od.quantity,
            od.unit_price,
            od.discount_id,
            od.store_id
        FROM order_details od
                 JOIN products p ON od.product_id = p.id
        WHERE od.order_id = p_order_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_order_status(p_order_id INTEGER)
    RETURNS order_status AS $$
DECLARE
    v_status order_status;
BEGIN
    SELECT status INTO v_status
    FROM orders
    WHERE id = p_order_id;

    RETURN v_status;
END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION register_customer(
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT,
    p_password_hash TEXT
) RETURNS INTEGER AS $$
DECLARE
    v_contact_id INTEGER;
    v_customer_id INTEGER;
BEGIN
    -- Ensure the email doesn't already exist
    IF EXISTS (SELECT 1 FROM contacts WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email % is already registered.', p_email;
    END IF;

    -- Create contact with only email (no phone)
    INSERT INTO contacts (email)
    VALUES (p_email)
    RETURNING id INTO v_contact_id;

    -- Create customer linked to contact
    INSERT INTO customers (first_name, last_name, contact_id, password_hash)
    VALUES (p_first_name, p_last_name, v_contact_id, p_password_hash)
    RETURNING id INTO v_customer_id;

    RETURN v_customer_id;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION login_customer(
    p_email TEXT,
    p_password_hash TEXT
) RETURNS INTEGER AS $$
DECLARE
    v_customer_id INTEGER;
BEGIN
    SELECT c.id
    INTO v_customer_id
    FROM customers c
             JOIN contacts ct ON c.contact_id = ct.id
    WHERE ct.email = p_email AND c.password_hash = p_password_hash;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid email or password.';
    END IF;

    RETURN v_customer_id;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION update_customer_phone(
    p_customer_id INTEGER,
    p_phone TEXT
) RETURNS VOID AS $$
DECLARE
    v_contact_id INTEGER;
BEGIN
    SELECT contact_id INTO v_contact_id
    FROM customers
    WHERE id = p_customer_id;

    IF v_contact_id IS NULL THEN
        RAISE EXCEPTION 'Customer not found or missing contact.';
    END IF;

    UPDATE contacts
    SET phone = p_phone
    WHERE id = v_contact_id;
END;
$$ LANGUAGE plpgsql;
