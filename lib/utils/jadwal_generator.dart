// Modul
import 'package:manajemen_rumah_sakit_cli_2/doctor_availability.dart' show JadwalDokter;

List<JadwalDokter> generateJadwalMingguan({
  required Map<String, List<String>> templateJadwal, 
  int durasiHari = 14,
}) {
  // Menyimpan hasil jadwal yang akan dikembalikan
  final List<JadwalDokter> hasil = [];

  // Pemetaan angka hari dalam minggu ke nama hari
  final hariMap = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: 'Jumat',
    6: 'Sabtu',
    7: 'Minggu',
  };

  // Mendapatkan tanggal hari ini
  final today = DateTime.now();

  // Mengulangi untuk menghasilkan jadwal selama durasiHari
  for (int i = 0; i < durasiHari; i++) {
    // Menghitung tanggal dengan menambahkan hari
    final tgl = today.add(Duration(days: i));

    // Menentukan nama hari berdasarkan angka weekday
    final namaHari = hariMap[tgl.weekday];

    // Jika ada jadwal untuk hari tersebut, maka tambahkan ke hasil
    if (templateJadwal.containsKey(namaHari)) {
      for (final jam in templateJadwal[namaHari]!) {
        hasil.add(JadwalDokter(tanggal: tgl, jam: jam));
      }
    }
  }
  return hasil;
}
