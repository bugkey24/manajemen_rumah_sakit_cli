import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'patient_management.dart';
import 'utils/table_renderer.dart';

void totalTagihan() {
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();

  List<Pasien> pasienList = loadPasienData();
  Map<String, Pasien> byId = {for (var p in pasienList) p.id: p};
  Map<String, Pasien> byNik = {for (var p in pasienList) p.nik: p};
  Pasien? pasien = byId[input] ?? byNik[input];

  if (pasien == null) {
    print("Pasien dengan NIK/ID $input tidak ditemukan.");
    return;
  }

  stdout.write("Masukkan Biaya Konsultasi: ");
  double biayaKonsultasi = double.tryParse(stdin.readLineSync() ?? '') ?? 0;

  stdout.write("Masukkan Biaya Obat: ");
  double biayaObat = double.tryParse(stdin.readLineSync() ?? '') ?? 0;

  double total = biayaKonsultasi + biayaObat;
  String tanggal = DateFormat("dd MMMM yyyy").format(DateTime.now());

  Map<String, dynamic> tagihanBaru = {
    'pasienId': pasien.id,
    'nik': pasien.nik,
    'nama': pasien.nama,
    'biayaKonsultasi': biayaKonsultasi,
    'biayaObat': biayaObat,
    'totalTagihan': total,
    'tanggal': tanggal,
  };

  File file = File('data/tagihan_data.json');
  if (!file.existsSync()) file.writeAsStringSync('[]');

  List<dynamic> semuaTagihan = [];
  try {
    String jsonStr = file.readAsStringSync();
    semuaTagihan = jsonDecode(jsonStr);
  } catch (e) {
    print("Gagal membaca data lama: $e");
  }

  semuaTagihan.add(tagihanBaru);
  file.writeAsStringSync(jsonEncode(semuaTagihan));
  print("✅ Tagihan berhasil disimpan untuk ${pasien.nama}.");
}

void lihatSemuaTagihan() {
  File file = File('data/tagihan_data.json');
  if (!file.existsSync()) {
    print("Belum ada data tagihan yang tersimpan.");
    return;
  }

  try {
    List<dynamic> jsonList = jsonDecode(file.readAsStringSync());
    if (jsonList.isEmpty) {
      print("Belum ada data tagihan.");
      return;
    }

    List<List<dynamic>> rows = jsonList.map((e) {
      return [
        e['tanggal'] ?? '-',
        e['pasienId'],
        e['nama'],
        e['biayaKonsultasi'],
        e['biayaObat'],
        e['totalTagihan'],
      ];
    }).toList();

    TableRenderer table = TableRenderer(
      ['Tanggal', 'ID', 'Nama', 'Konsultasi', 'Obat', 'Total'],
      rows,
    );

    print("\n📋 Daftar Semua Tagihan:");
    table.printTable();
  } catch (e) {
    print("Gagal membaca data tagihan: $e");
  }
}

void lihatTagihanPasien() {
  stdout.write("Masukkan ID atau NIK Pasien: ");
  String? input = stdin.readLineSync();

  File file = File('data/tagihan_data.json');
  if (!file.existsSync()) {
    print("Belum ada data tagihan.");
    return;
  }

  try {
    List<dynamic> jsonList = jsonDecode(file.readAsStringSync());

    List<Map<String, dynamic>> hasil = jsonList
        .where((e) => e['nik'] == input || e['pasienId'] == input)
        .cast<Map<String, dynamic>>()
        .toList();

    if (hasil.isEmpty) {
      print("Tidak ada tagihan untuk $input.");
      return;
    }

    List<List<dynamic>> rows = hasil.map((e) {
      return [
        e['tanggal'] ?? '-',
        e['nama'],
        e['biayaKonsultasi'],
        e['biayaObat'],
        e['totalTagihan'],
      ];
    }).toList();

    TableRenderer table = TableRenderer(
      ['Tanggal', 'Nama', 'Konsultasi', 'Obat', 'Total'],
      rows,
    );

    print("\n📁 Tagihan Pasien:");
    table.printTable();
  } catch (e) {
    print("Gagal membaca data tagihan: $e");
  }
}

void laporanHarian() {
  File file = File('data/tagihan_data.json');
  if (!file.existsSync()) {
    print("Belum ada data tagihan.");
    return;
  }

  List<dynamic> data = jsonDecode(file.readAsStringSync());
  String hariIni = DateFormat("dd MMMM yyyy").format(DateTime.now());

  List<Map<String, dynamic>> hariIniTagihan = data
      .where((e) => e['tanggal'] == hariIni)
      .cast<Map<String, dynamic>>()
      .toList();

  if (hariIniTagihan.isEmpty) {
    print("Belum ada tagihan hari ini ($hariIni).");
    return;
  }

  double total = hariIniTagihan.fold(0.0, (sum, e) => sum + (e['totalTagihan'] ?? 0));

  List<List<dynamic>> rows = hariIniTagihan.map((e) {
    return [e['nama'], e['biayaKonsultasi'], e['biayaObat'], e['totalTagihan']];
  }).toList();

  TableRenderer table = TableRenderer(
    ['Nama', 'Konsultasi', 'Obat', 'Total'],
    rows,
  );

  print("\n📅 Laporan Penghasilan Hari Ini: $hariIni");
  table.printTable();
  print("💰 Total Pendapatan: Rp${total.toStringAsFixed(2)}");
}

void laporanMingguan() {
  File file = File('data/tagihan_data.json');
  if (!file.existsSync()) {
    print("Belum ada data tagihan.");
    return;
  }

  List<dynamic> data = jsonDecode(file.readAsStringSync());
  DateTime sekarang = DateTime.now();
  DateFormat fmt = DateFormat("dd MMMM yyyy");

  List<Map<String, dynamic>> mingguan = data
      .where((e) {
        try {
          DateTime tanggal = fmt.parse(e['tanggal'] ?? '');
          return tanggal.isAfter(sekarang.subtract(Duration(days: 7))) &&
                 tanggal.isBefore(sekarang.add(Duration(days: 1)));
        } catch (_) {
          return false;
        }
      })
      .cast<Map<String, dynamic>>()
      .toList();

  if (mingguan.isEmpty) {
    print("Tidak ada tagihan selama 7 hari terakhir.");
    return;
  }

  double total = mingguan.fold(0.0, (sum, e) => sum + (e['totalTagihan'] ?? 0));

  List<List<dynamic>> rows = mingguan.map((e) {
    return [e['tanggal'], e['nama'], e['biayaKonsultasi'], e['biayaObat'], e['totalTagihan']];
  }).toList();

  TableRenderer table = TableRenderer(
    ['Tanggal', 'Nama', 'Konsultasi', 'Obat', 'Total'],
    rows,
  );

  print("\n📆 Laporan Mingguan:");
  table.printTable();
  print("💰 Total Pendapatan 7 Hari Terakhir: Rp${total.toStringAsFixed(2)}");
}