# Business Questions — Dashboard Bisnis Olist E-Commerce

Pertanyaan disusun berdasarkan struktur data aktual (9 file, ±99.441 order, periode 2016–2018), bukan template generik. Setiap pertanyaan langsung terhubung ke kolom/tabel yang tersedia.

---

## 1. Customer Value & Retention (RFM)

**Q1.** Siapa pelanggan paling bernilai berdasarkan Recency, Frequency, Monetary (RFM)? Segmen mana yang layak diprioritaskan untuk program loyalitas?
> Catatan teknis penting: gunakan `customer_unique_id`, **bukan** `customer_id`, sebagai identitas pelanggan. `customer_id` unik per order (99.441 baris = 99.441 unique), sedangkan `customer_unique_id` hanya punya 96.096 nilai unik — artinya sebagian pelanggan melakukan lebih dari satu order dengan `customer_id` berbeda tiap kali. Kalau salah pakai kolom, hasil RFM akan salah total (semua pelanggan kelihatan "one-time buyer").

**Q2.** Berapa persentase pelanggan repeat-buyer vs one-time buyer? Berapa kontribusi revenue dari masing-masing segmen?

---

## 2. Revenue & Growth Trend

**Q3.** Bagaimana tren revenue bulanan sepanjang 2016–2018? Bulan/kuartal mana yang tumbuh paling tinggi, dan kapan terjadi penurunan tajam?

**Q4.** Kategori produk apa yang tumbuh revenue-nya paling cepat, dan mana yang stagnan/menurun? *(butuh join `olist_products` → `product_category_name_translation` dulu, karena nama kategori aslinya Bahasa Portugis)*

**Q5.** Berapa growth rate month-over-month (MoM)? Apakah ada pola musiman (lonjakan bulan tertentu, misal Black Friday Brasil di November)?

---

## 3. Churn / Customer Risk

**Q6.** Berapa rata-rata jeda antar-order untuk pelanggan repeat? Berdasarkan itu, pelanggan mana yang sudah lewat batas waktu wajar tanpa order lagi (indikasi churn)?

**Q7.** Apakah pelanggan yang memberi `review_score` rendah (1–2) pada order sebelumnya, cenderung tidak order lagi?

---

## 4. Kategori Produk & Wilayah

**Q8.** Kategori produk apa yang paling profitable (revenue dikurangi `freight_value`) di tiap `customer_state`?

**Q9.** State mana yang menyumbang revenue terbesar? Bagaimana perbandingannya dengan jumlah pelanggan di state tersebut (revenue per customer)?

---

## 5. Performa Pengiriman *(opsional — data sangat mendukung ini)*

**Q10.** Berapa rata-rata selisih antara tanggal pengiriman aktual (`order_delivered_customer_date`) dan estimasi (`order_estimated_delivery_date`)? Seller atau wilayah mana yang paling sering terlambat?

**Q11.** Apakah keterlambatan pengiriman berkorelasi dengan `review_score` yang lebih rendah?

---

## 6. Perilaku Pembayaran *(opsional)*

**Q12.** Metode pembayaran (`payment_type`) apa yang paling umum? Apakah jumlah cicilan (`payment_installments`) berkorelasi dengan nilai transaksi (`payment_value`)?

---

## Rekomendasi Prioritas

Untuk portfolio, **fokus dulu ke Q1–Q9** (4 kategori inti: RFM, Revenue Trend, Churn, Kategori & Wilayah) — ini yang sudah direncanakan di Fase 4 roadmap dan cukup untuk menunjukkan kemampuan SQL kompleks + storytelling bisnis.

Q10–Q12 (pengiriman & pembayaran) bagus untuk "bonus page" di dashboard kalau waktu masih ada, karena datanya kuat untuk window function tambahan (misal `RANK()` seller berdasarkan rata-rata keterlambatan).

## Data Quality yang Perlu Diperhatikan Saat Menjawab
- `review_comment_message` null di 58,7% baris, `review_comment_title` null di 88,3% — jangan andalkan analisis teks komentar sebagai sumber utama insight
- `order_approved_at`, `order_delivered_carrier_date`, `order_delivered_customer_date` punya null (order yang belum sampai/dibatalkan) — filter `order_status` sesuai kebutuhan analisis (misal hanya `delivered` untuk analisis waktu kirim)
- `product_category_name` null di 610 baris (1,85%) — putuskan strategi: exclude atau kategorikan sebagai "unknown"
