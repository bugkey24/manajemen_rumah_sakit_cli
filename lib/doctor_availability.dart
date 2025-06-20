import 'dart:convert'; // untuk jsonDecode()
import 'dart:io'; // untuk File()

class DoctorAvailability {
  List<String> poli = [];
  List<Map<String, String>> dokter = [];
  List<String> jadwal = [];

  DoctorAvailability() {
    _loadData();
  }

  void _loadData() {
    final file = File('data/doctor_availability.json');
    if (!file.existsSync()) return;

    final data = jsonDecode(file.readAsStringSync());
    poli = List<String>.from(data['poli']);
    dokter = List<Map<String, String>>.from(
      (data['dokter'] as List).map(
        (e) => {'nama': e['nama'].toString(), 'poli': e['poli'].toString()},
      ),
    );
    jadwal = List<String>.from(
      data['jadwal'].map((e) => e['jadwal'].toString()),
    );
  }

  List<String> dokterByPoli(String selectedPoli) {
    return dokter
        .where((dok) => dok['poli'] == selectedPoli)
        .map((dok) => dok['nama']!)
        .toList();
  }
}
