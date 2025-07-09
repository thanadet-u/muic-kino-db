-- Populate contacts (12 rows)
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

-- Populate customers with password hashes (10 rows)
INSERT INTO customers (first_name, last_name, contact_id, password_hash) VALUES
                                                                             ('Somchai', 'Srisuk', 1, 'hashed_password_1'),
                                                                             ('Nareerat', 'Pattanapong', 2, 'hashed_password_2'),
                                                                             ('Manop', 'Thongyai', 3, 'hashed_password_3'),
                                                                             ('Siriwan', 'Kittisak', 4, 'hashed_password_4'),
                                                                             ('Takeshi', 'Yamamoto', 5, 'hashed_password_5'),
                                                                             ('Supawadee', 'Jirasuk', NULL, 'hashed_password_6'),
                                                                             ('Kenji', 'Tanaka', NULL, 'hashed_password_7'),
                                                                             ('Araya', 'Chompoo', NULL, 'hashed_password_8'),
                                                                             ('Chaiwat', 'Somboon', NULL, 'hashed_password_9'),
                                                                             ('Yui', 'Nakamura', NULL, 'hashed_password_10');

-- Populate customer addresses with default flags (10 rows)
INSERT INTO customer_addresses (customer_id, street, city, state, postal_code, country, address_type, is_default) VALUES
                                                                                                                      (1, '12 Sukhumvit Soi 22', 'Bangkok', NULL, '10110', 'Thailand', 'billing', true),
                                                                                                                      (1, '88/1 Siam Paragon', 'Bangkok', NULL, '10330', 'Thailand', 'shipping', true),
                                                                                                                      (2, '45 Charoen Krung Road', 'Bangkok', NULL, '10500', 'Thailand', 'billing', true),
                                                                                                                      (3, '78 Nimmanhaemin Road', 'Chiang Mai', NULL, '50200', 'Thailand', 'billing', true),
                                                                                                                      (4, '22 Beach Road', 'Phuket', NULL, '83100', 'Thailand', 'billing', true),
                                                                                                                      (6, '100 Rama IV Road', 'Bangkok', NULL, '10500', 'Thailand', 'billing', true),
                                                                                                                      (7, '55 Silom Road', 'Bangkok', NULL, '10500', 'Thailand', 'billing', true),
                                                                                                                      (8, '33 Ratchadaphisek Road', 'Bangkok', NULL, '10310', 'Thailand', 'billing', true),
                                                                                                                      (9, '12 Tha Phae Road', 'Chiang Mai', NULL, '50200', 'Thailand', 'billing', true),
                                                                                                                      (10, '9 Patong Beach Road', 'Phuket', NULL, '83150', 'Thailand', 'billing', true);

-- Populate stores (3 rows)
INSERT INTO stores (name, contact_id) VALUES
                                          ('Kinokuniya Siam Paragon', 6),
                                          ('Kinokuniya EmQuartier', 7),
                                          ('Kinokuniya CentralWorld', 8);

-- Populate store addresses (3 rows)
INSERT INTO store_addresses (store_id, street, city, state, postal_code, country) VALUES
                                                                                      (1, '991 Siam Paragon, 3rd Floor', 'Bangkok', NULL, '10330', 'Thailand'),
                                                                                      (2, '693 EmQuartier, 5th Floor', 'Bangkok', NULL, '10110', 'Thailand'),
                                                                                      (3, '999 CentralWorld, 6th Floor', 'Bangkok', NULL, '10330', 'Thailand');

-- Populate brands (10 rows)
INSERT INTO brands (name, country) VALUES
                                       ('Moleskine', 'Italy'),
                                       ('Zebra', 'Japan'),
                                       ('Midori', 'Japan'),
                                       ('Siam Paragon', 'Thailand'),
                                       ('Jim Thompson', 'Thailand'),
                                       ('Nanmeebooks Publishing', 'Thailand'),
                                       ('Amarin Books', 'Thailand'),
                                       ('SE-ED', 'Thailand'),
                                       ('Dokya', 'Thailand'),
                                       ('Kinokuniya', 'Japan');

-- Populate publishers (10 rows)
INSERT INTO publishers (name, contact_id) VALUES
                                              ('Nanmeebooks', 9),
                                              ('Amarin Printing', 10),
                                              ('SE-EDUCATION', 11),
                                              ('Dokya', 12),
                                              ('Penguin Random House', NULL),
                                              ('HarperCollins', NULL),
                                              ('Shogakukan', NULL),
                                              ('Kadokawa', NULL),
                                              ('Bungeishunju', NULL),
                                              ('Chuang Yi', NULL);

-- Populate authors (10 rows)
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

-- Populate categories (6 rows)
INSERT INTO categories (name) VALUES
                                  ('Books'),
                                  ('Stationery'),
                                  ('Merchandise'),
                                  ('Manga'),
                                  ('Art & Design'),
                                  ('Children Books');

