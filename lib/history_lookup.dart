import 'dart:convert';
import 'dart:io';
import 'consultation_result.dart';
import 'utils/table_renderer.dart';

void menuRiwayatPasien() {
  while (true) {
    print("\n=== Menu Riwayat Pasien ===");
    print("1. Lihat Pendaftaran & Jadwal");
    print("2. Lihat Hasil Konsultasi");
    print("3. Lihat Riwayat Tagihan");
    print("4. Kembali ke menu utama");
    stdout.write("Pilih opsi (1–4): ");
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
        return;
      default:
        print("Pilihan tidak valid.");
    }
  }
}

void cariPendaftaran() {
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? id = stdin.readLineSync();
  final file = File('data/pendaftaran_data.json');

  if (!file.existsSync()) {
    print("Belum ada data pendaftaran.");
    return;
  }

  final list = jsonDecode(file.readAsStringSync());
  final hasil = list
      .where((e) => e['nik'] == id || e['pasienId'] == id)
      .toList();

  if (hasil.isEmpty) {
    print("Tidak ditemukan pendaftaran untuk pasien tersebut.");
  } else {
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

    print("\n📌 Riwayat Pendaftaran & Jadwal:");
    table.printTable();
  }
}

void cariKonsultasi() {
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? id = stdin.readLineSync();
  final rekam = loadRekamMedisData()
      .where((e) => e.nik == id || e.pasienId == id)
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
  String? id = stdin.readLineSync();
  final file = File('data/tagihan_data.json');

  if (!file.existsSync()) {
    print("Belum ada riwayat tagihan.");
    return;
  }

  final tagihan = jsonDecode(file.readAsStringSync());
  final hasil = tagihan
      .where((e) => e['nik'] == id || e['pasienId'] == id)
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