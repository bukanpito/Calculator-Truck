// Run with NODE_PATH pointing to a directory containing pptxgenjs.
const pptxgen = require('pptxgenjs');
const path = require('node:path');
const pptx = new pptxgen();
pptx.layout = 'LAYOUT_WIDE';
pptx.author = 'Alvitto Zaky';
pptx.subject = 'Presentasi konsep dan pratinjau aplikasi MaterialTrack';
pptx.title = 'MaterialTrack — Kalkulasi dan Pencatatan Muatan';
pptx.lang = 'id-ID';
pptx.theme = { headFontFace: 'Aptos Display', bodyFontFace: 'Aptos', lang: 'id-ID' };
const C = { green: '126B55', dark: '16382F', muted: '587068', bg: 'F4F7F6', white: 'FFFFFF' };
function text(s, value, x, y, w, h, extra = {}) {
  s.addText(value, { x, y, w, h, fontFace: 'Aptos', fontSize: 20, color: C.dark, margin: 0, breakLine: false, ...extra });
}
function slide(title, label = 'KONSEP & RENCANA') {
  const s = pptx.addSlide();
  s.background = { color: C.bg };
  s.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: 0.16, h: 7.5, fill: { color: C.green }, line: { color: C.green } });
  text(s, 'MATERIALTRACK', 0.65, 0.35, 8, 0.3, { fontSize: 13, bold: true, color: C.green, charSpacing: 3 });
  text(s, title, 0.65, 1, 12, 0.8, { fontSize: 34, bold: true });
  text(s, label, 0.65, 6.95, 10.8, 0.25, { fontSize: 10, color: C.muted });
  text(s, String(pptx._slides.length), 12, 6.95, 0.6, 0.25, { fontSize: 10, color: C.muted, align: 'right' });
  return s;
}
function bullets(s, items, y = 2.15) {
  items.forEach((item, i) => text(s, `•  ${item}`, 0.85, y + i * 0.78, 11.6, 0.64, { fontSize: 23 }));
}
function box(s, title, body, x, y, w = 3.8, h = 2.6) {
  s.addShape(pptx.ShapeType.roundRect, { x, y, w, h, rectRadius: 0.15, fill: { color: C.white }, line: { color: 'DCE7E2' }, radius: 0.15 });
  text(s, title, x + 0.22, y + 0.2, w - 0.44, h < 1.5 ? 0.32 : 0.65, { fontSize: h < 1.5 ? 18 : 21, bold: true, color: C.green });
  text(s, body, x + 0.22, y + (h < 1.5 ? 0.65 : 1), w - 0.44, h < 1.5 ? 0.45 : h - 1.2, { fontSize: h < 1.5 ? 16 : 18, valign: 'top' });
}
function shape(s, type, x, y, w, h, color, line = color) {
  s.addShape(pptx.ShapeType[type], { x, y, w, h, fill: { color }, line: { color: line }, radius: 0.2 });
}
function truck(s, x, y, scale = 1) {
  const r = (type, a, b, w, h, color) => shape(s, type, x + a * scale, y + b * scale, w * scale, h * scale, color);
  r('ellipse', 0, 2.45, 5.7, 0.22, 'E0EBE5');
  r('triangle', 0.55, 0.1, 2.1, 1.1, 'C8B798');
  r('triangle', 1.8, 0.2, 1.65, 1, 'B9A584');
  r('rect', 0.2, 1, 3.65, 1.05, C.green);
  for (let i = 0; i < 5; i++) r('rect', 0.45 + i * 0.67, 1.12, 0.05, 0.8, '80AE97');
  r('roundRect', 3.95, 1.15, 1.35, 0.95, '8DB9A4');
  r('rect', 4.16, 1.29, 0.65, 0.4, 'E7F3EE');
  r('rect', 0.2, 2.03, 5.2, 0.18, C.dark);
  for (const a of [0.85, 2.65, 4.55]) {
    r('ellipse', a, 1.94, 0.65, 0.65, C.dark);
    r('ellipse', a + 0.17, 2.11, 0.31, 0.31, 'C6D9D0');
  }
}
function phone(s, x, y, title, ios, screen = 'dashboard') {
  shape(s, 'roundRect', x, y, 2.5, 4.75, C.dark);
  shape(s, 'roundRect', x + 0.09, y + 0.1, 2.32, 4.53, 'F4F7F6');
  if (ios) shape(s, 'roundRect', x + 0.8, y + 0.17, 0.9, 0.18, C.dark);
  else shape(s, 'ellipse', x + 1.18, y + 0.17, 0.12, 0.12, C.dark);
  text(s, '9:41', x + 0.2, y + 0.19, 0.5, 0.2, { fontSize: 8 });
  text(s, 'MaterialTrack', x + 0.22, y + 0.6, 2.1, 0.3, { fontSize: 15, bold: true, color: C.green });
  shape(s, 'rect', x + 0.13, y + 1.02, 2.24, 0.27, 'DBEAE1');
  text(s, 'PRATINJAU • TIDAK DISIMPAN', x + 0.2, y + 1.08, 2.1, 0.12, { fontSize: 6.5, align: 'center' });
  text(s, title, x + 0.22, y + 1.48, 2.05, 0.3, { fontSize: 14, bold: true });
  if (screen === 'dashboard') {
    shape(s, 'roundRect', x + 0.2, y + 1.95, 2.1, 1.15, C.white);
    text(s, 'TOTAL MODAL HARI INI', x + 0.33, y + 2.1, 1.9, 0.2, { fontSize: 8 });
    text(s, 'Rp0', x + 0.33, y + 2.43, 1.8, 0.35, { fontSize: 24, bold: true, color: C.green });
    text(s, '0 muatan   •   0 m³', x + 0.33, y + 2.88, 1.9, 0.15, { fontSize: 9 });
    text(s, 'Belum ada muatan\n\nHarga pasar belum tersedia', x + 0.25, y + 3.4, 2, 0.65, { fontSize: 10, align: 'center' });
  } else {
    ['Pasir pasang', 'Volume        24,17 m³', 'Modal         Rp370.000/m³'].forEach((v, i) => {
      shape(s, 'roundRect', x + 0.2, y + 1.95 + i * 0.45, 2.1, 0.37, C.white);
      text(s, v, x + 0.3, y + 2.05 + i * 0.45, 1.9, 0.18, { fontSize: 10 });
    });
    text(s, 'CONTOH TOTAL MODAL', x + 0.25, y + 3.5, 2, 0.2, { fontSize: 8 });
    text(s, 'Rp8.942.900', x + 0.25, y + 3.82, 2, 0.35, { fontSize: 21, bold: true, color: C.green });
  }
  text(s, 'Beranda     Hitung     Rekap     Material', x + 0.18, y + 4.35, 2.15, 0.15, { fontSize: 6.8, align: 'center' });
}
let s = slide('Kalkulasi muatan. Pencatatan lebih teratur.', 'PRESENTASI PRODUK • VERSI PRATINJAU UI');
text(s, 'MaterialTrack', 0.8, 2.4, 7, 1, { fontSize: 58, bold: true, color: C.green });
text(s, 'Aplikasi pencatatan harga muatan\ntruk material berbasis m³.', 0.85, 3.7, 7, 1, { fontSize: 26 });
text(s, 'Alvitto Zaky | Portfolio untuk HR & Interview', 0.85, 5.2, 7.5, 0.45, { fontSize: 20, color: C.green, bold: true });
truck(s, 7.6, 3, 0.87);
s.addNotes('Pembuka 1 menit. Perkenalkan diri sebagai Alvitto Zaky. Jelaskan bahwa proyek berada pada tahap pratinjau UI, bukan aplikasi produksi. Jangan mengklaim fitur rencana sebagai hasil implementasi.');

