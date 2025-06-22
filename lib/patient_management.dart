import 'dart:io' show File, stdin, stdout;
import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/input_validations.dart';

enum JenisKelamin { lakiLaki, perempuan }

extension JenisKelaminExtension on JenisKelamin {
  String get label => this == JenisKelamin.lakiLaki ? 'L' : 'P';

  static JenisKelamin? fromInput(String input) {
    switch (input.toUpperCase()) {
      case 'L':
        return JenisKelamin.lakiLaki;
      case 'P':
        return JenisKelamin.perempuan;
      default:
        return null;
    }
  }
}

class Pasien {
  String id;
  String nama;
  String nik;
  int umur;
  JenisKelamin jenisKelamin;
  String noHandphone;
  String alamat;

  Pasien({
    required this.id,
    required this.nama,
    required this.nik,
    required this.umur,
    required this.jenisKelamin,
    required this.noHandphone,
    required this.alamat,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nik': nik,
      'umur': umur,
      'jenisKelamin': jenisKelamin.label,
      'noHandphone': noHandphone,
      'alamat': alamat,
    };
  }

  static Pasien fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['id'],
      nama: json['nama'],
      nik: json['nik'],
      umur: json['umur'],
      jenisKelamin: JenisKelaminExtension.fromInput(json['jenisKelamin'])!,
      noHandphone: json['noHandphone'],
      alamat: json['alamat'],
    );
  }
}

List<Pasien> loadPasienData() => _loadPasienData();

List<Pasien> _loadPasienData() {
  try {
    String jsonData = File('data/pasien_data.json').readAsStringSync();
    List<dynamic> pasienJson = jsonDecode(jsonData);
    return pasienJson.map((e) => Pasien.fromJson(e)).toList();
  } catch (e) {
    return [];
  }
}

void _savePasienData(List<Pasien> pasienList) {
  String jsonData = jsonEncode(pasienList.map((p) => p.toJson()).toList());
  File('data/pasien_data.json').writeAsStringSync(jsonData);
}

void tambahDataPasien() {
  List<Pasien> pasienList = loadPasienData();
  Set<String> nikSet = pasienList.map((p) => p.nik).toSet();

  stdout.write("🪪 Masukkan NIK Pasien : ");
  String? nik = stdin.readLineSync();
  if (nik == null || nik.trim().isEmpty) {
    print("NIK tidak boleh kosong ⚠️");
    return;
  }
  if (nikSet.contains(nik)) {
    print("NIK sudah terdaftar. Tambah pasien dibatalkan ⛔");
    return;
  }

  String id = 'P${(pasienList.length + 1).toString().padLeft(4, '0')}';

  stdout.write("Masukkan Nama Pasien : ");
  String? nama = stdin.readLineSync();
  if (nama == null || nama.trim().isEmpty) {
    print("Nama tidak boleh kosong ⚠️");
    return;
  }

  stdout.write("Masukkan Umur Pasien : ");
  int? umur = int.tryParse(stdin.readLineSync() ?? '');
  if (umur == null || umur <= 0) {
    print("Umur tidak valid ❌");
    return;
  }

  stdout.write("Masukkan Jenis Kelamin (L/P) : ");
  String? genderInput = stdin.readLineSync();
  JenisKelamin? jenisKelamin = JenisKelaminExtension.fromInput(genderInput ?? '');
  if (jenisKelamin == null) {
    print("Jenis kelamin tidak valid. Gunakan L untuk Laki-laki atau P untuk Perempuan ⚠️");
    return;
  }

  stdout.write("Masukkan No Handphone : ");
  String? noHandphone = stdin.readLineSync();
  if (noHandphone == null || noHandphone.trim().isEmpty) {
    print("Nomor handphone tidak boleh kosong ⚠️");
    return;
  }

  stdout.write("Masukkan Alamat : ");
  String? alamat = stdin.readLineSync();
  if (alamat == null || alamat.trim().isEmpty) {
    print("Alamat tidak boleh kosong ⚠️");
    return;
  }

  Pasien pasien = Pasien(
    id: id,
    nama: nama.trim(),
    nik: nik.trim(),
    umur: umur,
    jenisKelamin: jenisKelamin,
    noHandphone: noHandphone.trim(),
    alamat: alamat.trim(),
  );

  pasienList.add(pasien);
  _savePasienData(pasienList);

  print('Data pasien ${pasien.nama} berhasil disimpan dengan NIK : $nik dan ID : $id ✅');
  print('📋 Total pasien saat ini : ${pasienList.length}');
}

void cariPasien() {
  stdout.write("🪪 Masukkan NIK atau ID Pasien : ");
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    print("Input tidak boleh kosong ⚠️");
    return;
  }

  List<Pasien> pasienList = loadPasienData();
  Map<String, Pasien> mapById = {for (var p in pasienList) p.id: p};
  Map<String, Pasien> mapByNik = {for (var p in pasienList) p.nik: p};

  Pasien? pasien = mapById[input.trim()] ?? mapByNik[input.trim()];

  if (pasien != null) {
    List<List<dynamic>> row = [
      [
        pasien.id,
        pasien.nama,
        pasien.nik,
        pasien.umur,
        pasien.jenisKelamin.label,
        pasien.noHandphone,
        pasien.alamat,
      ],
    ];

    TableRenderer tableRenderer = TableRenderer([
      'ID',
      'Nama',
      'NIK',
      'Umur',
      'Jenis Kelamin',
      'No Handphone',
      'Alamat',
    ], row);

    print("\n📌 Data Pasien Ditemukan :\n");
    tableRenderer.printTable();
  } else {
    print("Pasien dengan NIK/ID : $input tidak ditemukan ❌");
  }
}

void lihatDaftarPasien() {
  List<Pasien> pasienList = loadPasienData();
  if (pasienList.isEmpty) {
    print("Data pasien masih kosong ❌");
    return;
  }

  print("Urutkan berdasarkan:");
  print("1. Nama");
  print("2. Umur");
  print("3. ID");
  int pilihan = readIntInRange("Pilih opsi", 1, 3);
  
  switch (pilihan) {
    case 1:
      pasienList.sort((a, b) => a.nama.compareTo(b.nama));
      break;
    case 2:
      pasienList.sort((a, b) => a.umur.compareTo(b.umur));
      break;
    case 3:
      pasienList.sort((a, b) => a.id.compareTo(b.id));
  }

  List<List<dynamic>> rows = pasienList.map((pasien) {
    return [
      pasien.id,
      pasien.nama,
      pasien.nik,
      pasien.umur,
      pasien.jenisKelamin.label,
    ];
  }).toList();

  TableRenderer tableRenderer = TableRenderer([
    'ID',
    'Nama',
    'NIK',
    'Umur',
    'Jenis Kelamin',
  ], rows);

  print("\n📋 Daftar Pasien :");
  tableRenderer.printTable();
}