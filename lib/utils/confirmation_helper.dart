import 'dart:io';
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart';

/// Menampilkan data pasien dan meminta konfirmasi
Pasien? cariDanKonfirmasiPasien(String input, List<Pasien> pasienList) {
  final Map<String, Pasien> byId = {for (var p in pasienList) p.id: p};
  final Map<String, Pasien> byNik = {for (var p in pasienList) p.nik: p};

  final Pasien? pasien = byId[input] ?? byNik[input];
  if (pasien == null) {
    print("❌ Pasien dengan NIK/ID '$input' tidak ditemukan.");
    return null;
  }

  print("\n=== Konfirmasi Pasien ===");
  print("ID     : ${pasien.id}");
  print("Nama   : ${pasien.nama}");
  print("NIK    : ${pasien.nik}");
  print("Umur   : ${pasien.umur}");
  print("JK     : ${pasien.jenisKelamin.name}");
  print("HP     : ${pasien.noHandphone}");
  print("Alamat : ${pasien.alamat}");
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
  print("\n=== Konfirmasi Data ===");
  data.forEach((key, value) {
    print("$key : $value");
  });
  stdout.write("\nApakah semua data sudah benar? (y/n): ");
  String? confirm = stdin.readLineSync();
  return confirm?.toLowerCase() == 'y';
}