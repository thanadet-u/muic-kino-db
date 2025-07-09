-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS restock_alerts CASCADE;
DROP TABLE IF EXISTS restocks CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS shopping_cart_items CASCADE;
DROP TABLE IF EXISTS memberships CASCADE;
DROP TABLE IF EXISTS book_products CASCADE;
DROP TABLE IF EXISTS non_book_products CASCADE;
DROP TABLE IF EXISTS product_discounts CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS discounts CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS brands CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;
DROP TABLE IF EXISTS store_addresses CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS customer_addresses CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS contacts CASCADE;

-- Drop ENUM types
DROP TYPE IF EXISTS product_type CASCADE;
DROP TYPE IF EXISTS discount_type CASCADE;
DROP TYPE IF EXISTS order_status CASCADE;

-- Create ENUM types
CREATE TYPE product_type AS ENUM ('book', 'stationery', 'merch');
CREATE TYPE discount_type AS ENUM ('percentage', 'fixed');
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');

-- Contacts Table
CREATE TABLE contacts (
                          id SERIAL PRIMARY KEY,
                          email VARCHAR(100) UNIQUE NOT NULL,
                          phone VARCHAR(20)
);

-- Customers Table
CREATE TABLE customers (
                           id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50) NOT NULL,
                           last_name VARCHAR(50) NOT NULL,
                           contact_id INTEGER REFERENCES contacts(id)
);

-- Customer Addresses Table (with is_default)
CREATE TABLE customer_addresses (
                                    id SERIAL PRIMARY KEY,
                                    customer_id INTEGER NOT NULL REFERENCES customers(id),
                                    street TEXT NOT NULL,
                                    city VARCHAR(50) NOT NULL,
                                    state VARCHAR(50),
                                    postal_code VARCHAR(20),
                                    country VARCHAR(50) NOT NULL,
                                    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('shipping', 'billing')),
                                    is_default BOOLEAN DEFAULT false
);

-- Ensure only one default address per type per customer
CREATE UNIQUE INDEX uniq_default_address_per_type
    ON customer_addresses(customer_id, address_type)
    WHERE is_default = true;

-- Stores Table
CREATE TABLE stores (
                        id SERIAL PRIMARY KEY,
                        name VARCHAR(100) NOT NULL,
                        contact_id INTEGER REFERENCES contacts(id)
);

-- Store Addresses Table
CREATE TABLE store_addresses (
                                 id SERIAL PRIMARY KEY,
                                 store_id INTEGER NOT NULL REFERENCES stores(id),
                                 street TEXT NOT NULL,
                                 city VARCHAR(50) NOT NULL,
                                 state VARCHAR(50),
                                 postal_code VARCHAR(20),
                                 country VARCHAR(50) NOT NULL
);

-- Publishers Table
CREATE TABLE publishers (
                            id SERIAL PRIMARY KEY,
                            name VARCHAR(100) NOT NULL,
                            contact_id INTEGER REFERENCES contacts(id)
);

-- Memberships Table
CREATE TABLE memberships (
                             id SERIAL PRIMARY KEY,
                             customer_id INTEGER NOT NULL REFERENCES customers(id),
                             membership_number VARCHAR(20) UNIQUE NOT NULL,
                             join_date DATE NOT NULL,
                             expiry_date DATE NOT NULL,
                             points_balance INTEGER DEFAULT 0 CHECK (points_balance >= 0),
                             discount_percentage NUMERIC(5,2) CHECK (discount_percentage BETWEEN 0 AND 100)
);

-- Categories Table
CREATE TABLE categories (
                            id SERIAL PRIMARY KEY,
                            name VARCHAR(50) NOT NULL,
                            parent_id INTEGER REFERENCES categories(id)
);

-- Brands Table
CREATE TABLE brands (
                        id SERIAL PRIMARY KEY,
                        name VARCHAR(50) NOT NULL,
                        country VARCHAR(50)
);

-- Authors Table
CREATE TABLE authors (
                         id SERIAL PRIMARY KEY,
                         first_name VARCHAR(50) NOT NULL,
                         last_name VARCHAR(50) NOT NULL
);

-- Products Table
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          sku VARCHAR(20) UNIQUE NOT NULL,
                          name VARCHAR(255) NOT NULL,
                          description TEXT,
                          product_type product_type NOT NULL,
                          base_price NUMERIC(10,2) NOT NULL CHECK (base_price >= 0),
                          category_id INTEGER REFERENCES categories(id),
                          brand_id INTEGER REFERENCES brands(id)
);

