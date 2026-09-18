-- =============================================================
-- Fase 4 — Revenue Trend (menjawab Q3, Q4, Q5 di business_questions.md)
-- =============================================================
-- Revenue = SUM(order_items.price) -- harga produk saja, TIDAK termasuk
-- freight_value (ongkos kirim dianggap pass-through cost, bukan revenue).
-- Difilter order_status = 'delivered' (lihat methodology.md).
--
-- CATATAN KETERBATASAN DATA: data 2016 sangat sedikit (toko baru mulai),
-- dan data 2018 tidak lengkap satu tahun penuh (dataset berhenti sekitar
-- Agustus-Oktober 2018). Perbandingan year-over-year di Q4 perlu
-- diinterpretasi dengan hati-hati karena periode yang tidak apple-to-apple.
-- =============================================================

-- Q3: Tren Revenue Bulanan + Q5: Growth Rate MoM

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS bulan,
        SUM(oi.price) AS revenue
    FROM orders o
    join order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT
    bulan,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY bulan), 2) AS revenue_bulan_sebelumnya,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY bulan))
        / NULLIF(LAG(revenue) OVER (ORDER BY bulan), 0), 2
    ) AS growth_mom_pct
FROM monthly_revenue
ORDER BY bulan;

-- Q5 (lanjutan): Pola Musiman - Revenue per Bulan-ke-N (digabung semua tahun)

SELECT
    DATE_PART('month', o.order_purchase_timestamp) AS bulan_ke,
    TO_CHAR(o.order_purchase_timestamp, 'Month') AS nama_bulan,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS jumlah_order
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1, 2
ORDER BY 1;

-- Q4: Kategori Produk - Growth 2017 vs 2018
-- (2016 dikecualikan, karena datanya terlalu sedikit untuk jadi baseline)

WITH category_yearly AS (
    SELECT
        COALESCE(t.product_category_name_english, 'uncategorized') AS category,
        DATE_PART('year', o.order_purchase_timestamp) AS tahun,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t on p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered' AND DATE_PART('year', o.order_purchase_timestamp) IN (2017, 2018)
    GROUP BY 1, 2 
),
category_growth AS (
    SELECT
        category,
        SUM(CASE WHEN tahun = 2017 THEN revenue ELSE 0 END) AS revenue_2017,
        SUM(CASE WHEN tahun = 2018 THEN revenue ELSE 0 END) AS revenue_2018
    FROM category_yearly
    GROUP BY category
)
SELECT
    category,
    ROUND(revenue_2017, 2) AS revenue_2017,
    ROUND(revenue_2018, 2) AS revenue_2018,
    ROUND(100.0 * (revenue_2018 - revenue_2017) / NULLIF(revenue_2017, 0), 2) AS growth_pct
FROM category_growth
WHERE revenue_2017 > 0 -- exclue kategori tanpa baseline 2017 (growth % tidak bermakna)
ORDER BY growth_pct DESC;
