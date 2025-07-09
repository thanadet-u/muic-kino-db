DROP TRIGGER IF EXISTS trg_restock_alert ON inventory;


CREATE OR REPLACE FUNCTION trigger_restock_alert_and_restock()
    RETURNS TRIGGER AS $$
DECLARE
v_restock_qty INTEGER := 20;
    v_recent_alert_count INTEGER;
    v_recent_restock_count INTEGER;
BEGIN
    IF NEW.quantity < NEW.restock_threshold THEN
        -- Check for recent alert in last 24 hours
SELECT COUNT(*) INTO v_recent_alert_count
FROM restock_alerts
WHERE inventory_id = NEW.id
  AND alert_time > NOW() - INTERVAL '1 hour';

-- Check for recent restock in last 24 hours
SELECT COUNT(*) INTO v_recent_restock_count
FROM restocks r
         JOIN inventory i ON r.store_id = i.store_id AND r.product_id = i.product_id
WHERE i.id = NEW.id
  AND r.restock_date > NOW() - INTERVAL '1 hour';

IF v_recent_alert_count = 0 THEN
            -- Insert alert only if none recent
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
END IF;

        IF v_recent_restock_count = 0 THEN
            -- Create restock only if none recent
            PERFORM create_restock(NEW.id, v_restock_qty, 'system', 'Auto restock triggered by low inventory');
END IF;
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;




CREATE TRIGGER trg_restock_alert
    AFTER UPDATE ON inventory
    FOR EACH ROW
    WHEN (OLD.quantity IS DISTINCT FROM NEW.quantity)
EXECUTE FUNCTION trigger_restock_alert_and_restock();

