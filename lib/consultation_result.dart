import 'dart:io';
import 'dart:convert';
import 'patient_management.dart';
import 'utils/table_renderer.dart';

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
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();

  List<Pasien> pasienList = loadPasienData();
  Map<String, Pasien> mapById = {for (var p in pasienList) p.id: p};
  Map<String, Pasien> mapByNik = {for (var p in pasienList) p.nik: p};
  Pasien? pasien = mapById[input] ?? mapByNik[input];

  if (pasien == null) {
    print("Pasien dengan NIK/ID $input tidak ditemukan.");
    return;
  }

  stdout.write("Masukkan Diagnosis: ");
  String? diagnosis = stdin.readLineSync();

  stdout.write("Masukkan Resep Obat: ");
  String? resep = stdin.readLineSync();

  stdout.write("Masukkan Tindakan Medis: ");
  String? tindakan = stdin.readLineSync();

  if ([diagnosis, resep, tindakan].any((e) => e == null || e.trim().isEmpty)) {
    print("Data konsultasi tidak valid. Harap isi semua informasi.");
    return;
  }

  RekamMedis rekamMedis = RekamMedis(
    pasienId: pasien.id,
    nik: pasien.nik,
    nama: pasien.nama,
    diagnosis: diagnosis!,
    resepObat: resep!,
    tindakanMedis: tindakan!,
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

  List<List<dynamic>> rows = daftarRekam.map((rekam) {
    return [
      rekam.pasienId,
      rekam.nama,
      rekam.diagnosis,
      rekam.resepObat,
      rekam.tindakanMedis,
    ];
  }).toList();

  TableRenderer tableRenderer = TableRenderer(
    ['ID Pasien', 'Nama', 'Diagnosis', 'Resep Obat', 'Tindakan Medis'],
    rows,
  );

  print("\n📋 Daftar Rekam Medis:\n");
  tableRenderer.printTable();
}

void tampilkanRekamMedisPasien() {
  stdout.write("Masukkan ID atau NIK Pasien: ");
  String? input = stdin.readLineSync();

  List<RekamMedis> semuaData = loadRekamMedisData();
  List<RekamMedis> hasil = semuaData.where(
    (rekam) => rekam.pasienId == input || rekam.nik == input,
  ).toList();

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

  TableRenderer tableRenderer = TableRenderer(
    ['ID Pasien', 'Nama', 'Diagnosis', 'Resep Obat', 'Tindakan Medis'],
    rows,
  );

  print("\n📁 Rekam Medis Pasien:\n");
  tableRenderer.printTable();
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