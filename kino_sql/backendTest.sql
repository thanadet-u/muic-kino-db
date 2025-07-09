-- -- ✅ Valid add: product 1 total inventory = 35 + 4 = 39
-- SELECT add_to_cart(1, 1, 10);  -- Should succeed
--
-- -- ❌ Invalid add: exceed available inventory
-- SELECT add_to_cart(1, 1, 50);  -- Should raise exception
--
--

-- -- Manually update quantity to edge case
-- UPDATE shopping_cart_items SET quantity = 39 WHERE customer_id = 1 AND product_id = 1;
-- SELECT check_product_availabilities(1);  -- Should return true
-- --


-- -- Now push over the limit
-- UPDATE shopping_cart_items SET quantity = 40 WHERE customer_id = 1 AND product_id = 1;
-- SELECT check_product_availabilities(1);  -- Should return false


--
-- -- Add discounted product (e.g., ID 1 has discount price 280)
-- UPDATE shopping_cart_items SET quantity = 2 WHERE customer_id = 1 AND product_id = 1;
-- SELECT calculate_order_total(1);  -- Should return 560.00


-- Set a valid quantity that can be fulfilled (e.g., 10 units of product 1)
-- UPDATE shopping_cart_items SET quantity = 10 WHERE customer_id = 1 AND product_id = 1;
-- SELECT place_order(1, 'pending'::order_status, 'credit_card', 'TXN-ABC-1001') AS order_id;


--
-- -- 🧾 Order created
-- SELECT * FROM orders WHERE customer_id = 1 ORDER BY id DESC LIMIT 1;
--
-- -- 📦 Details split across stores
-- SELECT * FROM order_details WHERE order_id = (SELECT MAX(id) FROM orders WHERE customer_id = 1);
--
-- -- 🏬 Inventory deducted
-- SELECT * FROM inventory WHERE product_id = 1;


-- -- Cancel last order
-- SELECT edit_order_status((SELECT MAX(id) FROM orders WHERE customer_id = 1), 'cancelled');
--
-- -- ✅ Inventory should be restored
-- SELECT * FROM inventory WHERE product_id = 1;

SELECT * FROM inventory WHERE store_id = 1 AND product_id = 7;

-- Reduce product 7 @ store 1 below restock threshold (e.g., 4 < threshold 5)
UPDATE inventory SET quantity = 4 WHERE store_id = 1 AND product_id = 7;

-- ✅ Triggered alert and restock
SELECT * FROM restock_alerts WHERE product_id = 7 ORDER BY alert_time DESC;
SELECT * FROM restocks WHERE product_id = 7 ORDER BY restock_date DESC;

-- Inventory after restock (should be +20)
SELECT * FROM inventory WHERE store_id = 1 AND product_id = 7;




-- SELECT id, product_id, store_id, quantity, restock_threshold
-- FROM inventory
-- WHERE store_id = 1 AND product_id = 7;

