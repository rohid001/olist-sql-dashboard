-- =============================================================
-- Fase 3 — Finalisasi Schema: PRIMARY KEY, FOREIGN KEY, INDEX
-- =============================================================
-- Urutan WAJIB: PRIMARY KEY dulu -> FOREIGN KEY -> INDEX
-- (FK butuh PK di tabel induk sudah ada; index paling aman, bisa
-- kapan saja). Kalau mau ekstra hati-hati, jalankan per STEP,
-- bukan sekali semua -- supaya kalau ada yang gagal, langsung
-- ketahuan di step mana.
-- =============================================================


-- =============================================================
-- STEP 1: PRIMARY KEY
-- Hanya untuk tabel yang SUDAH terbukti unik dari audit Fase 2.
-- order_reviews TIDAK di sini -- ada 814 duplikat review_id,
-- ditangani lewat VIEW dedup di STEP 2b, bukan PK di tabel asli.
-- =============================================================

ALTER TABLE customers ADD PRIMARY KEY (customer_id);
ALTER TABLE sellers ADD PRIMARY KEY (seller_id);
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE product_category_translation ADD PRIMARY KEY (product_category_name);
ALTER TABLE orders ADD PRIMARY KEY (order_id);

-- Composite key -- audit sudah konfirmasi 0 duplikasi untuk kombinasi ini
ALTER TABLE order_items ADD PRIMARY KEY (order_id, order_item_id);
ALTER TABLE order_payments ADD PRIMARY KEY (order_id, payment_sequential);


-- =============================================================
-- STEP 2a: Cek dulu 13 kategori yang tidak match sebelum lanjut
-- (informational -- tidak mengubah apa pun, cuma untuk kamu lihat)
-- =============================================================

SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL;

-- Hasil cek: bukan 13 kategori acak, tapi cuma 2 kategori yang memang
-- tidak ada di file translation resmi Kaggle (bukan typo -- sudah
-- dibandingkan ke 71 kategori yang ada, tidak ada yang mirip):
--   'pc_gamer'                                       (3 produk)
--   'portateis_cozinha_e_preparadores_de_alimentos'  (10 produk)
-- Ini isu yang cukup dikenal di dataset Olist. Solusinya: tambahkan
-- terjemahan manual (bukan koreksi data yang salah), baru FK bisa
-- ditambahkan tanpa pengecualian.

INSERT INTO product_category_translation (product_category_name, product_category_name_english)
VALUES
    ('pc_gamer', 'pc_gamer'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers');

-- Terjemahan di atas dibuat manual (bukan dari file resmi Kaggle) --
-- catat ini di docs/methodology.md untuk transparansi.


-- =============================================================
-- STEP 2b: VIEW dedup untuk order_reviews
-- Solusi untuk 814 review_id duplikat -- tabel asli TIDAK diubah,
-- cukup pakai view ini untuk analisis di Fase 4 yang butuh 1 baris
-- per review_id.
-- =============================================================

CREATE VIEW order_reviews_dedup AS
SELECT DISTINCT ON (review_id) *
FROM order_reviews
ORDER BY review_id, review_answer_timestamp DESC NULLS LAST;


-- =============================================================
-- STEP 3: FOREIGN KEY
-- Aman ditambahkan -- audit Fase 2 sudah pastikan 0 orphan untuk
-- semua relasi berikut.
-- =============================================================

ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_seller
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

ALTER TABLE order_payments
    ADD CONSTRAINT fk_order_payments_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_reviews
    ADD CONSTRAINT fk_order_reviews_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Sekarang aman ditambahkan -- 2 kategori yang hilang sudah di-insert
-- di STEP 2a. NULL tetap diperbolehkan (610 produk tanpa kategori),
-- FK cuma menolak nilai NON-NULL yang tidak match.
ALTER TABLE products
    ADD CONSTRAINT fk_products_category
    FOREIGN KEY (product_category_name) REFERENCES product_category_translation(product_category_name);


-- =============================================================
-- STEP 4: INDEX
-- PostgreSQL TIDAK otomatis bikin index di kolom FK (cuma di
-- kolom PK yang dirujuk) -- jadi ini perlu ditambah manual biar
-- JOIN di Fase 4 cepat.
-- =============================================================

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_seller_id ON order_items(seller_id);
CREATE INDEX idx_order_payments_order_id ON order_payments(order_id);
CREATE INDEX idx_order_reviews_order_id ON order_reviews(order_id);

-- Index tambahan untuk query time-series (revenue trend di Fase 4)
CREATE INDEX idx_orders_purchase_timestamp ON orders(order_purchase_timestamp);


-- =============================================================
-- VERIFIKASI: lihat semua constraint & index yang baru dibuat
-- =============================================================

SELECT conname, conrelid::regclass AS table_name, contype
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY table_name, contype;

SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;