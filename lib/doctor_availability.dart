import 'dart:io' show File;
import 'dart:convert' show jsonDecode;
import 'package:manajemen_rumah_sakit_cli_2/utils/formatting.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/jadwal_generator.dart';

class JadwalDokter {
  DateTime tanggal;
  String jam;

  JadwalDokter({required this.tanggal, required this.jam});

  factory JadwalDokter.fromJson(Map<String, dynamic> json) {
    return JadwalDokter(
      tanggal: DateTime.parse(json['tanggal']),
      jam: json['jam'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tanggal': tanggal.toIso8601String().split('T')[0],
        'jam': jam,
      };

  @override
  String toString() {
    return "${formatTanggal(tanggal)} - $jam";
  }
}

class DoctorAvailability {
  List<String> poli = [];
  List<Map<String, String>> dokter = [];
  List<JadwalDokter> jadwal = [];

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

    // 🔸 Auto-generate jadwal berdasarkan template statis sementara
    final templateDefault = {
      'Senin': ['09:00'],
      'Selasa': ['10:00'],
      'Rabu': ['13:00'],
      'Kamis': ['14:00'],
      'Jumat': ['15:00'],
    };
    jadwal = generateJadwalMingguan(templateJadwal: templateDefault);

    _buildPoliMapping();
    _buildDokterUnik();
  }

  void _buildPoliMapping() {
    poliToDokter = {};
    for (var d in dokter) {
      final nama = d['nama']!;
      final poliNama = d['poli']!;
      poliToDokter.putIfAbsent(poliNama, () => []).add(nama);
    }
  }

  void _buildDokterUnik() {
    semuaDokterUnik = dokter.map((d) => d['nama']!).toSet();
  }

  List<String> dokterByPoli(String selectedPoli) {
    return poliToDokter[selectedPoli] ?? [];
  }

  List<String> dokterTersedia() => semuaDokterUnik.toList();
}