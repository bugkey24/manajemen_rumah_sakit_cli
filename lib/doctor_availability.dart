import 'dart:convert';
import 'dart:io';

class DoctorAvailability {
  List<String> poli = [];
  List<Map<String, String>> dokter = [];
  List<String> jadwal = [];

  // 🔹 Struktur data tambahan
  Map<String, List<String>> poliToDokter = {};
  Set<String> semuaDokterUnik = {};

  DoctorAvailability() {
    _loadData();
  }

  void _loadData() {
    final file = File('data/doctor_availability.json');
    if (!file.existsSync()) return;

    final data = jsonDecode(file.readAsStringSync());

    // 🔸 Load data dasar
    poli = List<String>.from(data['poli']);
    dokter = List<Map<String, String>>.from(
      (data['dokter'] as List).map(
        (e) => {
          'nama': e['nama'].toString(),
          'poli': e['poli'].toString(),
        },
      ),
    );
    jadwal = List<String>.from(
      data['jadwal'].map((e) => e['jadwal'].toString()),
    );

    // 🔸 Bangun struktur tambahan
    _buildPoliMapping();
    _buildDokterUnik();
  }

  void _buildPoliMapping() {
    poliToDokter = {}; // clear sebelumnya
    for (var d in dokter) {
      final nama = d['nama']!;
      final poliNama = d['poli']!;
      poliToDokter.putIfAbsent(poliNama, () => []).add(nama);
    }
  }

  void _buildDokterUnik() {
    semuaDokterUnik = dokter.map((d) => d['nama']!).toSet();
  }

  /// 🔹 Untuk mengambil list dokter dari poli tertentu
  List<String> dokterByPoli(String selectedPoli) {
    return poliToDokter[selectedPoli] ?? [];
  }

  /// 🔹 Semua dokter tanpa duplikasi
  List<String> dokterTersedia() => semuaDokterUnik.toList();

  /// 🔹 Dokter berdasarkan jadwal spesifik jika kamu ingin ekspansi nanti
  // Map<String, List<String>> jadwalToDokter = {};
  // void buildJadwalMapping() {...}
}