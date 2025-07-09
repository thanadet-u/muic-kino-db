CREATE OR REPLACE FUNCTION trigger_restock_alert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity < NEW.restock_threshold THEN
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
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