-- Populate sub_categories (10 rows)
INSERT INTO sub_categories (name, category_id) VALUES
                                                   ('Thai Literature', 1),
                                                   ('International Fiction', 1),
                                                   ('Business & Economics', 1),
                                                   ('Travel Guides', 1),
                                                   ('Japanese Pens', 2),
                                                   ('Journals', 2),
                                                   ('Thai Silk Bookmarks', 3),
                                                   ('Totebags', 3),
                                                   ('Shonen Manga', 4),
                                                   ('Art Books', 5);

-- Populate products (20 rows)
INSERT INTO products (sku, name, description, product_type, base_price, brand_id) VALUES
-- Books
('TH-BK001', 'Mad Dog & Co.', 'Thai contemporary novel', 'book', 350.00, 6),
('TH-BK002', 'Harry Potter Vol 1 (Thai)', 'Thai translation', 'book', 450.00, 6),
('TH-BK003', 'Bangkok Guide 2023', 'City travel guide', 'book', 295.00, 7),
('TH-BK004', 'Thai Business Culture', 'Business practices in Thailand', 'book', 420.00, 7),
('TH-BK005', 'Norwegian Wood', 'Japanese novel by Murakami', 'book', 390.00, 5),
('TH-BK006', 'To Live', 'Modern Chinese novel', 'book', 320.00, 6),
('TH-BK007', '1984', 'Dystopian novel', 'book', 310.00, 5),
('TH-BK008', 'Stories of the Sahara', 'Travel essays by Sanmao', 'book', 360.00, 6),
('TH-BK009', 'The Wandering Earth', 'Chinese sci-fi short stories', 'book', 410.00, 6),
('TH-BK010', 'One Piece Vol. 100', 'Japanese manga series', 'book', 200.00, 9),
-- Stationery
('TH-ST001', 'Zebra Sarasa Clip Pen', '0.5mm gel ink pen', 'stationery', 55.00, 2),
('TH-ST002', 'Midori MD Notebook', 'A5 blank notebook', 'stationery', 650.00, 3),
('TH-ST003', 'Moleskine Limited Edition', 'Special edition notebook', 'stationery', 850.00, 1),
('TH-ST004', 'Pentel Brush Pen', 'Japanese calligraphy pen', 'stationery', 220.00, 2),
('TH-ST005', 'Tombow Dual Brush', 'Art markers set', 'stationery', 1200.00, 2),
-- Merchandise
('TH-ME001', 'Thai Silk Bookmark', 'Handmade Thai silk', 'merch', 199.00, 5),
('TH-ME002', 'Kinokuniya Tote Bag', 'Limited edition', 'merch', 350.00, 4),
('TH-ME003', 'Japanese Washi Tape Set', 'Decorative tapes', 'merch', 299.00, 10),
('TH-ME004', 'Anime Figure', 'Collectible figure', 'merch', 1200.00, 10),
('TH-ME005', 'Book Sleeve', 'Protective cover for books', 'merch', 450.00, 10);

-- Populate book_products (10 rows)
INSERT INTO book_products (product_id, isbn, author_id, publisher_id, publication_date, sub_category_id, language) VALUES
                                                                                                                       (1, '9786161830892', 2, 1, '2020-03-15', 1, 'Thai'),
                                                                                                                       (2, '9789740200477', 5, 1, '2021-11-30', 2, 'Thai'),
                                                                                                                       (3, '9786163884050', 8, 2, '2023-01-10', 4, 'English'),
                                                                                                                       (4, '9786160023637', 3, 4, '2022-08-22', 3, 'Thai'),
                                                                                                                       (5, '9784101001545', 4, 6, '1987-09-04', 2, 'Japanese'),
                                                                                                                       (6, '9787532761763', 10, 10, '1993-06-01', 2, 'Chinese'),
                                                                                                                       (7, '9780451524935', 9, 5, '1949-06-08', 2, 'English'),
                                                                                                                       (8, '9789573317249', 7, 10, '1976-01-01', 2, 'Chinese'),
                                                                                                                       (9, '9787536484270', 6, 10, '2008-01-01', 2, 'Chinese'),
                                                                                                                       (10, '9784088820673', 4, 7, '2021-09-03', 9, 'Japanese');

-- Populate non_book_products (10 rows)
INSERT INTO non_book_products (product_id, item_type, specifications) VALUES
                                                                          (11, 'Pen', '{"color": "black", "tip_size": "0.5mm", "made_in": "Japan"}'),
                                                                          (12, 'Notebook', '{"size": "A5", "pages": 192, "paper_weight": "70gsm"}'),
                                                                          (13, 'Notebook', '{"size": "A4", "pages": 240, "cover": "hardcover"}'),
                                                                          (14, 'Brush Pen', '{"brush_size": "medium", "ink_type": "water-based"}'),
                                                                          (15, 'Art Markers', '{"colors": 24, "alcohol_based": true}'),
                                                                          (16, 'Bookmark', '{"material": "Thai silk", "design": "Traditional pattern"}'),
                                                                          (17, 'Tote Bag', '{"size": "38x42cm", "material": "Cotton canvas", "feature": "Water resistant"}'),
                                                                          (18, 'Stationery Set', '{"pieces": 10, "styles": ["floral", "geometric"]}'),
                                                                          (19, 'Collectible', '{"character": "Anime", "height_cm": 15, "material": "PVC"}'),
                                                                          (20, 'Book Cover', '{"size": "A5", "material": "Neoprene", "waterproof": true}');

