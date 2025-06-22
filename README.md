# 🏥 Manajemen Rumah Sakit CLI (Dart)

Aplikasi Command-Line Interface (CLI) berbasis Dart untuk mengelola operasional rumah sakit. Sistem ini mencakup manajemen data pasien, pendaftaran dan antrean, hasil konsultasi dan rekam medis, sistem tagihan dan laporan keuangan. Proyek ini menerapkan prinsip **Object-Oriented Programming (OOP)** dan struktur data dinamis menggunakan Dart.

---

## 📦 Fitur Utama

- 👤 **Data Pasien** : Tambah, cari dan lihat daftar pasien
- 📝 **Pendaftaran & Jadwal** : Antrean per poli dan dokter
- 🩺 **Rekam Medis**: Diagnosis, resep dan tindakan medis
- 💳 **Tagihan** : Hitung biaya layanan dan obat, proses pelunasan
- 📊 **Laporan** : Ringkasan harian, mingguan dan per pasien
- 🔎 **Riwayat Pasien** : Gabungan histori konsultasi & pembayaran
- ✅ **Validasi Interaktif** : Konfirmasi dua langkah saat input

---

## 🚀 Instalasi & Menjalankan

### 1. Persiapan

- Install [Dart SDK](https://dart.dev/get-dart) minimal versi **3.0**
- OS : Windows / Linux / macOS

### 2. Clone dan jalankan

```bash
git clone https://github.com/namamu/manajemen_rumah_sakit_cli.git
cd manajemen_rumah_sakit_cli
dart run bin/main.dart
```

---

## 🧱 Struktur Proyek

```
bin/
  main.dart                   # Titik masuk aplikasi CLI
lib/
  billing.dart
  consultation_result.dart
  doctor_availability.dart
  history_lookup.dart
  patient_management.dart
  queue_and_schedule.dart
  utils/
    clear_console.dart
    confirmation_helper.dart
    formatting.dart
    input_validations.dart
    jadwal_generator.dart
    print_slow.dart
    table_renderer.dart
data/
  pasien_data.json
  tagihan_data.json
  rekam_medis_data.json
  pendaftaran_data.json
  doctor_availability.json
```

---

## 🧠 OOP & Struktur Data

### ✅ OOP

- Class modular: `Pasien`, `Tagihan`, `RekamMedis`
- `factory fromJson()` untuk parsing JSON
- Modul pemisah antar domain (pasien, billing, antrean)

### ✅ Struktur Data

- **List** : Menyimpan entitas dinamis (pasien, tagihan, dll)
- **Set** : Menjamin keunikan (NIK, ID)
- **Map** : Lookup cepat (ID → data pasien)
- **Sort & filter** : Untuk laporan dan pencarian
- **JSON** : Penyimpanan data lokal

---

## 💬 Contoh Menu CLI

```text
=== MENU UTAMA MANAJEMEN RUMAH SAKIT ===

📁 MANAJEMEN DATA PASIEN
  1. Tambah Data Pasien
  2. Cari Pasien
  3. Lihat Daftar Pasien

💳 MANAJEMEN TAGIHAN
 10. Tambah Tagihan
 11. Lihat Semua Tagihan (Urut Nama)
 12. Proses Pembayaran
 13. Lihat Laporan Tagihan  <-- 🔥 Menu Sub-opsi
```

---

## 📚 Fitur Tambahan yang Disarankan

- ✏️ Edit & hapus data pasien dengan pengecekan dependensi
- 📄 Ekspor laporan ke CSV atau TXT
- 🔐 Mode akun (admin, kasir, dokter)
- ☁️ Backup dan restore dari folder `data/`
- ✅ Unit testing menggunakan package `test`

---

## 👤 Kontributor

- **Nama** : Dida
- **Bahasa** : Dart
- **Peran** : Arsitek sistem & pengembang CLI modular

---

## 📄 Lisensi

Proyek ini open-source untuk kebutuhan edukasi dan pengembangan non-komersial.  
Silakan fork, gunakan dan sesuaikan sesuai kebutuhan pembelajaranmu.
