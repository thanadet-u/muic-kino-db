-- Contacts for customers, stores, publishers
INSERT INTO contacts (email, phone) VALUES
                                        ('somchai.s@email.com', '+6621234567'),
                                        ('nareerat.p@email.com', '+6622345678'),
                                        ('manop.t@email.com', '+6623456789'),
                                        ('siriwan.k@email.com', '+6634567890'),
                                        ('takeshi.y@email.com', '+6624567890'),
                                        ('siamparagon@kinokuniya.co.th', '+6626111222'),
                                        ('emquartier@kinokuniya.co.th', '+6626222333'),
                                        ('centralworld@kinokuniya.co.th', '+6626333444'),
                                        ('nanmeebooks@publisher.co.th', '+6627444555'),
                                        ('amarin@publisher.co.th', '+6627555666'),
                                        ('seed@publisher.co.th', '+6627666777'),
                                        ('dokya@publisher.co.th', '+6627888999');

-- Customers
INSERT INTO customers (first_name, last_name, contact_id) VALUES
                                                              ('Somchai', 'Srisuk', 1),
                                                              ('Nareerat', 'Pattanapong', 2),
                                                              ('Manop', 'Thongyai', 3),
                                                              ('Siriwan', 'Kittisak', 4),
                                                              ('Takeshi', 'Yamamoto', 5);

-- Customer addresses
INSERT INTO customer_addresses (customer_id, street, city, state, postal_code, country, address_type) VALUES
                                                                                                          (1, '12 Sukhumvit Soi 22', 'Bangkok', NULL, '10110', 'Thailand', 'billing'),
                                                                                                          (1, '88/1 Siam Paragon', 'Bangkok', NULL, '10330', 'Thailand', 'shipping'),
                                                                                                          (2, '45 Charoen Krung Road', 'Bangkok', NULL, '10500', 'Thailand', 'billing'),
                                                                                                          (3, '78 Nimmanhaemin Road', 'Chiang Mai', NULL, '50200', 'Thailand', 'billing'),
                                                                                                          (4, '22 Beach Road', 'Phuket', NULL, '83100', 'Thailand', 'billing');

-- Stores
INSERT INTO stores (name, contact_id) VALUES
                                          ('Kinokuniya Siam Paragon', 6),
                                          ('Kinokuniya EmQuartier', 7),
                                          ('Kinokuniya CentralWorld', 8);

-- Store addresses
INSERT INTO store_addresses (store_id, street, city, state, postal_code, country) VALUES
                                                                                      (1, '991 Siam Paragon, 3rd Floor', 'Bangkok', NULL, '10330', 'Thailand'),
                                                                                      (2, '693 EmQuartier, 5th Floor', 'Bangkok', NULL, '10110', 'Thailand'),
                                                                                      (3, '999 CentralWorld, 6th Floor', 'Bangkok', NULL, '10330', 'Thailand');

-- Brands
INSERT INTO brands (name, country) VALUES
                                       ('Moleskine', 'Italy'),             -- id = 1
                                       ('Zebra', 'Japan'),                 -- id = 2
                                       ('Midori', 'Japan'),                -- id = 3
                                       ('Siam Paragon', 'Thailand'),       -- id = 4
                                       ('Jim Thompson', 'Thailand'),       -- id = 5
                                       ('Nanmeebooks Publishing', 'Thailand'), -- id = 6
                                       ('Amarin Books', 'Thailand');       -- id = 7

-- Publishers
INSERT INTO publishers (name, contact_id) VALUES
                                              ('Nanmeebooks', 9),
                                              ('Amarin Printing', 10),
                                              ('SE-EDUCATION', 11),
                                              ('Dokya', 12);

-- Authors
INSERT INTO authors (first_name, last_name) VALUES
                                                ('Pramoedya', 'Ananta Toer'),
                                                ('Chart', 'Korbjitti'),
                                                ('Veeraporn', 'Nitiprapha'),
                                                ('Haruki', 'Murakami'),
                                                ('J.K.', 'Rowling'),
                                                ('Liang', 'Yusheng'),
                                                ('Sanmao', 'Chen'),
                                                ('Kenzaburo', 'Oe'),
                                                ('George', 'Orwell'),
                                                ('Yu', 'Hua');

