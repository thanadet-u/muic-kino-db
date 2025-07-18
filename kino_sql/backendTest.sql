-- -- -- ✅ Valid add: product 1 total inventory = 35 + 4 = 39
-- -- SELECT add_to_cart(1, 1, 10);  -- Should succeed
-- --
-- -- -- ❌ Invalid add: exceed available inventory
-- -- SELECT add_to_cart(1, 1, 50);  -- Should raise exception
-- --
-- --
--
-- -- -- Manually update quantity to edge case
-- -- UPDATE shopping_cart_items SET quantity = 39 WHERE customer_id = 1 AND product_id = 1;
-- -- SELECT check_product_availabilities(1);  -- Should return true
-- -- --
--
--
-- -- -- Now push over the limit
-- -- UPDATE shopping_cart_items SET quantity = 40 WHERE customer_id = 1 AND product_id = 1;
-- -- SELECT check_product_availabilities(1);  -- Should return false
--
--
-- --
-- -- -- Add discounted product (e.g., ID 1 has discount price 280)
-- -- UPDATE shopping_cart_items SET quantity = 2 WHERE customer_id = 1 AND product_id = 1;
-- -- SELECT calculate_order_total(1);  -- Should return 560.00
--
--
-- -- Set a valid quantity that can be fulfilled (e.g., 10 units of product 1)
-- -- UPDATE shopping_cart_items SET quantity = 10 WHERE customer_id = 1 AND product_id = 1;
-- -- SELECT place_order(1, 'pending'::order_status, 'credit_card', 'TXN-ABC-1001') AS order_id;
--
--
-- --
-- -- -- 🧾 Order created
-- -- SELECT * FROM orders WHERE customer_id = 1 ORDER BY id DESC LIMIT 1;
-- --
-- -- -- 📦 Details split across stores
-- -- SELECT * FROM order_details WHERE order_id = (SELECT MAX(id) FROM orders WHERE customer_id = 1);
-- --
-- -- -- 🏬 Inventory deducted
-- -- SELECT * FROM inventory WHERE product_id = 1;
--
--
-- -- -- Cancel last order
-- -- SELECT edit_order_status((SELECT MAX(id) FROM orders WHERE customer_id = 1), 'cancelled');
-- --
-- -- -- ✅ Inventory should be restored
-- -- SELECT * FROM inventory WHERE product_id = 1;
--
--
--
-- -- -- Reduce product 7 @ store 1 below restock threshold (e.g., 4 < threshold 5)
-- UPDATE inventory SET quantity = 1 WHERE store_id = 1 AND product_id = 7;
-- --
-- -- -- ✅ Triggered alert and restock
-- -- SELECT * FROM restock_alerts WHERE product_id = 7 ORDER BY alert_time DESC;
-- -- SELECT * FROM restocks WHERE product_id = 7 ORDER BY restock_date DESC;
-- --
-- -- -- Inventory after restock (should be +20)
-- SELECT * FROM inventory WHERE store_id = 1 AND product_id = 7;
-- --
--
-- SELECT id, quantity, restock_threshold
-- FROM inventory
-- WHERE store_id = 1 AND product_id = 7;


SELECT add_to_cart(1, 1, 2);   -- Mad Dog & Co. (book, discounted to 280)
SELECT add_to_cart(1, 11, 3);  -- Zebra Sarasa Clip Pen (stationery, discounted to 5)
SELECT add_to_cart(1, 13, 1);  -- Moleskine Notebook (stationery, discounted to 750)
SELECT add_to_cart(1, 19, 2);  -- Anime Figure (merch, discounted to 900)

-- -- Check cart content
-- SELECT * FROM shopping_cart_items WHERE customer_id = 1;


-- Test order placement
-- SELECT place_order(
--                p_customer_id := 1,
--                p_status := 'pending'::order_status,
--                p_payment_method := 'credit_card',
--                p_transaction_id := 'TXN-ABC-1'
--        );


--
-- -- Before: Check current values
-- SELECT c.id, c.first_name, c.last_name, c.password_hash, ct.email, ct.phone
-- FROM customers c
--          JOIN contacts ct ON ct.id = c.contact_id
-- WHERE c.id = 1;
--
-- -- Call edit_customer to update customer info
-- SELECT edit_customer(
--                p_customer_id := 1,
--                p_first_name := 'SomchaiUpdated',
--                p_last_name := 'SrisukUpdated',
--                p_email := 'updated_somchai@email.com',
--                p_phone := '+6612345678',
--                p_password_hash := 'new_hashed_password_1'
--        );
--
-- -- After: Verify the changes
-- SELECT c.id, c.first_name, c.last_name, c.password_hash, ct.email, ct.phone
-- FROM customers c
--          JOIN contacts ct ON ct.id = c.contact_id
-- WHERE c.id = 1;




-- Add a new shipping address for customer 1, not specifying default
INSERT INTO customer_addresses (
    customer_id, street, city, state, postal_code, country, address_type
) VALUES (
             1, 'New Shipping Lane', 'Bangkok', NULL, '10120', 'Thailand', 'shipping'
         );

-- Check results
SELECT * FROM customer_addresses
WHERE customer_id = 1 AND address_type = 'shipping';