s = slide('Alur presentasi interview', '30 MENIT PEMAPARAN + MAKSIMAL 30 MENIT DISKUSI');
box(s, 'Konteks • 5 menit', 'Masalah bisnis, pengguna sasaran, dan tujuan produk.', 0.65, 2.3);
box(s, 'Produk • 12 menit', 'Alur muatan, ilustrasi Android/iPhone, kalkulasi dan demo UI.', 4.75, 2.3);
box(s, 'Engineering • 13 menit', 'Keputusan teknis, batas implementasi, kualitas dan roadmap.', 8.85, 2.3);
text(s, 'Diskusi fleksibel hingga 30 menit; total sesi tidak melebihi 60 menit.', 0.85, 5.6, 11.6, 0.7, { fontSize: 24 });
s.addNotes('Agenda 1 menit. Tawarkan versi singkat bila HR mempunyai waktu terbatas. Alokasi 30 menit presentasi sudah termasuk demo; jangan menunggu satu jam untuk selesai.');

s = slide('Studi kasus: digitalisasi pencatatan muatan');
box(s, 'Fokus proyek', 'Mengubah kebutuhan usaha material menjadi alur mobile yang mudah dipahami.', 0.65, 2.3);
box(s, 'Bukti yang tersedia', 'Kode Flutter pratinjau, navigasi empat halaman, dokumentasi dan test UI.', 4.75, 2.3);
box(s, 'Batas klaim', 'Belum ada pengguna nyata, metrik dampak bisnis atau backend produksi.', 8.85, 2.3);
s.addNotes('2 menit. Jelaskan kontribusi pribadi yang benar-benar dapat dibuktikan. Jika menggunakan bantuan AI, jelaskan dengan jujur proses review dan pemahaman kode. Jangan mengaku memiliki pengalaman kerja atau dampak bisnis yang belum terjadi.');