-- Categories
INSERT INTO categories (name, parent_id) VALUES
                                             ('Books', NULL),
                                             ('Thai Literature', 1),
                                             ('International Fiction', 1),
                                             ('Business & Economics', 1),
                                             ('Travel Guides', 1),
                                             ('Thailand Travel', 5),
                                             ('Stationery', NULL),
                                             ('Japanese Pens', 7),
                                             ('Journals', 7),
                                             ('Merchandise', NULL),
                                             ('Thai Silk Bookmarks', 10),
                                             ('Totebags', 10);

-- Products
INSERT INTO products (sku, name, description, product_type, base_price, category_id, brand_id) VALUES
-- Books (brand_id 6 or 7)
('TH-BK001', 'Mad Dog & Co.', 'Thai contemporary novel', 'book', 350, 2, 6),
('TH-BK002', 'Harry Potter Vol 1 (Thai)', 'Thai translation', 'book', 450, 3, 6),
('TH-BK003', 'Bangkok Guide 2023', 'City travel guide', 'book', 295, 6, 7),
('TH-BK004', 'Thai Business Culture', 'Business practices in Thailand', 'book', 420, 4, 7),
('TH-BK005', 'Norwegian Wood', 'Japanese novel by Murakami', 'book', 390, 3, 7),
('TH-BK006', 'To Live', 'Modern Chinese novel', 'book', 320, 3, 6),
('TH-BK007', '1984', 'Dystopian novel', 'book', 310, 3, 6),
('TH-BK008', 'Stories of the Sahara', 'Travel essays by Sanmao', 'book', 360, 3, 6),
('TH-BK009', 'The Wandering Earth', 'Chinese sci-fi short stories', 'book', 410, 3, 6),
-- Stationery
('TH-ST001', 'Zebra Sarasa Clip Pen', '0.5mm gel ink pen', 'stationery', 55, 8, 2),
('TH-ST002', 'Midori MD Notebook', 'A5 blank notebook', 'stationery', 650, 9, 3),
-- Merchandise
('TH-ME001', 'Thai Silk Bookmark', 'Handmade Thai silk', 'merch', 199, 11, 5),
('TH-ME002', 'Kinokuniya Tote Bag', 'Limited edition', 'merch', 350, 12, 4);
-- Book products
INSERT INTO book_products (product_id, isbn, author_id, publisher_id, publication_date) VALUES
                                                                                            (1, '9786161830892', 2, 1, '2020-03-15'),   -- Chart Korbjitti
                                                                                            (2, '9789740200477', 5, 1, '2021-11-30'),   -- J.K. Rowling
                                                                                            (3, '9786163884050', 6, 2, '2023-01-10'),   -- Bangkok Travel Guides
                                                                                            (4, '9786160023637', 7, 4, '2022-08-22');   -- Thai Business Institute

-- Non-book products
INSERT INTO non_book_products (product_id, item_type, specifications) VALUES
                                                                          (5, 'Pen', '{"color": "black", "tip_size": "0.5mm", "made_in": "Japan"}'),
                                                                          (6, 'Notebook', '{"size": "A5", "pages": 192, "paper_weight": "70gsm"}'),
                                                                          (7, 'Bookmark', '{"material": "Thai silk", "design": "Traditional pattern"}'),
                                                                          (8, 'Bag', '{"size": "38x42cm", "material": "Cotton canvas", "feature": "Water resistant"}');

-- Memberships
INSERT INTO memberships (customer_id, membership_number, join_date, expiry_date, points_balance, discount_percentage) VALUES
                                                                                                                          (1, 'KINO-TH-001', '2023-01-15', '2024-01-15', 3500, 10.00),
                                                                                                                          (2, 'KINO-TH-002', '2023-03-22', '2024-03-22', 1250, 5.00),
                                                                                                                          (5, 'KINO-TH-003', '2023-05-10', '2024-05-10', 5000, 15.00);

