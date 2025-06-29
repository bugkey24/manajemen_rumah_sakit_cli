/// Library
import 'dart:io' show File, stdin, stdout;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

/// Modul
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart' show JenisKelamin, JenisKelaminExtension, Pasien, loadPasienData;

/// Utility
import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart' show TableRenderer;
import 'package:manajemen_rumah_sakit_cli_2/utils/confirmation_helper.dart' show cariDanKonfirmasiPasien, konfirmasiRekap;
import 'package:manajemen_rumah_sakit_cli_2/utils/input_validations.dart' show readIntInRange;
import 'package:manajemen_rumah_sakit_cli_2/utils/formatting.dart' show formatTanggal;

/// Mengubah nominal double menjadi format mata uang Rupiah (Rp)
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Kelas model untuk data Tagihan pasien
class Tagihan {
  String pasienId;
  String nik;
  String nama;
  double biayaKonsultasi;
  double biayaObat;
  double totalTagihan;
  String tanggal;
  bool sudahDibayar;

  /// Konstruktor Tagihan
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

  /// Konversi objek Tagihan ke Map untuk keperluan JSON
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

  /// Membuat objek Tagihan dari Map (hasil decode JSON)
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

/// Membuat tagihan baru untuk pasien berdasarkan input biaya konsultasi dan obat
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
  String tanggal = DateTime.now().toIso8601String().split('T')[0];

