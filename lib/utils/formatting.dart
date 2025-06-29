// Library
import 'package:intl/intl.dart' show DateFormat;

String formatTanggal(dynamic tgl) {
  if (tgl == null) return "-";

  // Jika tgl adalah String, coba konversi menjadi DateTime
  if (tgl is String) tgl = DateTime.tryParse(tgl);

  // Jika tgl bukan DateTime setelah konversi, kembalikan "-"
  if (tgl is! DateTime) return "-";

  // Menggunakan DateFormat dari pustaka intl untuk memformat tanggal
  return DateFormat('dd MMMM yyyy').format(tgl);
}

String formatJadwal(dynamic jadwal, {String locale = 'id_ID'}) {
  // Memastikan bahwa input adalah Map dengan key 'tanggal' dan 'jam'
  if (jadwal is Map && jadwal['tanggal'] != null && jadwal['jam'] != null) {
    // Mengonversi tanggal dari String menjadi DateTime
    final tgl = DateTime.tryParse(jadwal['tanggal']);
    final jam = jadwal['jam'].toString(); // Menyimpan jam sebagai String

    // Jika tanggal valid, format menjadi 'dd MMMM yyyy - jam'
    if (tgl != null) {
      return "${formatTanggal(tgl)} - $jam";
    }
  }
  return "-";
}
