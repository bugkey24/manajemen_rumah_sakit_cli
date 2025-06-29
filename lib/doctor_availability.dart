// Library
import 'dart:io' show File;
import 'dart:convert' show jsonDecode;

// Utility
import 'package:manajemen_rumah_sakit_cli_2/utils/formatting.dart' show formatTanggal;
import 'package:manajemen_rumah_sakit_cli_2/utils/jadwal_generator.dart' show generateJadwalMingguan;

// Kelas JadwalDokter yang mewakili jadwal dokter
class JadwalDokter {
  DateTime tanggal;
  String jam;

  // Konstruktor untuk inisialisasi objek JadwalDokter
  JadwalDokter({required this.tanggal, required this.jam});

  // Factory method untuk mengonversi JSON menjadi objek JadwalDokter
  factory JadwalDokter.fromJson(Map<String, dynamic> json) {
    return JadwalDokter(
      tanggal: DateTime.parse(json['tanggal']),
      jam: json['jam'],
    );
  }

  // Method untuk mengonversi objek JadwalDokter menjadi format JSON
  Map<String, dynamic> toJson() => {
    'tanggal': tanggal.toIso8601String().split(
      'T',
    )[0], // Format tanggal ke ISO8601 tanpa waktu
    'jam': jam, // Menyimpan jam
  };

  // Method toString untuk menampilkan jadwal dalam format yang mudah dibaca
  @override
  String toString() {
    return "${formatTanggal(tanggal)} - $jam"; // Menggunakan fungsi formatTanggal untuk tanggal
  }
}

// Kelas untuk mengelola ketersediaan dokter
class DoctorAvailability {
  List<String> poli = [];
  List<Map<String, String>> dokter =
      [];
  List<JadwalDokter> jadwal = [];

  // Mapping antara poli dan daftar dokter yang tersedia di poli
  Map<String, List<String>> poliToDokter = {};

  // Set untuk menyimpan nama dokter unik
  Set<String> semuaDokterUnik = {};

  // Konstruktor DoctorAvailability yang memanggil _loadData untuk memuat data dari file JSON
  DoctorAvailability() {
    _loadData();
  }

  // Fungsi untuk memuat data dari file JSON
  void _loadData() {
    final file = File('data/doctor_availability.json');
    if (!file.existsSync()) return;

    // Membaca dan mengonversi data JSON menjadi objek Dart dari file JSON
    final data = jsonDecode(file.readAsStringSync());

    // 🔸 Load data dasar (Poli dan Dokter)
    poli = List<String>.from(data['poli']);
    dokter = List<Map<String, String>>.from(
      (data['dokter'] as List).map(
        (e) => {
          'nama': e['nama'].toString(),
          'poli': e['poli'].toString(),
        },
      ),
    );

    // 🔸 Auto-generate jadwal berdasarkan template statis sementara
    final templateDefault = {
      'Senin': ['09:00'],
      'Selasa': ['10:00'],
      'Rabu': ['13:00'],
      'Kamis': ['14:00'],
      'Jumat': ['15:00'],
    };
    jadwal = generateJadwalMingguan(
      templateJadwal: templateDefault,
    ); // Menghasilkan jadwal mingguan otomatis

    // Membuat mapping antara poli dan dokter yang tersedia
    _buildPoliMapping();

    // Membuat set dari nama dokter unik
    _buildDokterUnik();
  }

  // Fungsi untuk membangun mapping poli ke dokter yang tersedia di poli tertentu
  void _buildPoliMapping() {
    poliToDokter = {};
    for (var d in dokter) {
      final nama = d['nama']!;
      final poliNama = d['poli']!;
      poliToDokter
          .putIfAbsent(poliNama, () => [])
          .add(nama); // Memetakan poli ke dokter yang sesuai
    }
  }

  // Fungsi untuk membangun set dari nama dokter yang unik
  void _buildDokterUnik() {
    semuaDokterUnik = dokter
        .map((d) => d['nama']!)
        .toSet(); // Membuat set unik berdasarkan nama dokter
  }

  // Fungsi untuk mendapatkan daftar dokter yang tersedia di poli tertentu
  List<String> dokterByPoli(String selectedPoli) {
    return poliToDokter[selectedPoli] ??
        []; // Mengembalikan daftar dokter berdasarkan poli
  }

  // Fungsi untuk mendapatkan daftar semua dokter yang tersedia
  List<String> dokterTersedia() =>
      semuaDokterUnik.toList(); // Mengembalikan daftar nama dokter unik
}
