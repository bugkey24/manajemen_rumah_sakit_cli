// library
import 'dart:io' show File, stdin, stdout;
import 'dart:collection' show Queue;
import 'dart:convert' show jsonDecode, jsonEncode;

// Modul
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart' show Pasien, loadPasienData;
import 'package:manajemen_rumah_sakit_cli_2/doctor_availability.dart' show DoctorAvailability, JadwalDokter;
import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart' show TableRenderer;
import 'package:manajemen_rumah_sakit_cli_2/utils/confirmation_helper.dart' show cariDanKonfirmasiPasien;
import 'package:manajemen_rumah_sakit_cli_2/utils/formatting.dart' show formatJadwal, formatTanggal;

// Queue untuk menyimpan antrean pasien
Queue<Pasien> antreanPasien = Queue<Pasien>();

// Fungsi untuk melakukan pendaftaran pasien dan penjadwalan
void pendaftaranDanPenjadwalan() {
  final data = DoctorAvailability(); // Mengambil ketersediaan dokter
  List<Pasien> pasienList = loadPasienData(); // Memuat data pasien

  // Meminta input NIK atau ID Pasien
  stdout.write("🪪  Masukkan NIK atau ID Pasien : ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    print("Input tidak valid ❌");
    return;
  }

  // Mencari pasien berdasarkan input NIK atau ID
  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  if (data.poli.isEmpty) {
    print("Tidak ada poli yang tersedia ❌");
    return;
  }

  // Menampilkan daftar poli yang tersedia
  print("\n🏥 Daftar Poli :");
  final poliTable = List.generate(
    data.poli.length,
    (i) => [i + 1, data.poli[i]],
  );
  TableRenderer(['No', 'Poli'], poliTable).printTable();

  // Meminta pengguna untuk memilih poli dari daftar
  stdout.write("Pilih Poli [1-${data.poli.length}] : ");
  int poliIndex = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
  if (poliIndex < 1 || poliIndex > data.poli.length) {
    print("Pilihan tidak valid ❌");
    return;
  }
  String selectedPoli = data.poli[poliIndex - 1];

  // Menampilkan daftar dokter di poli berdasarkan pilihan pengguna
  List<String> dokterList = data.dokterByPoli(selectedPoli);
  if (dokterList.isEmpty) {
    print("Tidak ada dokter di Poli $selectedPoli ❌");
    return;
  }

  print("\n👨‍⚕️ Daftar Dokter di Poli $selectedPoli :");
  final dokterTable = List.generate(
    dokterList.length,
    (i) => [i + 1, dokterList[i]],
  );
  TableRenderer(['No', 'Dokter'], dokterTable).printTable();

  // Meminta pengguna untuk memilih dokter dari poli yang dipilih
  stdout.write("Pilih Dokter [1-${dokterList.length}]: ");
  int dokterIndex = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
  if (dokterIndex < 1 || dokterIndex > dokterList.length) {
    print("Pilihan tidak valid ❌");
    return;
  }
  String selectedDokter = dokterList[dokterIndex - 1];

  // Memeriksa ketersediaan jadwal dokter
  if (data.jadwal.isEmpty) {
    print("Tidak ada jadwal untuk $selectedDokter ❌");
    return;
  }

  // Menampilkan jadwal dokter yang tersedia
  print("\n⏰ Daftar Jadwal :");
  final jadwalTampil = List.generate(data.jadwal.length, (i) {
    final j = data.jadwal[i];
    return [i + 1, formatTanggal(j.tanggal), j.jam];
  });
  TableRenderer(['No', 'Tanggal', 'Jam'], jadwalTampil).printTable();

  // Meminta pengguna untuk memilih jadwal
  stdout.write("Pilih Jadwal [1-${data.jadwal.length}] : ");
  int jadwalIndex = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
  if (jadwalIndex < 1 || jadwalIndex > data.jadwal.length) {
    print("Pilihan tidak valid ❌");
    return;
  }
  JadwalDokter selectedJadwal = data.jadwal[jadwalIndex - 1];

  // Mendapatkan nomor antrean dan tanggal pendaftaran
  final now = DateTime.now();
  String nomorAntrean = _generateNomorAntrean();
  String formattedJadwal = formatJadwal({
    'tanggal': selectedJadwal.tanggal.toIso8601String().split('T')[0],
    'jam': selectedJadwal.jam,
  });
  String tampilTglDaftar = formatTanggal(now);

  // Menampilkan konfirmasi pendaftaran
  print("\n📋 Konfirmasi Pendaftaran :");
  List<String> headers = [
    'ID',
    'Nama',
    'NIK',
    'Poli',
    'Dokter',
    'Jadwal',
    'No. Antrean',
    'Tgl Daftar',
  ];
  List<dynamic> values = [
    pasien.id,
    pasien.nama,
    pasien.nik,
    selectedPoli,
    selectedDokter,
    formattedJadwal,
    nomorAntrean,
    tampilTglDaftar,
  ];
  TableRenderer(headers, [values]).printTable();

  // Meminta konfirmasi dari pengguna
  stdout.write("\nApakah semua data sudah benar? (y/n): ");
  String? konfirmasi = stdin.readLineSync();
  bool lanjut = konfirmasi?.toLowerCase() == 'y';

  // Jika tidak di lanjutkan, membatalkan pendaftaran
  if (!lanjut) {
    print("Antrean tidak disimpan ⛔");
    return;
  }

  // Menyimpan data pendaftaran ke file JSON
  List<Map<String, dynamic>> daftar = _loadPendaftaranData();
  daftar.add({
    'pasienId': pasien.id,
    'nama': pasien.nama,
    'nik': pasien.nik,
    'poli': selectedPoli,
    'dokter': selectedDokter,
    'jadwal': {
      'tanggal': selectedJadwal.tanggal.toIso8601String().split('T')[0],
      'jam': selectedJadwal.jam,
    },
    'nomorAntrean': nomorAntrean,
    'tanggalDaftar': now.toIso8601String().split('T')[0],
  });

  _savePendaftaranData(daftar); // Menyimpan data ke file
  antreanPasien.addLast(pasien); // Menambah pasien ke antrean

  print("\nAntrean berhasil disimpan untuk ${pasien.nama} dengan Nomor Antrean : $nomorAntrean ✅");
}