s = slide('Masalah yang ingin diselesaikan');
bullets(s, ['Perhitungan volume dan biaya masih dilakukan terpisah.', 'Harga pemasok berubah menurut material, kualitas dan wilayah.', 'Catatan muatan sulit direkap menjadi laporan harian.', 'Estimasi keuntungan perlu memperhitungkan seluruh biaya.', 'Harga acuan pasar tidak selalu sama dengan harga modal aktual.']);

s = slide('Solusi: satu alur dari hitung hingga laporan');
box(s, '1. Hitung', 'Pilih material, isi volume dan harga modal. Tambahkan kirim, biaya dan diskon.', 0.65, 2.3);
box(s, '2. Catat', 'Simpan identitas truk, pemasok, wilayah dan snapshot harga transaksi.', 4.75, 2.3);
box(s, '3. Rekap', 'Lihat spreadsheet harian, filter riwayat, ekspor Excel dan PDF.', 8.85, 2.3);
text(s, 'Sasaran pengguna: pengusaha material, pemasok dan pengelola muatan truk.', 0.85, 5.55, 11.5, 0.7);

s = slide('Contoh perhitungan utama');
box(s, 'Volume', '24,17 m³', 0.65, 2.1, 3.8, 2);
box(s, 'Harga modal', 'Rp370.000 / m³', 4.75, 2.1, 3.8, 2);
box(s, 'Total material', 'Rp8.942.900', 8.85, 2.1, 3.8, 2);
text(s, 'Total modal = subtotal material + biaya tambahan + ongkos kirim − diskon', 0.85, 4.55, 11.6, 0.8, { fontSize: 24, bold: true });
text(s, 'Pada contoh ini biaya tambahan, kirim dan diskon bernilai Rp0.\nKeuntungan = volume × harga jual per m³ − total modal.', 0.85, 5.6, 11.5, 0.85, { fontSize: 21 });

s = slide('Gambaran UI aplikasi', 'ILUSTRASI LAYOUT • BUKAN SCREENSHOT APLIKASI');
const previews = [
  ['Dashboard', 'TOTAL MODAL HARI INI\nRp0\n\n0 muatan  •  0 m³\n\nBelum ada muatan'],
  ['Calculator', 'Pasir pasang\n24,17 m³\nRp370.000 / m³\n\nCONTOH TOTAL\nRp8.942.900'],
  ['Spreadsheet', 'Tanggal transaksi\n\nMaterial | Volume | Modal\n\nBelum ada transaksi'],
  ['Material', 'Pasir pasang\nPasir cor\nBatu split\nSirtu\nTanah urug'],
];
previews.forEach(([title, body], i) => {
  const x = 0.7 + i * 3.15;
  box(s, title, body, x, 2, 2.9, 4.3);
  text(s, 'Mode pratinjau', x + 0.2, 5.85, 2.5, 0.25, { fontSize: 11, color: C.muted });
});

