-- =============================================================
-- Fase 4 — RFM Analysis (menjawab Q1 & Q2 di business_questions.md)
-- =============================================================
-- PENTING: pakai customer_unique_id, BUKAN customer_id (lihat
-- methodology.md poin 4) -- customer_id unik per order, jadi kalau
-- salah pakai, semua pelanggan kelihatan "one-time buyer".
--
-- Order difilter WHERE order_status = 'delivered' -- konsisten
-- dengan temuan audit Fase 2 (97% order berstatus delivered),
-- supaya order batal/belum selesai tidak mendistorsi nilai Monetary.
-- =============================================================

-- Q1: RFM Analysis

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
 
order_value AS (
    -- Monetary dihitung dari total payment per order (bisa >1 baris payment per order)
    SELECT order_id, SUM(payment_value) AS order_total
    FROM order_payments
    GROUP BY order_id
),
 
reference_date AS (
    -- "Hari ini" = tanggal order terakhir di dataset (data historis 2016-2018,
    -- bukan tanggal real-time)
    SELECT MAX(order_purchase_timestamp) AS max_date FROM orders
),
 
customer_rfm_raw AS (
    SELECT
        co.customer_unique_id,
        MAX(co.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT co.order_id) AS frequency,
        SUM(ov.order_total) AS monetary
    FROM customer_orders co
    JOIN order_value ov ON co.order_id = ov.order_id
    GROUP BY co.customer_unique_id
),
 
customer_rfm_scored AS (
    SELECT
        crr.*,
        (SELECT max_date FROM reference_date)::date - crr.last_order_date::date AS recency_days,
        -- Tiebreaker ditambahkan (customer_unique_id) supaya hasil NTILE deterministik/reproducible
        NTILE(5) OVER (
            ORDER BY (SELECT max_date FROM reference_date)::date - crr.last_order_date::date DESC,
                     crr.customer_unique_id
        ) AS r_score,
        -- F score TIDAK pakai NTILE -- frequency 97% bernilai 1 (lihat methodology.md),
        -- NTILE pada kolom seskewed ini memecah nilai identik secara acak ke 5 kuintil,
        -- hasilnya tidak reproducible dan tidak mencerminkan perbedaan nyata.
        -- Dipakai business rule tetap sebagai gantinya:
        CASE
            WHEN crr.frequency = 1 THEN 1
            WHEN crr.frequency = 2 THEN 3
            WHEN crr.frequency >= 3 THEN 5
        END AS f_score,
        NTILE(5) OVER (ORDER BY crr.monetary ASC, crr.customer_unique_id) AS m_score
    FROM customer_rfm_raw crr
)
 
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    r_score, f_score, m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_code,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk (dulu loyal)'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost / Hibernating'
        ELSE 'Others'
    END AS rfm_segment
FROM customer_rfm_scored
ORDER BY monetary DESC;


-- Q2: Kontribusi Revenue - One-time Buyer vs Repeat Buyer

WITH customer_orders AS (
    SELECT c.customer_unique_id, o.order_id, o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
order_value AS (
    SELECT order_id, SUM(payment_value) AS order_total
    FROM order_payments
    GROUP BY order_id
),
customer_summary AS (
    SELECT
        co.customer_unique_id,
        COUNT(DISTINCT co.order_id) AS frequency,
        SUM(ov.order_total) AS monetary
    FROM customer_orders co
    JOIN order_value ov ON co.order_id = ov.order_id
    GROUP BY co.customer_unique_id
),
buyer_type AS (
    SELECT
        monetary,
        CASE WHEN frequency = 1 THEN 'One-time buyer' ELSE 'Repeat buyer' END customer_type
    FROM customer_summary
),
agg AS (
    SELECT
        customer_type,
        COUNT(*) AS jumlah_pelanggan,
        SUM(monetary) AS total_revenue
    FROM buyer_type
    GROUP BY customer_type
)
SELECT
    customer_type,
    jumlah_pelanggan,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(100.0 * total_revenue / SUM(total_revenue) OVER (), 2) AS pct_revenue,
    ROUND(100.0 * jumlah_pelanggan / SUM(jumlah_pelanggan) OVER (), 2) AS pct_pelanggan
FROM agg
ORDER BY total_revenue DESC;