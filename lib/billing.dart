import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'patient_management.dart';
import 'utils/table_renderer.dart';
import 'utils/confirmation_helper.dart';

class Tagihan {
  String pasienId;
  String nik;
  String nama;
  double biayaKonsultasi;
  double biayaObat;
  double totalTagihan;
  String tanggal;
  bool sudahDibayar;

  Tagihan({
    required this.pasienId,
    required this.nik,
    required this.nama,
    required this.biayaKonsultasi,
    required this.biayaObat,
    required this.totalTagihan,
    required this.tanggal,
    this.sudahDibayar = false,
  });

  Map<String, dynamic> toJson() => {
    'pasienId': pasienId,
    'nik': nik,
    'nama': nama,
    'biayaKonsultasi': biayaKonsultasi,
    'biayaObat': biayaObat,
    'totalTagihan': totalTagihan,
    'tanggal': tanggal,
    'sudahDibayar': sudahDibayar,
  };

  static Tagihan fromJson(Map<String, dynamic> json) => Tagihan(
    pasienId: json['pasienId'],
    nik: json['nik'],
    nama: json['nama'],
    biayaKonsultasi: (json['biayaKonsultasi'] ?? 0).toDouble(),
    biayaObat: (json['biayaObat'] ?? 0).toDouble(),
    totalTagihan: (json['totalTagihan'] ?? 0).toDouble(),
    tanggal: json['tanggal'],
    sudahDibayar: json['sudahDibayar'] ?? false,
  );
}

void totalTagihan() {
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  List<Pasien> pasienList = loadPasienData();
  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  stdout.write("Masukkan Biaya Konsultasi: ");
  double biayaKonsultasi = double.tryParse(stdin.readLineSync() ?? '') ?? 0;

  stdout.write("Masukkan Biaya Obat: ");
  double biayaObat = double.tryParse(stdin.readLineSync() ?? '') ?? 0;

  double total = biayaKonsultasi + biayaObat;
  String tanggal = DateFormat("dd MMMM yyyy").format(DateTime.now());

  bool lanjut = konfirmasiRekap({
    'Nama Pasien': pasien.nama,
    'Tanggal': tanggal,
    'Konsultasi': 'Rp${biayaKonsultasi.toStringAsFixed(2)}',
    'Obat': 'Rp${biayaObat.toStringAsFixed(2)}',
    'Total Tagihan': 'Rp${total.toStringAsFixed(2)}',
  });

  if (!lanjut) {
    print("❌ Tagihan dibatalkan.");
    return;
  }

  Tagihan tagihan = Tagihan(
    pasienId: pasien.id,
    nik: pasien.nik,
    nama: pasien.nama,
    biayaKonsultasi: biayaKonsultasi,
    biayaObat: biayaObat,
    totalTagihan: total,
    tanggal: tanggal,
    sudahDibayar: false,
  );

  List<Tagihan> semua = loadTagihan();
  semua.add(tagihan);
  _simpanTagihan(semua);

  print("✅ Tagihan berhasil disimpan untuk ${pasien.nama}.");
}

void laporanHarian() {
  List<Tagihan> data = loadTagihan();
  String hariIni = DateFormat("dd MMMM yyyy").format(DateTime.now());

  List<Tagihan> hariIniData = data
      .where((e) => e.tanggal == hariIni && e.sudahDibayar)
      .toList();

  if (hariIniData.isEmpty) {
    print("Tidak ada tagihan yang dibayar hari ini ($hariIni).");
    return;
  }

  double total = hariIniData.fold(0.0, (sum, e) => sum + e.totalTagihan);

  List<List<dynamic>> rows = hariIniData.map((e) {
    return [e.nama, e.biayaKonsultasi, e.biayaObat, e.totalTagihan];
  }).toList();

  TableRenderer table = TableRenderer([
    'Nama',
    'Konsultasi',
    'Obat',
    'Total',
  ], rows);

  print("\n📅 Laporan Pembayaran Hari Ini: $hariIni");
  table.printTable();
  print("💰 Total Pendapatan: Rp${total.toStringAsFixed(2)}");
}

