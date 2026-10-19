# MaterialTrack — rencana implementasi

## Tahap 1: pemeriksaan proyek (selesai)

- Flutter 3.47.7 stable; Dart 3.13.5; batas SDK proyek `^3.13.5`.
- Target proyek hanya Android dan iOS. Lingkungan kerja Windows.
- `lib/main.dart` masih aplikasi counter bawaan; satu widget test counter.
- Dependensi aplikasi: Flutter, cupertino_icons. Pengujian: flutter_test, flutter_lints.
- Android SDK 36.0.0 tersedia; lisensi diterima. Tidak ada perangkat Android terhubung saat pemeriksaan.
- Visual Studio belum tersedia, tidak menghalangi target Android/iOS.
- iOS memerlukan macOS dan Xcode; tidak dapat dibangun di mesin ini.
- Application ID masih `com.example.calculator_truck`; signing release masih debug. Identitas final dan signing produksi perlu disiapkan sebelum distribusi.
- Baseline: `flutter analyze` bersih; `flutter test` lulus satu test template. Belum menguji fitur MaterialTrack atau build APK.
- Tidak ditemukan AGENTS.md. Tidak ada kode bisnis atau database lama yang perlu dimigrasikan.

## Keputusan implementasi

- Nama tampilan MaterialTrack; nama package Dart tetap `calculator_truck` agar tidak perlu migrasi import. Nama tampilan dipusatkan di konfigurasi aplikasi; label native disesuaikan saat MVP.
- Provider untuk state management, SQLite melalui sqflite untuk data lokal.
- Tambahkan dependensi hanya saat dipakai: provider, sqflite, path, intl; kemudian excel, pdf, path_provider, share_plus untuk laporan. Resolusi versi mengikuti SDK terpasang, bukan versi tebakan.
- Offline terlebih dahulu. Backend, login, sinkronisasi, PostgreSQL belum diperlukan.
- Uang disimpan integer Rupiah. Volume disimpan integer sepersejuta m³, maksimum enam desimal. Parser Indonesia menolak input ambigu/tidak valid; harga tidak negatif, volume harus lebih dari nol.
- Perkalian menggunakan integer dengan pembulatan half-up ke Rupiah per subtotal. Tetapkan batas nilai input agar aman terhadap overflow SQLite. Diskon tidak boleh melebihi subtotal ditambah biaya dan kirim.
- Harga jual kosong berbeda dengan harga jual nol. Agregat keuntungan hanya menghitung transaksi yang memiliki harga jual; jumlah transaksi dengan harga jual ditampilkan.
- Tanggal bisnis disimpan eksplisit sebagai `YYYY-MM-DD` lokal, waktu beserta offset disimpan terpisah. Jangan mengubah tanggal bisnis melalui UTC. Indonesia mempunyai tiga zona waktu; gunakan tanggal perangkat, tampilkan zona pada laporan.
- Material berbeda wilayah/spesifikasi dapat berupa entri berbeda. Harga default bukan harga pasar. Transaksi menyimpan snapshot identitas material dan semua harga.
- Belum ada sumber pasar terverifikasi. Tampilkan “Harga pasar belum tersedia”; pembaruan online belum aktif. Tidak ada harga, endpoint, atau keberhasilan simulasi.

## Struktur bertahap

```text
lib/
  main.dart
  app.dart
  models/           # material, transaksi, hasil perhitungan
  data/             # database, migrasi, repository
  services/         # kalkulasi, ekspor, integrasi harga ketika tersedia
  state/            # ChangeNotifier melalui Provider
  screens/          # dashboard, kalkulator, material, spreadsheet, riwayat, harga
test/
docs/
```

Buat folder/file ketika implementasinya dibutuhkan, bukan scaffold kosong.

## Tahap 2: MVP lokal