  // Konfirmasi sebelum menyimpan tagihan ke file JSON
  bool lanjut = konfirmasiRekap({
    'Nama Pasien': pasien.nama,
    'Tanggal': formatTanggal(DateTime.now()),
    'Konsultasi': formatCurrency(biayaKonsultasi),
    'Obat': formatCurrency(biayaObat),
    'Total Tagihan': formatCurrency(total),
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

/// Menampilkan laporan pembayaran tagihan yang lunas pada hari ini
void laporanHarian() {
  List<Tagihan> data = loadTagihan();
  String hariIni = DateTime.now().toIso8601String().split('T')[0];

  List<Tagihan> hariIniData = data
      .where((e) => e.tanggal == hariIni && e.sudahDibayar)
      .toList();

  if (hariIniData.isEmpty) {
    print(
      "Tidak ada tagihan yang dibayar hari ini (${formatTanggal(DateTime.now())}).",
    );
    return;
  }

  double total = hariIniData.fold(0.0, (sum, e) => sum + e.totalTagihan);

  List<List<dynamic>> rows = hariIniData.map((e) {
    return [
      e.nama,
      formatCurrency(e.biayaKonsultasi),
      formatCurrency(e.biayaObat),
      formatCurrency(e.totalTagihan),
    ];
  }).toList();

  TableRenderer table = TableRenderer([
    'Nama',
    'Konsultasi',
    'Obat',
    'Total',
  ], rows);

  print("\n📅 Laporan Pembayaran Hari Ini: ${formatTanggal(DateTime.now())}");
  table.printTable();
  print("💰 Total Pendapatan: ${formatCurrency(total)}");
}

/// Menampilkan laporan pembayaran tagihan yang lunas selama 7 hari terakhir
void laporanMingguan() {
  List<Tagihan> data = loadTagihan();
  DateTime sekarang = DateTime.now();
  DateFormat fmt = DateFormat("yyyy-MM-dd");

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
    return [
      formatTanggal(e.tanggal),
      e.nama,
      formatCurrency(e.biayaKonsultasi),
      formatCurrency(e.biayaObat),
      formatCurrency(e.totalTagihan),
    ];
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
  print("💰 Total Pendapatan 7 Hari Terakhir: ${formatCurrency(total)}");
}

/// Menampilkan riwayat pembayaran tagihan per pasien
void laporanPerPasien() {
  List<Tagihan> data = loadTagihan().where((e) => e.sudahDibayar).toList();

  if (data.isEmpty) {
    print("Belum ada tagihan yang dibayar.");
    return;
  }

  // Kelompokkan tagihan berdasarkan nama pasien
  Map<String, List<Tagihan>> grup = {};
  for (var tagihan in data) {
    grup.putIfAbsent(tagihan.nama, () => []).add(tagihan);
  }

  for (var entry in grup.entries) {
    print("\n👤 Pasien: ${entry.key}");
    List<List<dynamic>> rows = entry.value.map((e) {
      return [
        formatTanggal(e.tanggal),
        formatCurrency(e.biayaKonsultasi),
        formatCurrency(e.biayaObat),
        formatCurrency(e.totalTagihan),
      ];
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

/// Memproses pembayaran tagihan yang belum dibayar oleh pasien
void prosesPembayaran() {
  stdout.write("Masukkan ID atau NIK Pasien yang ingin dibayar: ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  List<Tagihan> semua = loadTagihan();
  List<Tagihan> belumBayar = semua
      .where((e) => (e.nik == input || e.pasienId == input) && !e.sudahDibayar)
      .toList();

  if (belumBayar.isEmpty) {
    print("Tidak ditemukan tagihan yang belum dibayar untuk $input.");
    return;
  }

  print("\n💳 Tagihan Belum Dibayar:");
  TableRenderer(
    ['No', 'Tanggal', 'Nama', 'Total'],
    List.generate(belumBayar.length, (i) {
      final t = belumBayar[i];
      return [
        i + 1,
        formatTanggal(t.tanggal),
        t.nama,
        formatCurrency(t.totalTagihan),
      ];
    }),
  ).printTable();

  stdout.write("Pilih nomor tagihan yang akan dibayar: ");
  int pilihan = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
  if (pilihan < 1 || pilihan > belumBayar.length) {
    print("Pilihan tidak valid.");
    return;
  }

  Tagihan target = belumBayar[pilihan - 1];

  // Konfirmasi sebelum pembayaran
  bool lanjut = konfirmasiRekap({
    'Nama Pasien': target.nama,
    'Tanggal Tagihan': formatTanggal(target.tanggal),
    'Konsultasi': formatCurrency(target.biayaKonsultasi),
    'Obat': formatCurrency(target.biayaObat),
    'Total': formatCurrency(target.totalTagihan),
  });

  if (!lanjut) {
    print("⏹️ Pembayaran dibatalkan.");
    return;
  }

  target.sudahDibayar = true;
  _simpanTagihan(semua);
  print("✅ Pembayaran tagihan berhasil untuk ${target.nama}.");
}

/// Menampilkan menu interaktif untuk melihat berbagai jenis tagihan
void menuLihatTagihan() {
  while (true) {
    print("\n📋 Pilih Jenis Tagihan yang Ingin Ditampilkan :");
    print("1. Semua Tagihan");
    print("2. Tagihan Belum Dibayar");
    print("3. Tagihan Sudah Dibayar");
    print("4. Pasien dengan Tagihan Aktif");
    print("5. Kembali");

    int input = readIntInRange("Pilih Menu Utama", 1, 5);
    print("\n");

    switch (input) {
      case 1:
        lihatSemuaTagihan();
        break;
      case 2:
        lihatTagihanBelumDibayar();
        break;
      case 3:
        lihatTagihanSudahDibayar();
        break;
      case 4:
        tampilkanPasienYangDitagih();
        break;
      case 5:
        return;
    }
    break;
  }
}

/// Menampilkan seluruh data tagihan
void lihatSemuaTagihan() {
  List<Tagihan> data = loadTagihan();
  if (data.isEmpty) {
    print("Belum ada data tagihan ❌");
    return;
  }

  data.sort((a, b) => a.nama.compareTo(b.nama));

  List<List<dynamic>> rows = data.map((e) {
    return [
      e.pasienId,
      e.nama,
      formatCurrency(e.biayaKonsultasi),
      formatCurrency(e.biayaObat),
      formatCurrency(e.totalTagihan),
      e.sudahDibayar ? 'Lunas' : 'Belum',
      formatTanggal(e.tanggal),
    ];
  }).toList();

  TableRenderer table = TableRenderer([
    'ID',
    'Nama',
    'Konsultasi',
    'Obat',
    'Total Tagihan',
    'Status Tagihan',
    'Tanggal',
  ], rows);

  print("\n📋 Daftar Semua Tagihan (Urut Nama) :");
  table.printTable();
}

/// Menampilkan daftar tagihan yang belum dibayar
void lihatTagihanBelumDibayar() {
  List<Tagihan> data = loadTagihan().where((e) => !e.sudahDibayar).toList();

  if (data.isEmpty) {
    print("Semua tagihan telah dibayar. Tidak ada tagihan aktif ✅");
    return;
  }

  print("\n📌 Tagihan Belum Dibayar :");
  List<List<dynamic>> rows = data
      .map(
        (e) => [
          formatTanggal(e.tanggal),
          e.nama,
          formatCurrency(e.biayaKonsultasi),
          formatCurrency(e.biayaObat),
          formatCurrency(e.totalTagihan),
        ],
      )
      .toList();

  TableRenderer table = TableRenderer([
    'Tanggal',
    'Nama',
    'Konsultasi',
    'Obat',
    'Total Tagihan',
  ], rows);

  table.printTable();
}

/// Menampilkan daftar tagihan yang sudah dibayar oleh pasien
void lihatTagihanSudahDibayar() {
  List<Tagihan> data = loadTagihan().where((e) => e.sudahDibayar).toList();

  if (data.isEmpty) {
    print("Belum ada tagihan yang lunas 📭");
    return;
  }

  print("\n📦 Tagihan yang Sudah Dibayar :");
  List<List<dynamic>> rows = data
      .map(
        (e) => [
          formatTanggal(e.tanggal),
          e.nama,
          formatCurrency(e.biayaKonsultasi),
          formatCurrency(e.biayaObat),
          formatCurrency(e.totalTagihan),
        ],
      )
      .toList();

  TableRenderer table = TableRenderer([
    'Tanggal',
    'Nama',
    'Konsultasi',
    'Obat',
    'Total Tagihan',
  ], rows);

  table.printTable();
}

/// Menampilkan daftar pasien yang masih memiliki tagihan aktif (belum lunas)
void tampilkanPasienYangDitagih() {
  List<Tagihan> tagihanAktif = loadTagihan()
      .where((e) => !e.sudahDibayar)
      .toList();

  if (tagihanAktif.isEmpty) {
    print(
      "Tidak ada pasien dengan tagihan aktif. Semua tagihan telah dibayarkan ✅",
    );
    return;
  }

  Set<String> nikSet = tagihanAktif.map((e) => e.nik).toSet();
  List<Pasien> pasienList = loadPasienData();

  List<List<dynamic>> rows = nikSet.map((nik) {
    Pasien pasien = pasienList.firstWhere(
      (p) => p.nik == nik,
      orElse: () => Pasien(
        id: '-',
        nama: 'Tidak Dikenal',
        nik: nik,
        umur: 0,
        jenisKelamin: JenisKelamin.lakiLaki,
        noHandphone: '-',
        alamat: '-',
      ),
    );
    return [
      pasien.id,
      pasien.nama,
      pasien.nik,
      pasien.jenisKelamin.label,
      pasien.umur,
      pasien.alamat,
      pasien.noHandphone,
    ];
  }).toList();

  print("\n📌 Pasien dengan Tagihan Belum Lunas :");
  TableRenderer table = TableRenderer([
    'ID',
    'Nama',
    'NIK',
    'JK',
    'Umur',
    'Alamat',
    'No HP',
  ], rows);
  table.printTable();
}

/// Mengembalikan set NIK pasien yang masih memiliki tagihan aktif (belum lunas)
Set<String> daftarPasienYangDitagih() {
  return loadTagihan().where((e) => !e.sudahDibayar).map((e) => e.nik).toSet();
}

/// Membaca data tagihan dari file JSON
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
    print("Gagal membaca data tagihan : $e ❌");
    return [];
  }
}

/// Menyimpan data tagihan ke file JSON
void _simpanTagihan(List<Tagihan> data) {
  final file = File('data/tagihan_data.json');
  final jsonData = data.map((e) => e.toJson()).toList();
  file.writeAsStringSync(jsonEncode(jsonData));
}