-- Discounts
INSERT INTO discounts (name, discount_type, value, start_date, end_date, is_active) VALUES
                                                                                        ('Thai Book Festival', 'percentage', 20.00, '2023-08-01', '2023-08-31', true),
                                                                                        ('Stationery Sale', 'fixed', 50.00, '2023-07-15', '2023-09-15', true),
                                                                                        ('Member Birthday', 'percentage', 15.00, '2023-01-01', '2023-12-31', true);

-- Product discounts
INSERT INTO product_discounts (product_id, discount_id, final_price) VALUES
                                                                         (1, 1, 280.00),    -- 20% off Thai novel
                                                                         (5, 2, 5.00),      -- 50 THB off pen
                                                                         (7, 1, 159.20),    -- 20% off bookmark
                                                                         (2, 3, 382.50);    -- 15% off Harry Potter (member discount)

-- Inventory
INSERT INTO inventory (store_id, product_id, quantity, restock_threshold) VALUES
-- Siam Paragon store
(1, 1, 35, 10),
(1, 2, 25, 5),
(1, 5, 50, 20),
(1, 7, 15, 5),
-- EmQuartier store
(2, 2, 18, 5),
(2, 3, 22, 8),
(2, 6, 10, 3),
(2, 8, 40, 15),
-- CentralWorld store
(3, 1, 4, 5),    -- Low stock
(3, 4, 30, 10),
(3, 5, 12, 20),   -- Low stock
(3, 7, 3, 5);     -- Low stock

-- Shopping cart items
INSERT INTO shopping_cart_items (customer_id, product_id, quantity) VALUES
                                                                        (1, 2, 1),  -- Somchai: Harry Potter Thai edition
                                                                        (1, 5, 3),  -- 3 Japanese pens
                                                                        (3, 3, 1),  -- Manop: Bangkok Guide
                                                                        (5, 6, 1);  -- Takeshi: Midori notebook

-- Orders
INSERT INTO orders (customer_id, store_id, order_date, status, payment_method, transaction_id) VALUES
                                                                                                   (1, 1, '2023-07-12 14:30:00', 'delivered', 'credit_card', 'KINO-TXN-1001'),
                                                                                                   (2, 2, '2023-07-18 11:15:00', 'shipped', 'promptpay', 'KINO-TXN-1002'),
                                                                                                   (5, 3, '2023-07-20 16:45:00', 'processing', 'credit_card', 'KINO-TXN-1003'),
                                                                                                   (3, 1, '2023-07-21 10:00:00', 'pending', 'bank_transfer', 'KINO-TXN-1004');

-- Order details
INSERT INTO order_details (order_id, product_id, quantity, unit_price, discount_id) VALUES
                                                                                        (1, 1, 1, 350.00, 1),     -- Thai novel with 20% discount
                                                                                        (1, 5, 2, 55.00, 2),      -- Pens with 50 THB discount
                                                                                        (2, 2, 1, 450.00, NULL),
                                                                                        (3, 6, 1, 650.00, NULL),
                                                                                        (4, 3, 1, 295.00, NULL),
                                                                                        (4, 7, 2, 199.00, 1);     -- Bookmarks with 20% discount

-- Restocks
INSERT INTO restocks (store_id, product_id, quantity, restocked_by, notes) VALUES
                                                                               (3, 1, 20, 'Store Manager', 'Restock popular Thai novel'),
                                                                               (3, 5, 30, 'Assistant Manager', 'Pen shipment from Japan'),
                                                                               (3, 7, 25, 'Inventory Staff', 'New silk bookmark stock');

-- Restock alerts
INSERT INTO restock_alerts (inventory_id, product_id, store_id, quantity, restock_threshold, alert_message) VALUES
                                                                                                                (9, 1, 3, 4, 5, 'Thai novel stock low at CentralWorld'),
                                                                                                                (11, 5, 3, 12, 20, 'Pens need restocking at CentralWorld'),
                                                                                                                (12, 7, 3, 3, 5, 'Silk bookmarks nearly out of stock');