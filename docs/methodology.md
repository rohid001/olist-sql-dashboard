# Metodologi — Dashboard Bisnis SQL Olist

Dokumen ini mencatat keputusan desain teknis sepanjang project dan alasannya.

---

## Pendekatan Umum: Audit-First, Constrain-Later

Proses dibagi jadi dua tahap yang sengaja dipisah:

1. **Fase 2-Load mentah tanpa constraint.** 9 tabel raw dibuat tanpa PRIMARY KEY/FOREIGN KEY sama sekali, supaya proses load 9 CSV tidak gagal karena masalah kualitas data yang belum diketahui.
2. **Fase 3-Audit dulu, baru constrain.** Setelah tahu persis di mana masalahnya (lewat query SQL langsung ke Postgres), constraint ditambahkan secara sadar — bukan trial-and-error yang berhenti di tengah jalan setiap ketemu error.

Alasan urutan ini: kalau constraint dipasang dari awal, proses load akan gagal di tengah jalan begitu ketemu baris bermasalah, tanpa tahu masalahnya seberapa luas. Dengan audit dulu, semua masalah terpetakan sekaligus sebelum keputusan desain diambil.

---

## Keputusan Desain Kunci

### 1. `order_reviews` — VIEW dedup, bukan modifikasi tabel asli
**Temuan:** 814 dari 99.224 baris (0,82%) punya `review_id` duplikat.
**Keputusan:** Tabel asli `order_reviews` dibiarkan apa adanya (tanpa PRIMARY KEY). Dibuat `VIEW order_reviews_dedup` yang mengambil 1 baris per `review_id`, prioritas `review_answer_timestamp` terbaru.
**Alasan:** Non-destructive — data asli tetap bisa diaudit ulang kapan saja, sementara analisis di Fase 4 yang butuh 1 baris per review tinggal query dari view.

### 2. Kategori produk yang hilang — translasi manual, bukan koreksi data
**Temuan:** 2 kategori (`pc_gamer`, 3 produk; `portateis_cozinha_e_preparadores_de_alimentos`, 10 produk) sama sekali tidak ada di `product_category_name_translation.csv` bawaan Kaggle — sudah dicek, bukan typo (tidak ada kandidat mirip di 71 kategori yang ada).
**Keputusan:** 2 baris translasi ditambahkan manual ke tabel `product_category_translation`.
**Alasan:** Data produknya sendiri valid, cuma lookup table resmi yang tidak lengkap. **Transparansi:** terjemahan `portable_kitchen_and_food_preparers` dibuat sendiri, bukan dari sumber resmi Kaggle.

### 3. 775 order tanpa `order_items` — dibiarkan, bukan data quality issue
**Temuan:** 775 order (mayoritas status `unavailable`/`canceled`) tidak punya baris `order_items` sama sekali.
**Keputusan:** Tidak ada perlakuan khusus — dibiarkan seperti itu.
**Alasan:** Ini business state yang valid (order dibatalkan sebelum item diproses), bukan error. Query revenue/RFM yang JOIN ke `order_items` akan otomatis mengecualikan 775 order ini, yang memang perilaku yang benar.

### 4. RFM harus pakai `customer_unique_id`, bukan `customer_id`
**Temuan:** `customer_id` unik per order (99.441 unik = 99.441 baris), sedangkan `customer_unique_id` cuma 96.096 unik — artinya sebagian pelanggan order lebih dari sekali dengan `customer_id` berbeda tiap kali.
**Keputusan:** Semua analisis retensi/RFM di Fase 4 wajib pakai `customer_unique_id`.
**Alasan:** Salah pakai kolom bikin semua pelanggan kelihatan "one-time buyer" — kesimpulan RFM jadi salah total.

### 5. Index manual di kolom Foreign Key
**Keputusan:** 7 index dibuat manual di kolom-kolom FK (`order_items.order_id`, `order_items.product_id`, dst).
**Alasan:** PostgreSQL otomatis membuat index hanya di sisi kolom yang **direferensikan** (PRIMARY KEY), bukan di kolom yang **mereferensi** (FOREIGN KEY). Tanpa index manual, JOIN multi-tabel di Fase 4 akan full table scan dan lambat, terutama ke `order_items` (112.650 baris) dan `geolocation` (1 juta baris).

---

### 6. F Score di RFM — business rule, bukan NTILE
**Temuan:** Validasi silang SQL vs Python menunjukkan F score (frequency) cuma cocok 22,6% antar dua cara hitung, padahal R score dan M score cocok >99%. Penyebabnya: **97% pelanggan (90.556 dari 93.357) punya `frequency = 1`** — nilai yang nyaris konstan. `NTILE(5) OVER (ORDER BY frequency ASC)` tanpa tiebreaker terpaksa memecah kelompok bernilai identik itu ke 5 kuintil secara acak, sehingga dua pelanggan yang sama-sama beli 1x bisa dapat skor F yang beda-beda tanpa alasan nyata, sehingga hasilnya juga tidak reproducible (beda tiap kali query dijalankan ulang).
**Keputusan:** F score diganti dari NTILE ke business rule tetap: `frequency=1 → skor 1`, `frequency=2 → skor 3`, `frequency>=3 → skor 5`.
**Alasan:** Kuantil (NTILE) cocok untuk variabel kontinu/beragam seperti Recency dan Monetary, tapi tidak cocok untuk variabel yang sangat skewed dan diskrit seperti Frequency di dataset ini. R score dan M score tetap pakai NTILE, tapi ditambah tiebreaker (`customer_unique_id`) supaya hasilnya deterministik.

### 7. `reference_date` untuk RFM/Churn pakai SEMUA order, bukan cuma delivered
**Keputusan:** `reference_date` (dipakai sebagai "hari ini" untuk hitung Recency dan status churn) dihitung dari `MAX(order_purchase_timestamp)` di **seluruh tabel `orders`**, bukan cuma yang `delivered`.
**Alasan:** Ini standar umum di analisis RFM/churn — pakai titik waktu terakhir yang diketahui di dataset sebagai "sekarang", terlepas dari status order tersebut. (Catatan proses: validasi awal sempat memakai basis yang berbeda — cuma order `delivered` — di script Python, yang membuat hasil kelihatan tidak cocok dengan SQL. Setelah disamakan basisnya, keduanya cocok. SQL di `sql/03_rfm_analysis.sql` dan `sql/05_churn_indicator.sql` tidak perlu diubah.)

---

## Referensi File

| File | Isi |
|---|---|
| `sql/01_schema.sql` | Schema raw, 9 tabel tanpa constraint |
| `notebooks/01_load_to_postgres.ipynb` | Load 9 CSV ke Postgres |
| `notebooks/02_data_audit.ipynb` | Audit lengkap: duplikasi, referential integrity, distribusi nilai |
| `sql/02_finalize_schema.sql` | PRIMARY KEY, FOREIGN KEY, INDEX, fix kategori, view dedup |
| `docs/fase3_schema_finalization.md` | Checklist & langkah eksekusi Fase 3 |
| `sql/03_rfm_analysis.sql` – `06_category_region_analysis.sql` | Query Fase 4 (Q1–Q9) |
| `notebooks/03_query_validation_viz.ipynb` | Visualisasi validasi per business question |
| `docs/fase4_query_development.md` | Checklist, langkah eksekusi, dan hasil validasi Fase 4 |
