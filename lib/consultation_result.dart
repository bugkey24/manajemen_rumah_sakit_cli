import 'dart:io';
import 'dart:convert';
import 'patient_management.dart';
import 'utils/table_renderer.dart';
import 'utils/confirmation_helper.dart';

class RekamMedis {
  String pasienId;
  String nik;
  String nama;
  String diagnosis;
  String resepObat;
  String tindakanMedis;

  RekamMedis({
    required this.pasienId,
    required this.nik,
    required this.nama,
    required this.diagnosis,
    required this.resepObat,
    required this.tindakanMedis,
  });

  Map<String, dynamic> toJson() => {
    'pasienId': pasienId,
    'nik': nik,
    'nama': nama,
    'diagnosis': diagnosis,
    'resepObat': resepObat,
    'tindakanMedis': tindakanMedis,
  };

  static RekamMedis fromJson(Map<String, dynamic> json) => RekamMedis(
    pasienId: json['pasienId'],
    nik: json['nik'],
    nama: json['nama'],
    diagnosis: json['diagnosis'],
    resepObat: json['resepObat'],
    tindakanMedis: json['tindakanMedis'],
  );
}

void inputHasilKonsultasi() {
  List<Pasien> pasienList = loadPasienData();

  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return;

  Pasien? pasien = cariDanKonfirmasiPasien(input.trim(), pasienList);
  if (pasien == null) return;

  stdout.write("Masukkan Diagnosis: ");
  String? diagnosis = stdin.readLineSync();
  stdout.write("Masukkan Resep Obat: ");
  String? resep = stdin.readLineSync();
  stdout.write("Masukkan Tindakan Medis: ");
  String? tindakan = stdin.readLineSync();

  if ([diagnosis, resep, tindakan].any((e) => e == null || e.trim().isEmpty)) {
    print("❗ Data konsultasi tidak valid. Harap isi semua informasi.");
    return;
  }

  bool lanjut = konfirmasiRekap({
    'Nama Pasien': pasien.nama,
    'Diagnosis': diagnosis!,
    'Resep Obat': resep!,
    'Tindakan Medis': tindakan!,
  });

  if (!lanjut) {
    print("🚫 Penyimpanan rekam medis dibatalkan.");
    return;
  }

  RekamMedis rekamMedis = RekamMedis(
    pasienId: pasien.id,
    nik: pasien.nik,
    nama: pasien.nama,
    diagnosis: diagnosis,
    resepObat: resep,
    tindakanMedis: tindakan,
  );

  _saveRekamMedisData(rekamMedis);
  print("✅ Rekam medis berhasil disimpan untuk pasien ${pasien.nama}.");
}

void tampilkanSemuaRekamMedis() {
  List<RekamMedis> daftarRekam = loadRekamMedisData();

  if (daftarRekam.isEmpty) {
    print("Belum ada data rekam medis yang tersimpan.");
    return;
  }

  // 🔸 Sortir berdasarkan nama pasien
  daftarRekam.sort((a, b) => a.nama.compareTo(b.nama));

  List<List<dynamic>> rows = daftarRekam.map((rekam) {
    return [
      rekam.pasienId,
      rekam.nama,
      rekam.diagnosis,
      rekam.resepObat,
      rekam.tindakanMedis,
    ];
  }).toList();

  TableRenderer tableRenderer = TableRenderer([
    'ID Pasien',
    'Nama',
    'Diagnosis',
    'Resep Obat',
    'Tindakan Medis',
  ], rows);

  print("\n📋 Daftar Rekam Medis (Urut Nama):");
  tableRenderer.printTable();
}

void tampilkanRekamMedisPasien() {
  stdout.write("Masukkan ID atau NIK Pasien: ");
  String? input = stdin.readLineSync();

  List<RekamMedis> semuaData = loadRekamMedisData();
  List<RekamMedis> hasil = semuaData
      .where((rekam) => rekam.pasienId == input || rekam.nik == input)
      .toList();

  if (hasil.isEmpty) {
    print("Tidak ditemukan rekam medis untuk pasien tersebut.");
    return;
  }

  List<List<dynamic>> rows = hasil.map((rekam) {
    return [
      rekam.pasienId,
      rekam.nama,
      rekam.diagnosis,
      rekam.resepObat,
      rekam.tindakanMedis,
    ];
  }).toList();

  TableRenderer tableRenderer = TableRenderer([
    'ID Pasien',
    'Nama',
    'Diagnosis',
    'Resep Obat',
    'Tindakan Medis',
  ], rows);

  print("\n📁 Rekam Medis Pasien:");
  tableRenderer.printTable();
}

void lihatRekamMedisPerDiagnosis() {
  List<RekamMedis> daftar = loadRekamMedisData();
  if (daftar.isEmpty) {
    print("Belum ada data rekam medis.");
    return;
  }

  Map<String, List<RekamMedis>> grup = {};
  for (var rekam in daftar) {
    grup.putIfAbsent(rekam.diagnosis, () => []).add(rekam);
  }

  for (var entry in grup.entries) {
    print("\n🧾 Diagnosis: ${entry.key}");
    List<List<dynamic>> rows = entry.value.map((rekam) {
      return [rekam.pasienId, rekam.nama, rekam.resepObat, rekam.tindakanMedis];
    }).toList();

    TableRenderer table = TableRenderer([
      'ID Pasien',
      'Nama',
      'Resep Obat',
      'Tindakan Medis',
    ], rows);

    table.printTable();
  }
}

void _saveRekamMedisData(RekamMedis rekamMedis) {
  List<RekamMedis> existing = loadRekamMedisData();
  existing.add(rekamMedis);

  String jsonData = jsonEncode(existing.map((e) => e.toJson()).toList());
  File('data/rekam_medis_data.json').writeAsStringSync(jsonData);
}

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
