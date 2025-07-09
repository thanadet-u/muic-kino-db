-- 1. Drop existing trigger if any
DROP TRIGGER IF EXISTS trg_restock_alert ON inventory;

-- 2. Create the trigger function
CREATE OR REPLACE FUNCTION trigger_restock_alert_and_restock()
    RETURNS TRIGGER AS $$
DECLARE
    v_restock_qty INTEGER := 20;
BEGIN
    IF NEW.quantity < NEW.restock_threshold THEN
        -- Log trigger firing
        RAISE NOTICE 'Trigger fired: quantity (NEW.%) < threshold (NEW.%)', NEW.quantity, NEW.restock_threshold;

        -- Insert alert
        INSERT INTO restock_alerts (
            inventory_id, product_id, store_id, quantity, restock_threshold, alert_message
        )
        VALUES (
                   NEW.id, NEW.product_id, NEW.store_id, NEW.quantity,
                   NEW.restock_threshold, 'Stock below restock threshold.'
               );

        -- Perform restock
        RAISE NOTICE 'Trigger performing restock of % units for inventory_id = %', v_restock_qty, NEW.id;

        PERFORM create_restock(
                NEW.id, v_restock_qty, 'system', 'Auto restock triggered by low inventory'
                );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Attach the trigger
CREATE TRIGGER trg_restock_alert
    AFTER UPDATE ON inventory
    FOR EACH ROW
    WHEN (OLD.quantity IS DISTINCT FROM NEW.quantity)
EXECUTE FUNCTION trigger_restock_alert_and_restock();



CREATE OR REPLACE FUNCTION enforce_single_default_address()
    RETURNS TRIGGER AS $$
BEGIN
    -- Only check if setting is_default = true
    IF NEW.is_default THEN
        -- If the new value is true and either it was false before or we're inserting:
        IF TG_OP = 'INSERT' OR (OLD.is_default IS DISTINCT FROM TRUE) THEN
            -- Unset previous defaults for same customer and type
            UPDATE customer_addresses
            SET is_default = false
            WHERE customer_id = NEW.customer_id
              AND address_type = NEW.address_type
              AND id <> NEW.id;
        END IF;

    ELSE
        -- If not setting this as default, and no other default exists, make this one default
        IF NOT EXISTS (
            SELECT 1 FROM customer_addresses
            WHERE customer_id = NEW.customer_id
              AND address_type = NEW.address_type
              AND id <> NEW.id
              AND is_default = true
        ) THEN
            NEW.is_default := true;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_enforce_single_default_address_update
    BEFORE UPDATE ON customer_addresses
    FOR EACH ROW
    WHEN (NEW.is_default IS DISTINCT FROM OLD.is_default)
EXECUTE FUNCTION enforce_single_default_address();
