-- =============================================================
-- Fase 4 — Churn Indicator (menjawab Q6 & Q7 di business_questions.md)
-- =============================================================
-- "At Risk" didefinisikan sebagai: belum order lagi selama > 180 hari
-- dari tanggal order terakhir di dataset. Ini business rule yang bisa
-- diubah (misal jadi 90 atau 365 hari) sesuai kebutuhan diskusi lebih
-- lanjut -- bukan angka baku dari textbook.
-- =============================================================

-- Q6a: Rata-rata Jeda Antar-Order (untuk pelanggan repeat)

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
order_gaps AS (
    SELECT
        customer_unique_id,
        order_purchase_timestamp - LAG(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id ORDER BY order_purchase_timestamp) AS gap
    FROM customer_orders
)
SELECT
    ROUND(AVG(EXTRACT(DAY FROM gap)), 1) AS rata_rata_jeda_hari,
    COUNT(*) AS jumlah_pasangan_order -- jumlah "gap" yang terhitung, bukan jumlah pelanggan
FROM order_gaps
WHERE gap IS NOT NULL;

-- Q6b: Daftar Pelanggan dengan Status Churn Risk

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
reference_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date FROM orders
),
customer_last_order AS (
    SELECT
        customer_unique_id,
        MAX(order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT order_id) AS total_orders
    FROM customer_orders
    GROUP BY customer_unique_id
)
SELECT
    customer_unique_id,
    total_orders,
    last_order_date,
    (SELECT max_date FROM reference_date)::date - last_order_date::date AS hari_sejak_order_terakhir,
    CASE
        WHEN (SELECT max_date FROM reference_date)::date - last_order_date::date > 180 THEN 'At Risk'
        ELSE 'Active'
    END AS churn_status
FROM customer_last_order
ORDER BY hari_sejak_order_terakhir DESC;

-- Q7: Korelasi Review Score Rendah dengan Churn
-- (pakai order_reviews_dedup, BUKAN order_reviews, biar tidak
-- terpengaruh 814 baris duplikat -- lihat methodology.md poin 1)

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
reference_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date FROM orders
),
customer_status AS (
    SELECT
        customer_unique_id,
        MAX(order_purchase_timestamp) AS last_order_date,
        CASE
            WHEN (SELECT max_date FROM reference_date)::date - MAX(order_purchase_timestamp)::date > 180
            THEN 'At Risk' ELSE 'Active'
        END AS churn_status
    FROM customer_orders
    GROUP BY customer_unique_id
),
customer_avg_review AS (
    SELECT
        co.customer_unique_id,
        AVG(r.review_score) AS avg_review_score
    FROM customer_orders co
    JOIN order_reviews_dedup r ON co.order_id = r.order_id
    GROUP BY co.customer_unique_id
)
SELECT
    cs.churn_status,
    ROUND(AVG(car.avg_review_score), 2) AS rata_rata_reviews_score,
    COUNT(*) AS jumlah_pelanggan
FROM customer_status cs
JOIN customer_avg_review car ON cs.customer_unique_id = car.customer_unique_id
GROUP BY cs.churn_status;