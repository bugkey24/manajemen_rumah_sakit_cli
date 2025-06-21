import 'dart:io';
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart';

/// Menampilkan data pasien dan meminta konfirmasi
Pasien? cariDanKonfirmasiPasien(String input, List<Pasien> pasienList) {
  final Map<String, Pasien> byId = {for (var p in pasienList) p.id: p};
  final Map<String, Pasien> byNik = {for (var p in pasienList) p.nik: p};

  final Pasien? pasien = byId[input] ?? byNik[input];
  if (pasien == null) {
    print("❌ Pasien dengan NIK/ID '$input' tidak ditemukan.");
    return null;
  }

  print("\n📌 Konfirmasi Data Pasien:");

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

  stdout.write("\nApakah data pasien sudah sesuai? (y/n): ");
  String? konfirmasi = stdin.readLineSync();
  if (konfirmasi?.toLowerCase() != 'y') {
    print("⏹️ Proses dibatalkan.");
    return null;
  }

  return pasien;
}

/// Menampilkan rekap data sebagai konfirmasi akhir
bool konfirmasiRekap(Map<String, String> data) {
  print("\n📋 Konfirmasi Data:");

  final headers = data.keys.toList();
  final values = data.values.toList();

  TableRenderer(headers, [values]).printTable();

  stdout.write("\nApakah semua data sudah benar? (y/n): ");
  String? confirm = stdin.readLineSync();
  return confirm?.toLowerCase() == 'y';
}

/// Konfirmasi keluar sistem
bool konfirmasiKeluar() {
  stdout.write("Apakah Anda yakin ingin keluar? (y/n): ");
  final input = stdin.readLineSync();
  return input?.toLowerCase() == 'y';
}