void laporanMingguan() {
  List<Tagihan> data = loadTagihan();
  DateTime sekarang = DateTime.now();
  DateFormat fmt = DateFormat("dd MMMM yyyy");

  List<Tagihan> minggu = data.where((e) {
    try {
      DateTime tgl = fmt.parse(e.tanggal);
      return tgl.isAfter(sekarang.subtract(Duration(days: 7))) &&
          tgl.isBefore(sekarang.add(Duration(days: 1))) &&
          e.sudahDibayar;
    } catch (_) {
      return false;
    }
  }).toList();

  if (minggu.isEmpty) {
    print("Tidak ada pembayaran selama 7 hari terakhir.");
    return;
  }

  double total = minggu.fold(0.0, (sum, e) => sum + e.totalTagihan);

  List<List<dynamic>> rows = minggu.map((e) {
    return [e.tanggal, e.nama, e.biayaKonsultasi, e.biayaObat, e.totalTagihan];
  }).toList();

  TableRenderer table = TableRenderer([
    'Tanggal',
    'Nama',
    'Konsultasi',
    'Obat',
    'Total',
  ], rows);

  print("\n📆 Laporan Mingguan (Pembayaran Lunas):");
  table.printTable();
  print("💰 Total Pendapatan 7 Hari Terakhir: Rp${total.toStringAsFixed(2)}");
}

void laporanPerPasien() {
  List<Tagihan> data = loadTagihan().where((e) => e.sudahDibayar).toList();

  if (data.isEmpty) {
    print("Belum ada tagihan yang dibayar.");
    return;
  }

  Map<String, List<Tagihan>> grup = {};
  for (var tagihan in data) {
    grup.putIfAbsent(tagihan.nama, () => []).add(tagihan);
  }

  for (var entry in grup.entries) {
    print("\n👤 Pasien: ${entry.key}");
    List<List<dynamic>> rows = entry.value.map((e) {
      return [e.tanggal, e.biayaKonsultasi, e.biayaObat, e.totalTagihan];
    }).toList();

    TableRenderer table = TableRenderer([
      'Tanggal',
      'Konsultasi',
      'Obat',
      'Total',
    ], rows);
    table.printTable();
  }
}

void prosesPembayaran() {
  stdout.write("Masukkan ID atau NIK Pasien yang ingin dibayar: ");
  String? input = stdin.readLineSync();
  List<Tagihan> semua = loadTagihan();

  List<Tagihan> belumBayar = semua
      .where((e) => (e.nik == input || e.pasienId == input) && !e.sudahDibayar)
      .toList();

  if (belumBayar.isEmpty) {
    print("Tidak ditemukan tagihan yang belum dibayar untuk $input.");
    return;
  }

  print("\n💳 Tagihan Belum Dibayar:");
  for (int i = 0; i < belumBayar.length; i++) {
    Tagihan t = belumBayar[i];
    print(
      "${i + 1}. ${t.tanggal} | ${t.nama} | Rp${t.totalTagihan.toStringAsFixed(2)}",
    );
  }

  stdout.write("Pilih nomor tagihan yang akan dibayar: ");
  int pilihan = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
  if (pilihan < 1 || pilihan > belumBayar.length) {
    print("Pilihan tidak valid.");
    return;
  }

  Tagihan target = belumBayar[pilihan - 1];

  bool lanjut = konfirmasiRekap({
    'Nama Pasien': target.nama,
    'Tanggal Tagihan': target.tanggal,
    'Konsultasi': 'Rp${target.biayaKonsultasi.toStringAsFixed(2)}',
    'Obat': 'Rp${target.biayaObat.toStringAsFixed(2)}',
    'Total': 'Rp${target.totalTagihan.toStringAsFixed(2)}',
  });

  if (!lanjut) {
    print("⏹️ Pembayaran dibatalkan.");
    return;
  }

  target.sudahDibayar = true;
  _simpanTagihan(semua);
  print("✅ Pembayaran tagihan berhasil untuk ${target.nama}.");
}

void menuLihatTagihan() {
  print("\n📋 Pilih Jenis Tagihan yang Ingin Ditampilkan:");
  print("1. Semua Tagihan");
  print("2. Tagihan Belum Dibayar");
  print("3. Tagihan Sudah Dibayar");
  print("4. Pasien dengan Tagihan Aktif");
  print("5. Kembali");
  stdout.write("Pilih opsi (1–5): ");
  String? input = stdin.readLineSync();

  switch (input) {
    case '1':
      lihatSemuaTagihan();
      break;
    case '2':
      lihatTagihanBelumDibayar();
      break;
    case '3':
      lihatTagihanSudahDibayar();
      break;
    case '4':
      tampilkanPasienYangDitagih();
      break;
    case '5':
      return;
    default:
      print("❌ Opsi tidak valid.");
  }
}

