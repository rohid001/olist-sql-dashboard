# Insight & Rekomendasi Bisnis-Dashboard Olist E-Commerce

---

## Ringkasan Eksekutif

Platform ini punya pertumbuhan revenue yang solid dari 2016-2018, tapi **struktur bisnisnya sangat bergantung pada akuisisi pelanggan baru secara terus-menerus**, bukan retensi, di mana sebesar 97% pelanggan cuma order sekali sepanjang hidupnya di platform ini. Masalah utama bukan "pelanggan lari" (churn klasik), tapi "pelanggan tidak pernah kembali sejak awal". Revenue terkonsentrasi di São Paulo murni karena skala pasar, dan kategori `health_beauty` terbukti jadi pemenang nasional yang layak dijadikan flagship.

---

## 1. Customer Value & Retention

**Temuan (Q1, Q2):** 90.556 dari 93.357 pelanggan (97%) cuma order **1 kali** sepanjang 2016–2018. Repeat buyer cuma 2.801 orang (3%), dan meski jumlahnya kecil, mereka menyumbang 5,6% dari total revenue, sedangkan sisanya (94,4%) datang dari pelanggan yang belanja sekali lalu tidak pernah kembali.

**Insight bisnis:** Ini bukan platform berbasis loyalitas (seperti marketplace subscription), tapi platform akuisisi — mirip pola umum e-commerce multi-vendor di mana pembeli sering loyal ke penjual tertentu, bukan ke platform. Segmen "kualitas tinggi" (Loyal Customers, Champions) secara alami kecil (1.693 dan 116 orang) bukan karena ada yang salah, tapi karena itu memang gambaran jujur perilaku pelanggan saat ini.

**Rekomendasi:**
- Buat insentif pembelian kedua (voucher/diskon khusus) untuk mendorong sebagian dari 97% one-time buyer supaya order minimal 1x lagi, dampaknya ke revenue total bisa besar mengingat skalanya
- Targetkan follow-up (email/notifikasi promo) ke segmen **"New Customers"** (36.141 one-time buyer yang baru saja order) dalam 30–60 hari pertama, sebelum mereka bergeser ke "Lost/Hibernating"
- Buat program VIP/eksklusif untuk 116 **Champions**, mereka sudah terbukti loyal dan bernilai tinggi, risiko kehilangan mereka lebih mahal daripada akuisisi pelanggan baru

---

## 2. Revenue & Growth Trend

**Temuan (Q3, Q4):** Revenue tumbuh stabil dari 2017 ke pertengahan 2018, dengan lonjakan tertinggi di **November 2017** (kemungkinan Black Friday Brasil). Beberapa kategori kecil tumbuh sangat pesat dari basis kecil (`small_appliances_home_oven`, `diapers_and_hygiene`), sementara beberapa kategori turun tajam: `security_and_services` (-100%), `cds_dvds_musicals` (-90%), `tablets_printing_image` (-80%).

**Insight bisnis:** Event musiman/promo besar terbukti berdampak nyata ke revenue. Di sisi lain, ada kategori yang tampaknya mengalami disrupsi struktural (CD/DVD, tablet printing kemungkinan tergerus pesatnya perkembangan digital), bukan sekadar fluktuasi musiman.

**Rekomendasi:**
- Alokasikan budget marketing lebih besar menjelang November, berdasarkan pola tahun sebelumnya
- Evaluasi ulang kategori yang menurun tajam (`cds_dvds_musicals`, `security_and_services`, `tablets_printing_image`), seperti pertimbangkan mengurangi fokus inventori/seller di kategori ini
- Kategori kecil yang tumbuh pesat (`small_appliances_home_oven`, `diapers_and_hygiene`) layak dipantau sebagai kandidat ekspansi, tapi jangan buat keputusan besar dahulu, basis datanya masih kecil (revenue 2017 di bawah R$1.000 untuk beberapa kategori ini)
- **Catatan penting:** pola musiman resmi (Q5) tidak valid dijadikan dasar keputusan "musim sepi September–Desember", itu artifact keterbatasan cakupan data (lihat `methodology.md`), bukan perilaku belanja asli

---

## 3. Churn / Customer Risk

**Temuan (Q6, Q7):** Rata-rata jeda antar-order pelanggan repeat adalah 78,8 hari. 59% pelanggan berstatus "At Risk" (>180 hari tanpa order), akan tetapi mayoritas mereka memang one-time buyer yang tidak pernah berniat order lagi, bukan pelanggan loyal yang menjauh. Review score **bukan** indikator churn yang kuat (selisih rata-rata Active vs At Risk cuma 0,06 poin).

**Insight bisnis:** Masalah utama bukan "kenapa pelanggan pergi?" (churn klasik), akan tetapi **"kenapa pelanggan tidak pernah kembali sejak awal"**. Kepuasan pelanggan (review score) sudah cukup tinggi secara umum (rata-rata di atas 4 dari 5), jadi kemungkinan besar penyebab tidak repeat order bukan soal kualitas layanan, melainkan faktor lain: sifat produk (barang yang jarang dibeli ulang), loyalitas ke seller tertentu, atau kompetisi platform lain.

**Rekomendasi:**
- Jangan fokuskan strategi retensi hanya pada "perbaiki kepuasan", review score tinggi ternyata tidak berkorelasi kuat dengan repeat purchase
- Perlu riset kualitatif tambahan (survei pelanggan) untuk memahami alasan sebenarnya di balik rendahnya repeat rate, data kuantitatif ini sudah menunjukkan ADA masalah, tapi tidak menjelaskan PENYEBABnya
- Untuk 2.801 repeat buyer, jadwalkan komunikasi retensi (reminder/promo) di sekitar hari ke-78 sejak order terakhir mereka — sebelum mereka lewat jendela waktu repeat order yang wajar

---

## 4. Kategori Produk & Wilayah

**Temuan (Q8, Q9):** Kategori `health_beauty` jadi kategori paling profitable di **14 dari 27 state**, dominasi nasional yang jelas. São Paulo (SP) menyumbang revenue **>3x lipat** dari state kedua (RJ), tapi revenue per customer relatif seragam di seluruh state top (R$129–156).

**Insight bisnis:** Dominasi SP murni soal **skala pasar** (jumlah pelanggan jauh lebih banyak), bukan karena pelanggan SP belanja lebih boros per orang. `health_beauty` terbukti jadi kategori "universal winner" yang laku hampir di semua wilayah, bukan cuma di kota besar.

**Rekomendasi:**
- Strategi ekspansi regional sebaiknya fokus ke **akuisisi pelanggan baru** di state non-SP (RJ, MG, RS, dst), bukan strategi "naikkan nilai belanja per orang", karena revenue per customer sudah relatif seragam, ruang pertumbuhan lebih besar ada di jumlah pelanggan
- Jadikan `health_beauty` kategori flagship untuk campaign nasional, mengingat daya tariknya merata di hampir semua wilayah
- Waspadai risiko konsentrasi bisnis di SP, karena gangguan logistik/ekonomi khusus di satu state ini berdampak besar ke revenue total platform; diversifikasi regional perlu jadi prioritas jangka menengah

---

## Ringkasan Prioritas (Kalau Cuma Bisa Pilih 3)

1. **Program insentif pembelian kedua**, dampak revenue paling besar, mengingat skala 90.556 one-time buyer
2. **Riset kualitatif alasan tidak repeat order**, data kuantitatif sudah menunjukkan masalahnya, tapi penyebabnya butuh digali lebih lanjut sebelum bikin solusi yang tepat sasaran
3. **Akuisisi pelanggan baru di luar SP**, dengan `health_beauty` sebagai kategori andalan campaign