1. Implementasikan parser, kalkulasi integer, format Indonesia, test contoh 24,17 × 370.000 = 8.942.900 dan validasi batas.
2. Tambahkan SQLite versi 1 dengan migrasi inkremental, foreign key aktif, CHECK constraints dan indeks tanggal/material. Uji persistensi melalui database file sementara yang dibuka ulang; test menggunakan SQLite desktop bila diperlukan.
3. Tabel awal: materials, material_price_history, loads, load_change_history. Pemasok/wilayah berupa field terstruktur pada material dan snapshot transaksi; tabel master terpisah ditambahkan ketika perlu pengelolaan independen.
4. Material: tambah/edit/nonaktifkan, default modal/jual per wilayah, riwayat perubahan harga dalam transaksi database atomik. Material yang dipakai transaksi tidak dihapus.
5. Kalkulator: Hitung, Simpan, Reset, Salin; metadata kendaraan, pemasok, wilayah, catatan dan tanggal. Harga khusus transaksi tidak mengubah default. Cegah simpan ganda dan tangani kegagalan tanpa menghilangkan formulir.
6. Dashboard memakai agregasi database hari terpilih. Navigasi bawah empat tujuan utama; harga, riwayat dan pengaturan melalui menu tambahan.
7. Spreadsheet harian horizontal dengan seluruh kolom; filter tanggal/material/wilayah/pemasok/kendaraan, pencarian, edit dengan audit dan konfirmasi, hapus dengan konfirmasi. Rekap mingguan/bulanan dan riwayat rentang tanggal.
8. XLSX dan PDF memakai query/filter yang sama dengan tampilan, angka numerik dan total nyata. Nama `MaterialTrack_YYYY-MM-DD`; simpan di penyimpanan aplikasi dan bagikan melalui share sheet. Jangan meminta akses seluruh penyimpanan.
9. Uji hasil ekspor, snapshot harga, filter tanggal, persistensi, material baru, kondisi kosong, kegagalan database dan UI. Jalankan analyze/test setiap bagian sebelum lanjut.

## Tahap 3: harga pasar

1. Evaluasi sumber satu per satu: dokumentasi, izin, cakupan, satuan, spesifikasi, tanggal, batas akses dan kredensial. Catat URL sumber dan hasil evaluasi; belum ada klaim cakupan nasional.
2. Tambahkan migrasi market_price_sources, market_prices, price_update_logs dan application_settings ketika integrasi pertama tersedia. Simpan jenis data, status validasi, waktu publikasi/pengambilan/berlaku dan metadata sumber.
3. Indeks dan harga pekerjaan tidak ditampilkan sebagai harga material per m³. Konversi hanya jika faktor konversinya sah dan terdokumentasi.
4. Backend baru diperlukan untuk kredensial dan penjadwalan: pilih FastAPI dengan scheduler server, timeout, retry terbatas/backoff, rate limit, validasi dan log. PostgreSQL hanya bila akses banyak pengguna/perangkat benar-benar dibutuhkan.
5. Flutter membaca referensi tervalidasi; kegagalan mempertahankan data terakhir dengan label kedaluwarsa. Pembaruan tidak pernah mengubah modal aktual atau transaksi lama.
6. Pengaturan menampilkan sumber, cakupan kosong, status, log dan jadwal nyata. Tombol pembaruan tanpa konfigurasi menjelaskan layanan belum aktif.

## Tahap 4: validasi dan distribusi

- Tutup seluruh 15 skenario pengujian pada permintaan; bedakan unit, widget, integrasi perangkat dan pemeriksaan manual.
- Uji Android perangkat/emulator, font besar, keyboard, tabel horizontal dan berbagi file.
- Dokumentasikan instalasi, lokasi database, batas presisi, rumus biaya, konfigurasi sumber dan pemulihan kesalahan.
- Build APK debug lebih dahulu; release sesudah identitas aplikasi dan signing produksi disetujui. Jangan menyatakan APK selesai sebelum build berhasil.
- Tidak melakukan migrasi destruktif, menghapus data pengguna, atau memasukkan secret ke Flutter.

## Status saat ini

Tahap 1 selesai. Aplikasi masih template; MVP, ekspor, database dan integrasi pasar belum diimplementasikan. Berikutnya: Tahap 2 langkah 1 (logika perhitungan beserta pengujian), kemudian SQLite dan UI bertahap.
