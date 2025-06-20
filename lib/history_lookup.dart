import 'dart:convert';
import 'dart:io';

import 'consultation_result.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/confirmation_helper.dart';
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart';

void menuRiwayatPasien() {
  while (true) {
    print("\n=== Menu Riwayat Pasien ===");
    print("1. Lihat Pendaftaran & Jadwal (Urut Tanggal)");
    print("2. Lihat Hasil Konsultasi");
    print("3. Lihat Riwayat Tagihan");
    print("4. Lihat Riwayat per Poli");
    print("5. Kembali ke menu utama");
    stdout.write("Pilih opsi (1–5): ");
    String? pilihan = stdin.readLineSync();

    switch (pilihan) {
      case '1':
        cariPendaftaran();
        break;
      case '2':
        cariKonsultasi();
        break;
      case '3':
        cariTagihan();
        break;
      case '4':
        lihatRiwayatPerPoli();
        break;
      case '5':
        return;
      default:
        print("Pilihan tidak valid.");
    }
  }
}

void cariPendaftaran() {
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  List<Pasien> pasienList = loadPasienData();
  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  final file = File('data/pendaftaran_data.json');
  if (!file.existsSync()) {
    print("Belum ada data pendaftaran.");
    return;
  }

  List<dynamic> list = jsonDecode(file.readAsStringSync());
  List<Map<String, dynamic>> hasil = list
      .cast<Map<String, dynamic>>()
      .where((e) => e['nik'] == pasien.nik || e['pasienId'] == pasien.id)
      .toList();

  if (hasil.isEmpty) {
    print("Tidak ditemukan pendaftaran untuk pasien tersebut.");
  } else {
    hasil.sort((a, b) {
      DateTime tglA = DateTime.tryParse(a['tanggalDaftar'] ?? '') ?? DateTime(1900);
      DateTime tglB = DateTime.tryParse(b['tanggalDaftar'] ?? '') ?? DateTime(1900);
      return tglB.compareTo(tglA);
    });

    List<List<dynamic>> rows = hasil.map((p) {
      return [
        p['tanggalDaftar'] ?? '-',
        p['poli'] ?? '-',
        p['dokter'] ?? '-',
        p['jadwal'] ?? '-',
        p['nomorAntrean'] ?? '-',
      ];
    }).toList();

    TableRenderer table = TableRenderer(
      ['Tanggal', 'Poli', 'Dokter', 'Jadwal', 'Antrean'],
      rows,
    );

    print("\n📌 Riwayat Pendaftaran & Jadwal (Urut Terbaru):");
    table.printTable();
  }
}

void cariKonsultasi() {
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  List<Pasien> pasienList = loadPasienData();
  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  final rekam = loadRekamMedisData()
      .where((e) => e.nik == pasien.nik || e.pasienId == pasien.id)
      .toList();

  if (rekam.isEmpty) {
    print("Belum ada hasil konsultasi untuk pasien ini.");
  } else {
    List<List<dynamic>> rows = rekam.map((r) {
      return [r.diagnosis, r.resepObat, r.tindakanMedis];
    }).toList();

    TableRenderer tableRenderer = TableRenderer(
      ['Diagnosis', 'Resep Obat', 'Tindakan Medis'],
      rows,
    );

    print("\n📋 Riwayat Hasil Konsultasi:");
    tableRenderer.printTable();
  }
}

void cariTagihan() {
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  List<Pasien> pasienList = loadPasienData();
  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  final file = File('data/tagihan_data.json');
  if (!file.existsSync()) {
    print("Belum ada riwayat tagihan.");
    return;
  }

  List<dynamic> tagihanList = jsonDecode(file.readAsStringSync());
  List<Map<String, dynamic>> hasil = tagihanList
      .cast<Map<String, dynamic>>()
      .where((e) => e['nik'] == pasien.nik || e['pasienId'] == pasien.id)
      .toList();

  if (hasil.isEmpty) {
    print("Tidak ditemukan tagihan untuk pasien ini.");
  } else {
    List<List<dynamic>> rows = hasil.map((e) {
      return [
        e['tanggal'] ?? '-',
        e['biayaKonsultasi'],
        e['biayaObat'],
        e['totalTagihan'],
      ];
    }).toList();

    TableRenderer tableRenderer = TableRenderer(
      ['Tanggal', 'Konsultasi', 'Obat', 'Total'],
      rows,
    );

    print("\n💳 Riwayat Tagihan:");
    tableRenderer.printTable();
  }
}

void lihatRiwayatPerPoli() {
  final file = File('data/pendaftaran_data.json');
  if (!file.existsSync()) {
    print("Belum ada data pendaftaran.");
    return;
  }

  List<dynamic> list = jsonDecode(file.readAsStringSync());
  Map<String, List<Map<String, dynamic>>> perPoli = {};

  for (var e in list.cast<Map<String, dynamic>>()) {
    String poli = e['poli'] ?? 'Lainnya';
    perPoli.putIfAbsent(poli, () => []).add(e);
  }

  for (var entry in perPoli.entries) {
    print("\n🏥 Poli: ${entry.key}");
    List<List<dynamic>> rows = entry.value.map((e) {
      return [
        e['tanggalDaftar'] ?? '-',
        e['nama'],
        e['dokter'],
        e['jadwal'],
        e['nomorAntrean'],
      ];
    }).toList();

    TableRenderer table = TableRenderer(
      ['Tanggal', 'Nama', 'Dokter', 'Jadwal', 'Antrean'],
      rows,
    );

    table.printTable();
  }
}