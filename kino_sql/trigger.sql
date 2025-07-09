DROP TRIGGER IF EXISTS trg_restock_alert ON inventory;

CREATE OR REPLACE FUNCTION trigger_restock_alert_and_restock()
    RETURNS TRIGGER AS $$
DECLARE
v_restock_qty INTEGER := 20;
BEGIN
    IF NEW.quantity < NEW.restock_threshold THEN
        -- Insert restock alert
        INSERT INTO restock_alerts (
            inventory_id,
            product_id,
            store_id,
            quantity,
            restock_threshold,
            alert_message
        )
        VALUES (
            NEW.id,
            NEW.product_id,
            NEW.store_id,
            NEW.quantity,
            NEW.restock_threshold,
            'Stock below restock threshold.'
        );

        -- Immediately restock
        PERFORM create_restock(
            NEW.id,
            v_restock_qty,
            'system',
            'Auto restock triggered by low inventory'
        );
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;




CREATE TRIGGER trg_restock_alert
    AFTER UPDATE ON inventory
    FOR EACH ROW
    WHEN (OLD.quantity IS DISTINCT FROM NEW.quantity)
EXECUTE FUNCTION trigger_restock_alert_and_restock();
