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
















