-- =============================================================
-- Schema RAW — Dashboard Bisnis Olist E-Commerce
-- Fase 2: Data Audit & Exploration
-- =============================================================
-- Catatan penting:
-- Tabel di layer "raw" ini SENGAJA tidak diberi PRIMARY KEY /
-- FOREIGN KEY constraint. Tujuannya supaya proses load data
-- tidak gagal gara-gara masalah kualitas data (duplikasi,
-- orphan key, dll) — justru masalah itu yang mau kita TEMUKAN
-- lewat query audit di notebooks/data_audit.ipynb, bukan
-- disembunyikan lewat constraint yang menolak baris bermasalah.
-- Constraint yang lebih ketat baru ditambahkan nanti di layer
-- "curated"/analytics setelah audit selesai.
-- =============================================================
 
-- 1. Customers (99.441 baris)
-- customer_id unik per ORDER, customer_unique_id = identitas pelanggan asli
CREATE TABLE customers (
    customer_id                VARCHAR(50),
    customer_unique_id         VARCHAR(50),
    customer_zip_code_prefix   INTEGER,
    customer_city               VARCHAR(100),
    customer_state              VARCHAR(2)
);

-- 2. Sellers (3.095 baris)
CREATE TABLE sellers (
    seller_id                  VARCHAR(50),
    seller_zip_code_prefix     INTEGER,
    seller_city                 VARCHAR(100),
    seller_state                 VARCHAR(2)
);

-- 3. Products (32.951 baris)
CREATE TABLE products (
    product_id                     VARCHAR(50),
    product_category_name          VARCHAR(100),   -- nullable, masih Bahasa Portugis
    product_name_lenght             INTEGER,
    product_description_lenght      INTEGER,
    product_photos_qty              INTEGER,
    product_weight_g                INTEGER,
    product_length_cm               INTEGER,
    product_height_cm               INTEGER,
    product_width_cm                INTEGER
);

-- 4. Product Category Translation (71 baris)
CREATE TABLE product_category_translation (
    product_category_name          VARCHAR(100),
    product_category_name_english   VARCHAR(100)
);

-- 5. Geolocation (1.000.163 baris - tabel paling besar)
CREATE TABLE geolocation (
    geolocation_zip_code_prefix    INTEGER,
    geolocation_lat                  DOUBLE PRECISION,
    geolocation_lng                  DOUBLE PRECISION,
    geolocation_city                 VARCHAR(100),
    geolocation_state                 VARCHAR(2)
);

-- 6. Orders (99.441 baris)
-- Banyak kolom timestamp nullable (order yang belum sampai/dibatalkan)
CREATE TABLE orders (
    order_id                     VARCHAR(50),
    customer_id                  VARCHAR(50),
    order_status                 VARCHAR(20),
    order_purchase_timestamp     TIMESTAMP,
    order_approved_at            TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 7. Order Items (112.650 baris)
CREATE TABLE order_items (
    order_id                     VARCHAR(50),
    order_item_id                INTEGER,
    product_id                   VARCHAR(50),
    seller_id                    VARCHAR(50),
    shipping_limit_date          TIMESTAMP,
    price                        NUMERIC(10,2),
    freight_value                NUMERIC(10,2)
);

-- 8. Order Payments (103.886 baris)
-- 1 order bisa punya >1 baris payment (payment_sequential)
CREATE TABLE order_payments (
    order_id                VARCHAR(50),
    payment_sequential      INTEGER,
    payment_type            VARCHAR(20),
    payment_installments    INTEGER,
    payment_value           NUMERIC(10,2)
);

-- 9. Order Reviews (99.224 baris)
-- review_id TIDAK dipaksa unik di sini - perlu dicek dulu saat audit, 
-- dataset asli Olist punya kasus duplikasi review_id
CREATE TABLE order_reviews (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50),
    review_score            INTEGER,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);