-- Populate memberships (10 rows)
INSERT INTO memberships (customer_id, membership_number, join_date, expiry_date, points_balance, discount_percentage) VALUES
                                                                                                                          (1, 'KINO-TH-001', '2023-01-15', '2024-01-15', 3500, 10.00),
                                                                                                                          (2, 'KINO-TH-002', '2023-03-22', '2024-03-22', 1250, 5.00),
                                                                                                                          (3, 'KINO-TH-003', '2023-02-10', '2026-02-10', 5000, 15.00),
                                                                                                                          (4, 'KINO-TH-004', '2023-04-05', '2024-04-05', 800, 5.00),
                                                                                                                          (5, 'KINO-TH-005', '2023-05-20', '2025-05-20', 4200, 12.00),
                                                                                                                          (6, 'KINO-TH-006', '2023-06-15', '2024-06-15', 1500, 8.00),
                                                                                                                          (7, 'KINO-TH-007', '2023-03-01', '2024-03-01', 3000, 10.00),
                                                                                                                          (8, 'KINO-TH-008', '2023-07-10', '2026-07-10', 200, 5.00),
                                                                                                                          (9, 'KINO-TH-009', '2023-01-05', '2024-01-05', 6000, 15.00),
                                                                                                                          (10, 'KINO-TH-010', '2023-04-18', '2026-04-18', 3500, 10.00);

-- Populate discounts (10 rows)
INSERT INTO discounts (name, discount_type, value, start_date, end_date, is_active) VALUES
                                                                                        ('Thai Book Festival', 'percentage', 20.00, '2023-08-01', '2023-08-31', true),
                                                                                        ('Stationery Sale', 'fixed', 50.00, '2023-07-15', '2023-09-15', true),
                                                                                        ('Member Birthday', 'percentage', 15.00, '2023-01-01', '2023-12-31', true),
                                                                                        ('Manga Week', 'percentage', 10.00, '2023-09-01', '2023-09-07', true),
                                                                                        ('New Member Welcome', 'percentage', 10.00, '2023-01-01', '2023-12-31', true),
                                                                                        ('Clearance Sale', 'fixed', 100.00, '2023-10-01', '2023-10-31', true),
                                                                                        ('Premium Member Discount', 'percentage', 20.00, '2023-01-01', '2023-12-31', true),
                                                                                        ('Art Supplies Promotion', 'percentage', 15.00, '2023-08-15', '2023-09-15', true),
                                                                                        ('Travel Guide Special', 'fixed', 50.00, '2023-07-20', '2023-08-20', true),
                                                                                        ('Back to School', 'percentage', 25.00, '2023-05-15', '2023-06-15', false);

-- Populate product_discounts (10 rows)
INSERT INTO product_discounts (product_id, discount_id, final_price) VALUES
                                                                         (1, 1, 280.00),
                                                                         (11, 2, 5.00),
                                                                         (16, 1, 159.20),
                                                                         (2, 3, 382.50),
                                                                         (10, 4, 180.00),
                                                                         (15, 8, 1020.00),
                                                                         (3, 9, 245.00),
                                                                         (5, 7, 312.00),
                                                                         (13, 6, 750.00),
                                                                         (19, 10, 900.00);

-- Populate inventory (30 rows - 10 per store)
-- Store 1 (Siam Paragon)
INSERT INTO inventory (store_id, product_id, quantity, restock_threshold) VALUES
                                                                              (1, 1, 35, 10),
                                                                              (1, 2, 25, 5),
                                                                              (1, 3, 18, 5),
                                                                              (1, 4, 12, 5),
                                                                              (1, 5, 20, 5),
                                                                              (1, 6, 15, 5),
                                                                              (1, 7, 8, 5),
                                                                              (1, 8, 10, 5),
                                                                              (1, 9, 5, 3),
                                                                              (1, 10, 30, 10);

-- Store 2 (EmQuartier)
INSERT INTO inventory (store_id, product_id, quantity, restock_threshold) VALUES
                                                                              (2, 11, 50, 20),
                                                                              (2, 12, 22, 8),
                                                                              (2, 13, 15, 5),
                                                                              (2, 14, 30, 10),
                                                                              (2, 15, 12, 5),
                                                                              (2, 16, 25, 10),
                                                                              (2, 17, 40, 15),
                                                                              (2, 18, 18, 10),
                                                                              (2, 19, 7, 5),
                                                                              (2, 20, 25, 10);

-- Store 3 (CentralWorld)
INSERT INTO inventory (store_id, product_id, quantity, restock_threshold) VALUES
                                                                              (3, 1, 4, 5),
                                                                              (3, 5, 8, 5),
                                                                              (3, 10, 15, 5),
                                                                              (3, 11, 12, 20),
                                                                              (3, 12, 6, 5),
                                                                              (3, 13, 9, 5),
                                                                              (3, 14, 10, 5),
                                                                              (3, 16, 3, 5),
                                                                              (3, 17, 8, 5),
                                                                              (3, 20, 4, 5);