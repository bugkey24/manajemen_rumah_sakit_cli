import 'dart:io';
import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'patient_management.dart';
import 'doctor_availability.dart';
import 'utils/table_renderer.dart';

Queue<String> antreanPasien = Queue<String>();

void pendaftaranDanPenjadwalan() {
  final data = DoctorAvailability();
  List<Pasien> pasienList = loadPasienData();
  Map<String, Pasien> byId = {for (var p in pasienList) p.id: p};
  Map<String, Pasien> byNik = {for (var p in pasienList) p.nik: p};

  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();

  Pasien? pasien = byId[input] ?? byNik[input];
  if (pasien == null) {
    print("Pasien dengan NIK/ID $input tidak ditemukan.");
    return;
  }

  print("Data Pasien: ID: ${pasien.id}, Nama: ${pasien.nama}, NIK: ${pasien.nik}");

  // POLI
  print("\nDaftar Poli:");
  if (data.poli.isEmpty) {
    print("Tidak ada poli yang tersedia.");
    return;
  }
  for (int i = 0; i < data.poli.length; i++) {
    print("${i + 1}. ${data.poli[i]}");
  }

  stdout.write("Pilih Poli: ");
  int poliIndex = int.parse(stdin.readLineSync()!) - 1;
  String selectedPoli = data.poli[poliIndex];

  // DOKTER
  List<String> dokterList = data.dokterByPoli(selectedPoli);
  if (dokterList.isEmpty) {
    print("Tidak ada dokter di Poli $selectedPoli.");
    return;
  }

  print("\nDaftar Dokter di Poli $selectedPoli:");
  for (int i = 0; i < dokterList.length; i++) {
    print("${i + 1}. ${dokterList[i]}");
  }

  stdout.write("Pilih Dokter: ");
  int dokterIndex = int.parse(stdin.readLineSync()!) - 1;
  String selectedDokter = dokterList[dokterIndex];

  // JADWAL
  print("\nDaftar Jadwal:");
  if (data.jadwal.isEmpty) {
    print("Tidak ada jadwal untuk $selectedDokter.");
    return;
  }
  for (int i = 0; i < data.jadwal.length; i++) {
    print("${i + 1}. ${data.jadwal[i]}");
  }

  stdout.write("Pilih Jadwal: ");
  int jadwalIndex = int.parse(stdin.readLineSync()!) - 1;
  String selectedJadwal = data.jadwal[jadwalIndex];

  String nomorAntrean = _generateNomorAntrean();
  String tanggalDaftar = DateFormat("dd MMMM yyyy").format(DateTime.now());

  List<Map<String, dynamic>> daftar = _loadPendaftaranData();
  daftar.add({
    'pasienId': pasien.id,
    'nama': pasien.nama,
    'nik': pasien.nik,
    'poli': selectedPoli,
    'dokter': selectedDokter,
    'jadwal': selectedJadwal,
    'nomorAntrean': nomorAntrean,
    'tanggalDaftar': tanggalDaftar,
  });

  _savePendaftaranData(daftar);

  print("\n✅ Antrean berhasil dibuat untuk ${pasien.nama}.");
  print("📍 Poli: $selectedPoli");
  print("🩺 Dokter: $selectedDokter");
  print("📆 Jadwal: $selectedJadwal");
  print("🎫 Nomor Antrean: $nomorAntrean");
  print("🕓 Tanggal Daftar: $tanggalDaftar");
}

void lihatDaftarAntrean() {
  File file = File('data/pendaftaran_data.json');
  if (!file.existsSync()) {
    print("Belum ada data pendaftaran yang tersimpan.");
    return;
  }

  try {
    List<dynamic> rawData = jsonDecode(file.readAsStringSync());
    if (rawData.isEmpty) {
      print("Belum ada data antrean pasien.");
      return;
    }

    List<List<dynamic>> rows = rawData.map((entry) {
      return [
        entry['nomorAntrean'],
        entry['tanggalDaftar'] ?? '-',
        entry['nama'],
        entry['poli'],
        entry['dokter'],
        entry['jadwal'],
      ];
    }).toList();

    TableRenderer table = TableRenderer(
      ['Nomor', 'Tanggal', 'Nama', 'Poli', 'Dokter', 'Jadwal'],
      rows,
    );

    print("\n📋 Daftar Antrean Pasien:");
    table.printTable();
  } catch (e) {
    print("Gagal memuat antrean: $e");
  }
}

String _generateNomorAntrean() {
  List<Map<String, dynamic>> daftar = _loadPendaftaranData();
  int nomor = daftar.length + 1;
  return 'A${nomor.toString().padLeft(4, '0')}';
}

List<Map<String, dynamic>> _loadPendaftaranData() {
  try {
    String json = File('data/pendaftaran_data.json').readAsStringSync();
    List<dynamic> rawList = jsonDecode(json);
    return rawList.map((e) => Map<String, dynamic>.from(e)).toList();
  } catch (_) {
    return [];
  }
}

void _savePendaftaranData(List<Map<String, dynamic>> daftar) {
  File('data/pendaftaran_data.json').writeAsStringSync(jsonEncode(daftar));
}