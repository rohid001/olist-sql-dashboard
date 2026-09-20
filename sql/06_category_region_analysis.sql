-- =============================================================
-- Fase 4 — Kategori Produk & Wilayah (menjawab Q8 & Q9)
-- =============================================================
 
 
-- =============================================================
-- Q8: Kategori Paling Profitable per State
-- Profit di sini disederhanakan sebagai (price - freight_value),
-- BUKAN profit akuntansi sesungguhnya (tidak ada data cost of goods
-- di dataset ini) -- anggap sebagai "margin kasar" saja.
-- =============================================================

WITH category_state_revenue AS (
    SELECT
        c.customer_state,
        COALESCE(t.product_category_name_english, 'uncategorized') AS category,
        SUM(oi.price - oi.freight_value) AS margin_kasar,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY 1, 2
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY customer_state ORDER BY margin_kasar DESC) AS rnk
    FROM category_state_revenue
)
SELECT
    customer_state,
    category,
    ROUND(margin_kasar, 2) AS margin_kasar,
    ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rnk = 1
ORDER BY margin_kasar DESC;

-- Q9: Revenue per Customer per State

WITH state_revenue AS (
    SELECT
        c.customer_state,
        SUM(oi.price) AS total_revenue,
        COUNT(DISTINCT c.customer_unique_id) AS jumlah_pelanggan,
        COUNT(DISTINCT o.order_id) AS jumlah_order
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT
    customer_state,
    ROUND(total_revenue, 2) AS total_revenue,
    jumlah_pelanggan,
    jumlah_order,
    ROUND(total_revenue / jumlah_pelanggan, 2) AS revenue_per_customer
FROM state_revenue
ORDER BY total_revenue DESC;