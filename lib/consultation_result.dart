// Library
import 'dart:io' show File, stdin, stdout;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:intl/intl.dart' show DateFormat;

// Utility
import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart'
    show TableRenderer;
import 'package:manajemen_rumah_sakit_cli_2/utils/confirmation_helper.dart'
    show cariDanKonfirmasiPasien, konfirmasiRekap;

// Modul
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart'
    show Pasien, loadPasienData;

// Kelas untuk menyimpan dan mengelola data Rekam Medis
class RekamMedis {
  String pasienId;
  String nik;
  String nama;
  String diagnosis;
  String resepObat;
  String tindakanMedis;
  String dokter;
  DateTime tanggal;

  // Konstruktor untuk inisialisasi objek RekamMedis
  RekamMedis({
    required this.pasienId,
    required this.nik,
    required this.nama,
    required this.diagnosis,
    required this.resepObat,
    required this.tindakanMedis,
    required this.dokter,
    required this.tanggal,
  });

  // Fungsi untuk mengonversi objek RekamMedis menjadi format JSON
  Map<String, dynamic> toJson() => {
    'pasienId': pasienId,
    'nik': nik,
    'nama': nama,
    'diagnosis': diagnosis,
    'resepObat': resepObat,
    'tindakanMedis': tindakanMedis,
    'dokter': dokter,
    'tanggal': tanggal.toIso8601String(),
  };

  // Fungsi untuk mengonversi JSON menjadi objek RekamMedis
  static RekamMedis fromJson(Map<String, dynamic> json) => RekamMedis(
    pasienId: json['pasienId'],
    nik: json['nik'],
    nama: json['nama'],
    diagnosis: json['diagnosis'],
    resepObat: json['resepObat'],
    tindakanMedis: json['tindakanMedis'],
    dokter: json['dokter'] ?? '-',
    tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime(1900),
  );
}

