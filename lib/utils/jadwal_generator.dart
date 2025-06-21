import 'package:manajemen_rumah_sakit_cli_2/doctor_availability.dart';

/// Template jadwal dokter:
/// {'Senin': ['09:00', '13:00'], 'Rabu': ['10:00']}
List<JadwalDokter> generateJadwalMingguan({
  required Map<String, List<String>> templateJadwal,
  int durasiHari = 14,
}) {
  final List<JadwalDokter> hasil = [];
  final hariMap = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: 'Jumat',
    6: 'Sabtu',
    7: 'Minggu',
  };

  final today = DateTime.now();

  for (int i = 0; i < durasiHari; i++) {
    final tgl = today.add(Duration(days: i));
    final namaHari = hariMap[tgl.weekday];

    if (templateJadwal.containsKey(namaHari)) {
      for (final jam in templateJadwal[namaHari]!) {
        hasil.add(JadwalDokter(tanggal: tgl, jam: jam));
      }
    }
  }

  return hasil;
}