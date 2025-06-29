// Library
import 'dart:io' show stdin, stdout;

// Utility
import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart' show TableRenderer;

// Modul
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart' show Pasien;

/// Menampilkan data pasien dan meminta konfirmasi
Pasien? cariDanKonfirmasiPasien(String input, List<Pasien> pasienList) {

  // Membuat Map dari ID pasien dan NIK untuk pencarian cepat
  final Map<String, Pasien> byId = {for (var p in pasienList) p.id: p};
  final Map<String, Pasien> byNik = {for (var p in pasienList) p.nik: p};
  final Pasien? pasien = byId[input] ?? byNik[input];
  if (pasien == null) {
    print("Pasien dengan NIK/ID '$input' tidak ditemukan ❌");
    return null;
  }

  // Menampilkan data pasien untuk konfirmasi
  print("\n📌 Konfirmasi Data Pasien :");
  List<String> headers = ['ID', 'Nama', 'NIK', 'Umur', 'JK', 'HP', 'Alamat'];
  List<dynamic> values = [
    pasien.id,
    pasien.nama,
    pasien.nik,
    pasien.umur.toString(),
    pasien.jenisKelamin.name,
    pasien.noHandphone,
    pasien.alamat,
  ];

  TableRenderer(headers, [values]).printTable();
  stdout.write("\nApakah data pasien sudah sesuai? (y/n) : ");
  String? konfirmasi = stdin.readLineSync();

  // Jika pengguna tidak mengonfirmasi bukan 'y' maka proses dibatalkan
  if (konfirmasi?.toLowerCase() != 'y') {
    print("Proses dibatalkan ⏹️");
    return null;
  }
  return pasien;
}

/// Menampilkan rekap data sebagai konfirmasi akhir
bool konfirmasiRekap(Map<String, String> data) {
  print("\n📋 Konfirmasi Data :");

  // Menyusun header dan nilai dari map data untuk tabel
  final headers = data.keys.toList();
  final values = data.values.toList();

  // Mencetak tabel rekap data
  TableRenderer(headers, [values]).printTable();

  // Meminta konfirmasi dari pengguna
  stdout.write("\nApakah semua data sudah sesuai? (y/n) : ");
  String? confirm = stdin.readLineSync();
  return confirm?.toLowerCase() == 'y';
}

/// Konfirmasi keluar sistem
bool konfirmasiKeluar() {
  stdout.write("Apakah Anda yakin ingin keluar? (y/n) : ");
  final input = stdin.readLineSync();
  return input?.toLowerCase() == 'y';
}