/// Fungsi untuk menampilkan daftar antrean pasien
void lihatDaftarAntrean() {
  File file = File('data/pendaftaran_data.json');
  if (!file.existsSync()) {
    print("Belum ada data pendaftaran yang tersimpan ❌");
    return;
  }

  try {
    List<dynamic> rawData = jsonDecode(file.readAsStringSync());
    if (rawData.isEmpty) {
      print("Belum ada data antrean pasien ❌");
      return;
    }

    // Menampilkan antrean pasien dalam bentuk tabel
    List<List<dynamic>> rows = rawData.map((entry) {
      final jadwalStr = formatJadwal(entry['jadwal']);
      final tglDaftar = formatTanggal(entry['tanggalDaftar']);

      return [
        entry['nomorAntrean'],
        entry['pasienId'],
        entry['nama'],
        entry['nik'],
        entry['poli'],
        entry['dokter'],
        jadwalStr,
        tglDaftar,
      ];
    }).toList();

    TableRenderer([
      'Nomor Antrean',
      'ID Pasien',
      'Nama',
      'NIK',
      'Poli',
      'Dokter',
      'Jadwal Periksa',
      'Tanggal Daftar',
    ], rows).printTable();
  } catch (e) {
    print("Gagal memuat antrean : $e ❌");
  }
}

/// Fungsi untuk menampilkan antrean aktif pasien
void tampilkanAntreanAktif() {
  if (antreanPasien.isEmpty) {
    print("Antrean saat ini sedang kosong ❌");
    return;
  }

  print("\n🎯 Antrean Pasien Saat Ini :");
  int no = 1;
  for (var pasien in antreanPasien) {
    print("$no. ${pasien.nama} (ID: ${pasien.id})");
    no++;
  }
}

/// Fungsi untuk menghasilkan nomor antrean
String _generateNomorAntrean() {
  List<Map<String, dynamic>> daftar = _loadPendaftaranData();
  int nomor = daftar.length + 1;
  return 'A${nomor.toString().padLeft(4, '0')}';
}

/// Fungsi untuk memuat data pendaftaran pasien dari file JSON
List<Map<String, dynamic>> _loadPendaftaranData() {
  try {
    String json = File('data/pendaftaran_data.json').readAsStringSync();
    List<dynamic> rawList = jsonDecode(json);
    return rawList.map((e) => Map<String, dynamic>.from(e)).toList();
  } catch (_) {
    return [];
  }
}

/// Fungsi untuk menyimpan data pendaftaran pasien ke file JSON
void _savePendaftaranData(List<Map<String, dynamic>> daftar) {
  File('data/pendaftaran_data.json').writeAsStringSync(jsonEncode(daftar));
}
