import 'package:intl/intl.dart';

/// Format tanggal menjadi bentuk '21 Juni 2025'
String formatTanggal(dynamic tgl) {
  if (tgl == null) return "-";

  if (tgl is String) tgl = DateTime.tryParse(tgl);
  if (tgl is! DateTime) return "-";

  return DateFormat('dd MMMM yyyy').format(tgl);
}

/// Format jadwal dari Map {'tanggal': ..., 'jam': ...}
String formatJadwal(dynamic jadwal, {String locale = 'id_ID'}) {
  if (jadwal is Map && jadwal['tanggal'] != null && jadwal['jam'] != null) {
    final tgl = DateTime.tryParse(jadwal['tanggal']);
    final jam = jadwal['jam'].toString();
    if (tgl != null) {
      return "${formatTanggal(tgl)} - $jam";
    }
  }
  return "-";
}