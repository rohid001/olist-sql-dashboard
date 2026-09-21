-- =============================================================
-- Fase 6 — Overview KPI (untuk halaman pertama dashboard)
-- Belum ada di Fase 4 karena bukan bagian dari 9 business question,
-- tapi perlu untuk kartu ringkasan di halaman Overview.
-- =============================================================

WITH base AS(
    SELECT
        o.order_id,
        c.customer_unique_id,
        oi.price,
        oi.seller_id
    FROM orders o
    JOIN customers c on o.customer_id = c.customer_id
    JOIN order_items oi on o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
),
review_avg AS (
    SELECT AVG(review_score) AS avg_review FROM order_reviews_dedup
)
SELECT
    COUNT(DISTINCT b.order_id) AS total_order,
    COUNT(DISTINCT b.customer_unique_id) AS total_pelanggan,
    ROUND(SUM(b.price), 2) AS total_revenue,
    ROUND(SUM(b.price)/COUNT(DISTINCT b.order_id), 2) AS avg_order_value,
    COUNT(DISTINCT b.seller_id) AS total_seller,
    ROUND((SELECT avg_review FROM review_avg), 2) AS avg_review_score
FROM base b;