void lihatSemuaTagihan() {
  List<Tagihan> data = loadTagihan();

  if (data.isEmpty) {
    print("Belum ada data tagihan.");
    return;
  }

  data.sort((a, b) => a.nama.compareTo(b.nama));

  List<List<dynamic>> rows = data.map((e) => [
    e.tanggal,
    e.pasienId,
    e.nama,
    e.biayaKonsultasi,
    e.biayaObat,
    e.totalTagihan,
    e.sudahDibayar ? 'Lunas' : 'Belum'
  ]).toList();

  TableRenderer table = TableRenderer([
    'Tanggal', 'ID', 'Nama', 'Konsultasi', 'Obat', 'Total', 'Status'
  ], rows);

  print("\n📋 Daftar Semua Tagihan (Urut Nama):");
  table.printTable();
}

void lihatTagihanBelumDibayar() {
  List<Tagihan> data = loadTagihan().where((e) => !e.sudahDibayar).toList();

  if (data.isEmpty) {
    print("🎉 Semua tagihan telah dibayar. Tidak ada tagihan aktif.");
    return;
  }

  print("\n📌 Tagihan Belum Dibayar:");
  List<List<dynamic>> rows = data.map((e) => [
    e.tanggal, e.nama, e.biayaKonsultasi, e.biayaObat, e.totalTagihan
  ]).toList();

  TableRenderer table = TableRenderer([
    'Tanggal', 'Nama', 'Konsultasi', 'Obat', 'Total'
  ], rows);

  table.printTable();
}

void lihatTagihanSudahDibayar() {
  List<Tagihan> data = loadTagihan().where((e) => e.sudahDibayar).toList();

  if (data.isEmpty) {
    print("📭 Belum ada tagihan yang lunas.");
    return;
  }

  print("\n📦 Tagihan yang Sudah Dibayar:");
  List<List<dynamic>> rows = data.map((e) => [
    e.tanggal, e.nama, e.biayaKonsultasi, e.biayaObat, e.totalTagihan
  ]).toList();

  TableRenderer table = TableRenderer([
    'Tanggal', 'Nama', 'Konsultasi', 'Obat', 'Total'
  ], rows);

  table.printTable();
}

void tampilkanPasienYangDitagih() {
  List<Tagihan> tagihanAktif = loadTagihan().where((e) => !e.sudahDibayar).toList();

  if (tagihanAktif.isEmpty) {
    print("🎉 Tidak ada pasien dengan tagihan aktif. Semua tagihan telah dibayar!");
    return;
  }

  Set<String> nikSet = tagihanAktif.map((e) => e.nik).toSet();
  List<Pasien> pasienList = loadPasienData();

  List<List<dynamic>> rows = nikSet.map((nik) {
    Pasien? pasien = pasienList.firstWhere(
      (p) => p.nik == nik,
      orElse: () => Pasien(
        id: '-', nama: 'Tidak Dikenal', nik: nik,
        umur: 0, jenisKelamin: JenisKelamin.lakiLaki,
        noHandphone: '-', alamat: '-'
      )
    );
    return [
      pasien.id,
      pasien.nama,
      pasien.nik,
      pasien.jenisKelamin.label,
      pasien.umur,
      pasien.noHandphone
    ];
  }).toList();

  print("\n📌 Pasien dengan Tagihan Belum Lunas:");
  TableRenderer table = TableRenderer([
    'ID', 'Nama', 'NIK', 'JK', 'Umur', 'No HP'
  ], rows);
  table.printTable();
}

Set<String> daftarPasienYangDitagih() {
  return loadTagihan().where((e) => !e.sudahDibayar).map((e) => e.nik).toSet();
}

List<Tagihan> loadTagihan() {
  final file = File('data/tagihan_data.json');
  if (!file.existsSync()) {
    file.writeAsStringSync('[]');
  }

  try {
    final jsonStr = file.readAsStringSync();
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((e) => Tagihan.fromJson(e)).toList();
  } catch (e) {
    print("❌ Gagal membaca data tagihan: $e");
    return [];
  }
}

void _simpanTagihan(List<Tagihan> data) {
  final file = File('data/tagihan_data.json');
  final jsonData = data.map((e) => e.toJson()).toList();
  file.writeAsStringSync(jsonEncode(jsonData));
}