-- Book Products Table
CREATE TABLE book_products (
                               product_id INTEGER PRIMARY KEY REFERENCES products(id),
                               isbn CHAR(13) UNIQUE NOT NULL CHECK (LENGTH(isbn) = 13),
                               author_id INTEGER NOT NULL REFERENCES authors(id),
                               publisher_id INTEGER NOT NULL REFERENCES publishers(id),
                               publication_date DATE
);

-- Non-Book Products Table
CREATE TABLE non_book_products (
                                   product_id INTEGER PRIMARY KEY REFERENCES products(id),
                                   item_type VARCHAR(50) NOT NULL,
                                   specifications JSONB
);

-- Shopping Cart Items Table
CREATE TABLE shopping_cart_items (
                                     id SERIAL PRIMARY KEY,
                                     customer_id INTEGER NOT NULL REFERENCES customers(id),
                                     product_id INTEGER NOT NULL REFERENCES products(id),
                                     quantity INTEGER NOT NULL CHECK (quantity > 0),
                                     UNIQUE (customer_id, product_id)
);

-- Discounts Table
CREATE TABLE discounts (
                           id SERIAL PRIMARY KEY,
                           name VARCHAR(100) NOT NULL,
                           discount_type discount_type NOT NULL,
                           value NUMERIC(10,2) NOT NULL CHECK (value >= 0),
                           start_date DATE NOT NULL,
                           end_date DATE NOT NULL,
                           is_active BOOLEAN DEFAULT true,
                           CHECK (start_date <= end_date)
);

-- Product Discounts Table
CREATE TABLE product_discounts (
                                   id SERIAL PRIMARY KEY,
                                   product_id INTEGER NOT NULL REFERENCES products(id),
                                   discount_id INTEGER NOT NULL REFERENCES discounts(id),
                                   final_price NUMERIC(10,2) CHECK (final_price >= 0),
                                   UNIQUE (product_id, discount_id)
);

-- Inventory Table
CREATE TABLE inventory (
                           id SERIAL PRIMARY KEY,
                           store_id INTEGER NOT NULL REFERENCES stores(id),
                           product_id INTEGER NOT NULL REFERENCES products(id),
                           quantity INTEGER NOT NULL CHECK (quantity >= 0),
                           restock_threshold INTEGER NOT NULL CHECK (restock_threshold >= 0),
                           UNIQUE (store_id, product_id)
);

-- Restocks Table
CREATE TABLE restocks (
                          id SERIAL PRIMARY KEY,
                          store_id INTEGER NOT NULL,
                          product_id INTEGER NOT NULL,
                          quantity INTEGER NOT NULL CHECK (quantity > 0),
                          restock_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          restocked_by VARCHAR(100),
                          notes TEXT,
                          FOREIGN KEY (store_id, product_id)
                              REFERENCES inventory(store_id, product_id)
                              ON DELETE CASCADE
);

-- Restock Alerts Table
CREATE TABLE restock_alerts (
                                id SERIAL PRIMARY KEY,
                                inventory_id INTEGER NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
                                product_id INTEGER NOT NULL REFERENCES products(id),
                                store_id INTEGER NOT NULL REFERENCES stores(id),
                                quantity INTEGER NOT NULL,
                                restock_threshold INTEGER NOT NULL,
                                alert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                alert_message TEXT
);

-- Orders Table
CREATE TABLE orders (
                        id SERIAL PRIMARY KEY,
                        customer_id INTEGER NOT NULL REFERENCES customers(id),
                        store_id INTEGER REFERENCES stores(id),
                        order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        status order_status DEFAULT 'pending',
                        payment_method VARCHAR(50) NOT NULL,
                        transaction_id VARCHAR(100) UNIQUE
);

-- Order Details Table
CREATE TABLE order_details (
                               id SERIAL PRIMARY KEY,
                               order_id INTEGER NOT NULL REFERENCES orders(id),
                               product_id INTEGER NOT NULL REFERENCES products(id),
                               quantity INTEGER NOT NULL CHECK (quantity > 0),
                               unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
                               discount_id INTEGER REFERENCES discounts(id)
);

-- Indexes
CREATE INDEX idx_customers_email ON contacts(email);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_order_details_order ON order_details(order_id);
CREATE INDEX idx_discounts_active ON discounts(id) WHERE is_active = true;