s = slide('Satu konsep, dua platform mobile', 'MOCKUP ILUSTRATIF • BUKAN SCREENSHOT ATAU BUKTI BUILD iOS');
phone(s, 1.2, 1.95, 'Ringkasan hari ini', false);
phone(s, 4.4, 1.95, 'Kalkulasi muatan', true, 'calculator');
text(s, 'Android', 1.2, 6.76, 2.5, 0.2, { fontSize: 12, align: 'center' });
text(s, 'iPhone / iOS', 4.4, 6.76, 2.5, 0.2, { fontSize: 12, align: 'center' });
text(s, 'Konsisten, tenang, terbaca.', 7.65, 2.5, 4.8, 1, { fontSize: 30, bold: true, color: C.green });
text(s, 'Putih untuk ruang baca.\nHijau untuk fokus tindakan.\nAngka utama dibuat menonjol.\nNavigasi empat tujuan utama.', 7.65, 3.85, 4.7, 1.8, { fontSize: 22, breakLine: false });
s.addNotes('3 menit. Mockup berupa objek vektor PowerPoint yang bisa diedit, bukan screenshot perangkat. Android adalah prioritas implementasi. iOS masih target; pengujian memerlukan macOS dan Xcode.');

s = slide('Alur pengguna di lapangan', 'RANCANGAN ALUR • PENYIMPANAN BELUM AKTIF');
truck(s, 0.85, 2.2, 0.9);
box(s, '01  Muatan tiba', 'Identifikasi jenis material, truk dan pemasok.', 6.6, 2, 5.9, 1.3);
box(s, '02  Verifikasi biaya', 'Masukkan volume serta harga yang disepakati.', 6.6, 3.5, 5.9, 1.3);
box(s, '03  Catat dan rekap', 'Simpan transaksi; cocokkan laporan harian.', 6.6, 5, 5.9, 1.3);
s.addNotes('2 menit. Jelaskan konteks kerja nyata sebagai skenario, bukan hasil observasi yang sudah dilakukan. Harga pemasok tetap dapat diubah per transaksi.');

s = slide('Status aplikasi saat presentasi', 'STATUS NYATA • BELUM ADA APK HASIL BUILD');
box(s, 'Sudah tersedia', 'Empat halaman pratinjau.\nNavigasi antarhalaman.\nLabel data sementara.\nContoh tampilan kalkulasi.', 0.7, 2.1, 5.85, 3.8);
box(s, 'Belum diimplementasikan', 'Kalkulator interaktif dan validasi.\nDatabase dan penyimpanan.\nEdit transaksi dan filter.\nEkspor XLSX/PDF.\nIntegrasi harga pasar.', 6.8, 2.1, 5.85, 3.8);
text(s, 'Pemeriksaan saat pratinjau dibuat: flutter analyze bersih; satu widget test navigasi lulus.', 0.85, 6.2, 11.6, 0.45, { fontSize: 16, color: C.muted });

s = slide('Harga modal tetap dikontrol pengguna');
bullets(s, ['Harga default dapat diatur per material, spesifikasi dan wilayah.', 'Harga khusus transaksi tidak perlu mengubah harga default.', 'Transaksi menyimpan snapshot harga pada saat pencatatan.', 'Perubahan harga berikutnya tidak mengubah transaksi lama.', 'Harga pasar hanya referensi, bukan modal otomatis.']);

s = slide('Spreadsheet dan laporan yang direncanakan');
bullets(s, ['Kolom lengkap: material, truk, pemasok, volume, biaya dan keuntungan.', 'Tanggal lokal; navigasi harian; rekap mingguan dan bulanan.', 'Filter material, pemasok, kendaraan, wilayah dan rentang tanggal.', 'Edit dengan jejak perubahan; hapus dengan konfirmasi.', 'Ekspor XLSX/PDF dari data dan filter nyata, lalu bagikan file.']);

s = slide('Harga pasar: realistis dan transparan');
bullets(s, ['Belum ada sumber harga yang terverifikasi atau terhubung.', 'Evaluasi API resmi, izin penggunaan, cakupan dan satuan.', 'Tampilkan sumber, wilayah, spesifikasi serta waktu pembaruan.', 'Indeks konstruksi bukan harga material langsung per m³.', 'Tanpa sumber valid: “Harga pasar belum tersedia”.']);