// Fungsi untuk memasukkan hasil konsultasi pasien
void inputHasilKonsultasi() {
  List<Pasien> pasienList = loadPasienData();

  stdout.write("🪪  Masukkan NIK atau ID Pasien : ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  // Mencari pendaftaran terakhir pasien
  final pendaftaran = _cariPendaftaranTerakhir(pasien);
  if (pendaftaran == null) {
    print(
      "Pasien belum pernah terdaftar. Tidak dapat mencatat hasil konsultasi ❌",
    );
    return;
  }

  String dokter = pendaftaran['dokter'] ?? '-'; // Mendapatkan nama dokter
  final jadwal = pendaftaran['jadwal'];
  DateTime tanggalKonsultasi =
      DateTime.tryParse(jadwal?['tanggal'] ?? '') ?? DateTime.now();

  // Meminta input hasil konsultasi
  stdout.write("Masukkan Diagnosis : ");
  String? diagnosis = stdin.readLineSync();
  stdout.write("Masukkan Resep Obat : ");
  String? resep = stdin.readLineSync();
  stdout.write("Masukkan Tindakan Medis : ");
  String? tindakan = stdin.readLineSync();

  // Validasi input
  if ([diagnosis, resep, tindakan].any((e) => e == null || e.trim().isEmpty)) {
    print("Data konsultasi tidak valid. Harap isi semua informasi ⚠️");
    return;
  }

  // Menyusun konfirmasi data hasil konsultasi
  bool lanjut = konfirmasiRekap({
    'Nama Pasien': pasien.nama,
    'Dokter Pemeriksa': dokter,
    'Tanggal Konsultasi': DateFormat('dd-MM-yyyy').format(tanggalKonsultasi),
    'Diagnosis': diagnosis!,
    'Resep Obat': resep!,
    'Tindakan Medis': tindakan!,
  });

  if (!lanjut) {
    print("Penyimpanan rekam medis dibatalkan 🚫");
    return;
  }

  // Membuat objek RekamMedis dan menyimpannya
  RekamMedis rekamMedis = RekamMedis(
    pasienId: pasien.id,
    nik: pasien.nik,
    nama: pasien.nama,
    diagnosis: diagnosis,
    resepObat: resep,
    tindakanMedis: tindakan,
    dokter: dokter,
    tanggal: tanggalKonsultasi,
  );

  // Menyimpan rekam medis ke file JSON
  _saveRekamMedisData(rekamMedis);
  print(
    "Rekam medis berhasil disimpan untuk pasien ${pasien.nama} dengan nik ${pasien.nik} ✅",
  );
}

// Fungsi untuk mencari pendaftaran terakhir pasien
Map<String, dynamic>? _cariPendaftaranTerakhir(Pasien pasien) {
  final file = File('data/pendaftaran_data.json');
  if (!file.existsSync()) return null;

  try {
    List<dynamic> daftar = jsonDecode(file.readAsStringSync());
    List<Map<String, dynamic>> filtered = daftar
        .cast<Map<String, dynamic>>()
        .where((e) => e['pasienId'] == pasien.id || e['nik'] == pasien.nik)
        .toList();

    if (filtered.isEmpty) return null;

    // Mengurutkan pendaftaran berdasarkan tanggal terbaru
    filtered.sort(
      (a, b) => (b['tanggalDaftar'] ?? '').toString().compareTo(
        (a['tanggalDaftar'] ?? '').toString(),
      ),
    );

    return filtered.first; // Mengembalikan pendaftaran terbaru
  } catch (_) {
    return null;
  }
}

// Fungsi untuk menampilkan semua rekam medis yang tersimpan
void tampilkanSemuaRekamMedis() {
  List<RekamMedis> daftar = loadRekamMedisData();
  if (daftar.isEmpty) {
    print("Belum ada data rekam medis yang tersimpan ❌");
    return;
  }

  daftar.sort(
    (a, b) => b.tanggal.compareTo(a.tanggal),
  ); // Mengurutkan berdasarkan tanggal terbaru
  final formatter = DateFormat('dd-MM-yyyy');

  List<List<dynamic>> rows = daftar.map((rekam) {
    return [
      formatter.format(rekam.tanggal),
      rekam.nama,
      rekam.dokter,
      rekam.diagnosis,
      rekam.resepObat,
      rekam.tindakanMedis,
    ];
  }).toList();

  // Menampilkan tabel rekam medis
  TableRenderer([
    'Tanggal',
    'Nama',
    'Dokter',
    'Diagnosis',
    'Resep Obat',
    'Tindakan Medis',
  ], rows).printTable();
}

// Fungsi untuk menampilkan rekam medis per diagnosis
void lihatRekamMedisPerDiagnosis() {
  List<RekamMedis> daftar = loadRekamMedisData();
  if (daftar.isEmpty) {
    print("Belum ada data rekam medis ❌");
    return;
  }

  // Mengelompokkan rekam medis berdasarkan diagnosis yang sama
  Map<String, List<RekamMedis>> grup = {};
  for (var rekam in daftar) {
    grup.putIfAbsent(rekam.diagnosis, () => []).add(rekam);
  }

  final formatter = DateFormat('dd-MM-yyyy');

  // Menampilkan rekam medis berdasarkan diagnosis yang tersimpan
  for (var entry in grup.entries) {
    print("\n🧾 Diagnosis : ${entry.key}");
    List<List<dynamic>> rows = entry.value.map((rekam) {
      return [
        formatter.format(rekam.tanggal),
        rekam.nama,
        rekam.dokter,
        rekam.resepObat,
        rekam.tindakanMedis,
      ];
    }).toList();

    // Menampilkan tabel rekam medis per diagnosis yang tersimpan
    TableRenderer([
      'Tanggal',
      'Nama',
      'Dokter',
      'Resep Obat',
      'Tindakan Medis',
    ], rows).printTable();
  }
}

// Fungsi untuk menyimpan data rekam medis ke file JSON
void _saveRekamMedisData(RekamMedis rekamMedis) {
  List<RekamMedis> existing = loadRekamMedisData();
  existing.add(rekamMedis);

  String jsonData = jsonEncode(existing.map((e) => e.toJson()).toList());
  File('data/rekam_medis_data.json').writeAsStringSync(jsonData);
}

// Fungsi untuk memuat data rekam medis dari file JSON
List<RekamMedis> loadRekamMedisData() {
  File file = File('data/rekam_medis_data.json');
  if (!file.existsSync()) {
    file.writeAsStringSync('[]');
  }

  try {
    String jsonData = file.readAsStringSync().trim();
    if (jsonData.isEmpty) jsonData = '[]';
    List<dynamic> jsonList = jsonDecode(jsonData);
    return jsonList.map((e) => RekamMedis.fromJson(e)).toList();
  } catch (e) {
    print("Gagal memuat data JSON: $e");
    return [];
  }
}
