# 🏥 CLI Hospital Management — Patient, Consultation & Billing System

A Command Line Interface (CLI) system built in Dart for managing hospital operations, from patient data to scheduling, consultations, and billing reports. Designed with structured modular logic and clear data handling.

---

## 🎯 Project Objectives

- Streamline patient and consultation management through a lightweight CLI.
- Apply Object-Oriented Programming (OOP) and data structure concepts in a practical case.
- Support real-time patient queueing and medical record tracking.

---

## 🧩 Core Features

### 👥 Patient Management
- Add, search, and display patient records.
- Unique NIK validation and gender enum with input/output conversion.

### 🗓 Registration & Scheduling
- Choose medical department (poli), doctor, and schedule.
- Real-time queue managed with `Queue<Pasien>`.

### 💬 Medical Consultations
- Input diagnosis, prescriptions, and medical procedures.
- Store consultation results using structured JSON data.

### 💳 Billing & Reporting
- Input costs and generate patient bills.
- Daily, weekly, and per-patient income reports.
- Encapsulated in a dedicated `Tagihan` class.

### 📂 Patient History Lookup
- Display full history of registration, consultation, and billing by NIK/ID.

---

## 💡 Data Structures Implemented

| Data Structure              | Usage Example                                          |
|-----------------------------|--------------------------------------------------------|
| List / Set / Map            | Core data containers for patients, doctors, billing    |
| Queue<Pasien>               | Real-time patient queue in registration module         |
| Sorting (List.sort)         | Sorting medical records and billing reports            |
| Map<String, List<>>         | Grouping records by department, diagnosis, and patient |

---

## 🧠 OOP Concepts Used

- **Class & Objects**: `Pasien`, `Tagihan`, `RekamMedis`, `DoctorAvailability`
- **Encapsulation**: All data is contained within well-defined class structures
- **Abstraction & Serialization**: Classes handle JSON read/write internally
- **Enum + Extension**: Gender handling with cleaner input formatting

---

## ▶️ How to Run

1. Ensure [Dart SDK](https://dart.dev/get-dart) is installed.
2. Clone this repository.
3. Run the CLI:

   ```bash
   dart run main.dart

# 🏥 CLI Rumah Sakit — Aplikasi Manajemen Pasien, Konsultasi, & Tagihan

Sistem manajemen rumah sakit berbasis Command Line Interface (CLI) yang dibuat dengan Dart. Dirancang untuk menangani operasional medis secara modular, terstruktur, dan sepenuhnya berjalan di dalam terminal.

---

## 🎯 Tujuan Proyek

- Mengelola data pasien secara efisien.
- Menerapkan konsep Object-Oriented Programming (OOP) dan struktur data dalam solusi nyata.
- Menyediakan fitur manajemen antrean, pendaftaran, konsultasi, dan laporan tagihan.

---

## 🧩 Fitur Utama

### 👥 Manajemen Pasien
- Tambah, cari, dan tampilkan data pasien.
- Validasi NIK unik dan enum untuk jenis kelamin.

### 🗓 Pendaftaran & Jadwal
- Pemilihan Poli, Dokter, dan Jadwal praktik.
- Antrean dinamis menggunakan struktur data `Queue`.

### 💬 Hasil Konsultasi
- Input diagnosis, resep obat, dan tindakan medis.
- Menyimpan rekam medis dalam format JSON.

### 💳 Tagihan & Laporan
- Hitung biaya konsultasi dan obat.
- Laporan harian, mingguan, serta per pasien.
- Data disimpan dan diproses dalam `class Tagihan`.

### 📂 Riwayat Pasien
- Tampilkan seluruh riwayat pendaftaran, konsultasi, dan tagihan dari satu antarmuka.

---

## 💡 Struktur Data yang Digunakan

| Struktur Data              | Implementasi                                                 |
|----------------------------|--------------------------------------------------------------|
| List, Set, Map             | Manajemen data pasien, tagihan, dan konsultasi               |
| Queue<Pasien>              | Antrian pasien dinamis                                       |
| Sorting (List.sort)        | Urut nama/tagihan/rekam medis                                |
| Map<String, List<>>        | Grouping per poli, diagnosis, dan pasien                     |

---

## 🧠 Konsep OOP yang Diterapkan

- **Class & Object**: `Pasien`, `Tagihan`, `RekamMedis`, `DoctorAvailability`.
- **Encapsulation**: Akses data melalui method dan constructor.
- **Enum & Extension**: JenisKelamin → konversi input ke label (`L`/`P`).
- **Modularisasi**: Setiap fitur dipisahkan ke dalam file yang terstruktur.

---

## 🛠 Cara Menjalankan

1. Install [Dart SDK](https://dart.dev/get-dart).
2. Clone repositori ini dan buka terminal.
3. Jalankan:

   ```bash
   dart run main.dart