s = slide('Fondasi teknis yang direncanakan');
box(s, 'Aplikasi', 'Flutter + Dart\nProvider untuk state\nAndroid dan iOS', 0.65, 2.3);
box(s, 'Penyimpanan lokal', 'SQLite melalui sqflite\nMigrasi bertahap\nSnapshot harga transaksi', 4.75, 2.3);
box(s, 'Online bertahap', 'Backend ketika dibutuhkan\nKredensial di server\nTanpa layanan berbayar wajib', 8.85, 2.3);
text(s, 'Target: fitur pencatatan utama tetap dapat digunakan tanpa internet.', 0.85, 5.5, 11.6, 0.8, { fontSize: 25, bold: true });

s = slide('Roadmap pengembangan');
bullets(s, ['Tahap 1 — Pemeriksaan proyek dan rencana: selesai.', 'Pratinjau UI — Dashboard dan navigasi: tersedia.', 'Tahap 2 — Kalkulator, SQLite, material, transaksi dan ekspor.', 'Tahap 3 — Integrasi sumber harga sah, sesuai ketersediaan.', 'Tahap 4 — Pengujian perangkat, penyempurnaan UI dan build APK.']);

s = slide('Keputusan teknis dan alasannya');
box(s, 'Lokal terlebih dahulu', 'Pencatatan tidak bergantung internet. Backend ditambahkan ketika kebutuhan integrasi nyata muncul.', 0.65, 2.3);
box(s, 'Presisi angka', 'Rencana integer Rupiah dan volume berskala. Hindari penggunaan double untuk nilai uang.', 4.75, 2.3);
box(s, 'Snapshot transaksi', 'Harga historis dipertahankan. Perubahan default tidak mengubah catatan yang sudah dibuat.', 8.85, 2.3);
s.addNotes('2 menit. Ketiganya keputusan desain, belum implementasi bisnis. Siapkan penjelasan pembulatan, batas volume dan migrasi tanpa menghapus data.');

s = slide('Kualitas: bukti sekarang, target berikutnya');
box(s, 'Sudah diperiksa', 'flutter analyze: bersih.\nSatu widget test navigasi: lulus.\nPenanda pratinjau terlihat.', 0.7, 2.2, 5.85, 3.3);
box(s, 'Pengujian berikutnya', 'Perhitungan desimal dan validasi.\nPersistensi dan snapshot harga.\nFilter tanggal serta isi ekspor.\nPengujian pada perangkat Android.', 6.8, 2.2, 5.85, 3.3);
text(s, 'Tidak ada klaim performa, pengguna aktif atau penghematan waktu tanpa pengukuran.', 0.85, 5.95, 11.6, 0.6, { fontSize: 20, color: C.muted });
s.addNotes('2 menit. Hasil analyze/test mengacu pada pemeriksaan pratinjau sebelumnya, bukan pengujian ulang saat membuat slide. Belum ada uji fitur database atau build APK.');

s = slide('Demo dan langkah berikutnya');
bullets(s, ['Buka proyek di VS Code; pilih emulator atau perangkat Android.', 'Jalankan flutter run atau tekan F5.', 'Tinjau empat halaman dan keterbacaan tampilan.', 'Data pratinjau tidak disimpan; tombol fitur mendatang dinonaktifkan.', 'Berikutnya: kalkulator nyata, pengujian angka, kemudian SQLite.']);
s.addNotes('Demo 4 menit. Jalankan perangkat sebelum interview. Tunjukkan dashboard, kalkulator contoh, spreadsheet kosong dan daftar material. Jika perangkat gagal, gunakan mockup berlabel sebagai cadangan; jangan menyebutnya demo langsung.');

s = slide('Terima kasih — mari berdiskusi', 'ALVITTO ZAKY • PORTFOLIO MATERIALTRACK');
text(s, 'Dari kebutuhan bisnis\nke keputusan produk yang jelas.', 0.85, 2.3, 7.5, 1.8, { fontSize: 36, bold: true, color: C.green });
text(s, 'Diskusi: prioritas MVP, validasi pengguna,\nketepatan data dan pengembangan bertahap.', 0.85, 4.6, 7.5, 1, { fontSize: 23 });
truck(s, 8.05, 3.45, 0.8);
s.addNotes('Penutup 1 menit. Undang pertanyaan. Jelaskan apa yang sudah ada, apa yang belum, dan prioritas berikutnya. Jangan mengarang timeline penyelesaian.');

pptx.writeFile({ fileName: path.join(__dirname, 'MaterialTrack_Interview_Alvitto_Zaky.pptx') });
