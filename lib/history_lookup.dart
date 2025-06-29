// library
import 'dart:io' show File, stdin, stdout;
import 'dart:convert' show jsonDecode;

// Modul
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart' show Pasien, loadPasienData;
import 'package:manajemen_rumah_sakit_cli_2/consultation_result.dart' show loadRekamMedisData;
import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart' show TableRenderer;
import 'package:manajemen_rumah_sakit_cli_2/utils/confirmation_helper.dart' show cariDanKonfirmasiPasien;
import 'package:manajemen_rumah_sakit_cli_2/utils/input_validations.dart' show readIntInRange;
import 'package:manajemen_rumah_sakit_cli_2/utils/formatting.dart' show formatTanggal;

/// Fungsi untuk memformat jadwal, mengubah objek jadwal menjadi string dengan format yang benar
String formatJadwal(dynamic jadwal) {
  if (jadwal is String && jadwal.trim().isNotEmpty) return jadwal;

  if (jadwal is Map && jadwal.containsKey('tanggal') && jadwal.containsKey('jam')) {
    try {
      final tgl = DateTime.tryParse(jadwal['tanggal']); // Mengonversi tanggal menjadi objek DateTime
      final jam = jadwal['jam']?.toString() ?? '-';
      if (tgl != null) {
        return "${formatTanggal(tgl)} - $jam"; // Menggabungkan tanggal dan jam dengan format yang sesuai
      }
    } catch (_) {}
  }

  return "-";
}

/// Menu utama untuk melihat riwayat pasien
void menuRiwayatPasien() {
  while (true) {
    // Menampilkan pilihan menu untuk riwayat pasien
    print("\n=== MENU RIWAYAT PASIEN ===");
    print("1. Lihat Pendaftaran & Jadwal (Urut Tanggal)");
    print("2. Lihat Hasil Konsultasi");
    print("3. Lihat Riwayat Tagihan");
    print("4. Lihat Riwayat per Poli");
    print("5. Kembali ke menu utama");
    int pilihan = readIntInRange("Pilih menu utama", 1, 5); // Meminta input pilihan menu

    switch (pilihan) {
      case 1:
        cariPendaftaran();
        break;
      case 2:
        cariKonsultasi();
        break;
      case 3:
        cariTagihan();
        break;
      case 4:
        lihatRiwayatPerPoli();
        break;
      case 5:
        return;
    }
    break;
  }
}

/// Fungsi untuk mencari dan menampilkan riwayat pendaftaran pasien
void cariPendaftaran() {
  stdout.write("🪪  Masukkan NIK atau ID Pasien : ");
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
    print("Tidak ditemukan pendaftaran untuk pasien tersebut ❌");
  } else {
    hasil.sort((a, b) {
      DateTime tglA = DateTime.tryParse(a['tanggalDaftar'] ?? '') ?? DateTime(1900);
      DateTime tglB = DateTime.tryParse(b['tanggalDaftar'] ?? '') ?? DateTime(1900);
      return tglB.compareTo(tglA); // Mengurutkan berdasarkan tanggal pendaftaran terbaru
    });

    List<List<dynamic>> rows = hasil.map((p) {
      return [
        formatTanggal(p['tanggalDaftar']), // Memformat tanggal pendaftaran
        p['poli'] ?? '-',
        p['dokter'] ?? '-',
        formatJadwal(p['jadwal']), // Memformat jadwal
        p['nomorAntrean'] ?? '-',
      ];
    }).toList();

    TableRenderer table = TableRenderer([
      'Tanggal',
      'Poli',
      'Dokter',
      'Jadwal',
      'Antrean',
    ], rows);

    print("\n📌 Riwayat Pendaftaran & Jadwal (Urut Terbaru) :");
    table.printTable();
  }
}

/// Fungsi untuk mencari dan menampilkan hasil konsultasi pasien
void cariKonsultasi() {
  stdout.write("🪪  Masukkan NIK atau ID Pasien : ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  List<Pasien> pasienList = loadPasienData();
  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  final rekam = loadRekamMedisData()
      .where((e) => e.nik == pasien.nik || e.pasienId == pasien.id)
      .toList();

  if (rekam.isEmpty) {
    print("Belum ada hasil konsultasi untuk pasien ini ❌");
  } else {
    rekam.sort((a, b) => b.tanggal.compareTo(a.tanggal)); // Mengurutkan berdasarkan tanggal konsultasi terbaru

    List<List<dynamic>> rows = rekam
        .map(
          (r) => [
            formatTanggal(r.tanggal), // Memformat tanggal konsultasi
            r.dokter,
            r.diagnosis,
            r.resepObat,
            r.tindakanMedis,
          ],
        )
        .toList();

    TableRenderer tableRenderer = TableRenderer([
      'Tanggal',
      'Dokter',
      'Diagnosis',
      'Resep Obat',
      'Tindakan Medis',
    ], rows);

    print("\n📋 Riwayat Hasil Konsultasi :");
    tableRenderer.printTable();
  }
}

/// Fungsi untuk mencari dan menampilkan riwayat tagihan pasien
void cariTagihan() {
  stdout.write("🪪  Masukkan NIK atau ID Pasien : ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  List<Pasien> pasienList = loadPasienData();
  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  final file = File('data/tagihan_data.json');
  if (!file.existsSync()) {
    print("Belum ada riwayat tagihan ❌");
    return;
  }

  List<dynamic> tagihanList = jsonDecode(file.readAsStringSync());
  List<Map<String, dynamic>> hasil = tagihanList
      .cast<Map<String, dynamic>>()
      .where((e) => e['nik'] == pasien.nik || e['pasienId'] == pasien.id)
      .toList();

  if (hasil.isEmpty) {
    print("Tidak ditemukan tagihan untuk pasien ini ❌");
  } else {
    List<List<dynamic>> rows = hasil.map((e) {
      return [
        formatTanggal(e['tanggal']),
        e['biayaKonsultasi'],
        e['biayaObat'],
        e['totalTagihan'],
      ];
    }).toList();

    TableRenderer tableRenderer = TableRenderer([
      'Konsultasi',
      'Obat',
      'Total',
    ], rows);

    print("\n💳 Riwayat Tagihan :");
    tableRenderer.printTable();
  }
}

/// Fungsi untuk melihat riwayat pendaftaran pasien per poli
void lihatRiwayatPerPoli() {
  final file = File('data/pendaftaran_data.json');
  if (!file.existsSync()) {
    print("Belum ada data pendaftaran ❌");
    return;
  }

  List<dynamic> list = jsonDecode(file.readAsStringSync());
  Map<String, List<Map<String, dynamic>>> perPoli = {}; // Membuat map untuk menyimpan pendaftaran per poli

  for (var e in list.cast<Map<String, dynamic>>()) {
    String poli = e['poli'] ?? 'Lainnya'; // Jika poli tidak tersedia, disimpan sebagai 'Lainnya'
    perPoli.putIfAbsent(poli, () => []).add(e); // Menambahkan pendaftaran ke map berdasarkan poli
  }

  // Menampilkan riwayat pendaftaran per poli
  for (var entry in perPoli.entries) {
    print("\n🏥 Poli: ${entry.key}");
    List<List<dynamic>> rows = entry.value.map((e) {
      return [
        formatTanggal(e['tanggalDaftar']),
        e['nama'],
        e['dokter'],
        formatJadwal(e['jadwal']),
        e['nomorAntrean'],
      ];
    }).toList();

    TableRenderer table = TableRenderer([
      'Tanggal',
      'Nama',
      'Dokter',
      'Jadwal',
      'Antrean',
    ], rows);

    table.printTable();
  }
}
