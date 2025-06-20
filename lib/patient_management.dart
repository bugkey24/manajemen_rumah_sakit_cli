import 'dart:convert';
import 'dart:io';
import 'utils/table_renderer.dart';

// ENUM & EXTENSION untuk Jenis Kelamin
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
      'jenisKelamin': jenisKelamin.label, // Simpan sebagai 'L' atau 'P'
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

  stdout.write("Masukkan NIK Pasien: ");
  String? nik = stdin.readLineSync();
  if (nikSet.contains(nik)) {
    print("NIK sudah terdaftar. Tambah pasien dibatalkan.");
    return;
  }

  String id = 'P${(pasienList.length + 1).toString().padLeft(4, '0')}';

  stdout.write("Masukkan Nama Pasien: ");
  String? nama = stdin.readLineSync();
  stdout.write("Masukkan Umur Pasien: ");
  int umur = int.parse(stdin.readLineSync()!);

  stdout.write("Masukkan Jenis Kelamin (L/P): ");
  String? genderInput = stdin.readLineSync();
  JenisKelamin? jenisKelamin = JenisKelaminExtension.fromInput(genderInput!);
  if (jenisKelamin == null) {
    print("Jenis kelamin tidak valid. Gunakan L untuk Laki-laki atau P untuk Perempuan.");
    return;
  }

  stdout.write("Masukkan No Handphone: ");
  String? noHandphone = stdin.readLineSync();
  stdout.write("Masukkan Alamat: ");
  String? alamat = stdin.readLineSync();

  Pasien pasien = Pasien(
    id: id,
    nama: nama!,
    nik: nik!,
    umur: umur,
    jenisKelamin: jenisKelamin,
    noHandphone: noHandphone!,
    alamat: alamat!,
  );

  pasienList.add(pasien);
  _savePasienData(pasienList);
  print('Data pasien ${pasien.nama} dengan ID $id dan NIK $nik berhasil disimpan!');
}

void cariPasien() {
  stdout.write("Masukkan NIK atau ID Pasien: ");
  String? input = stdin.readLineSync();

  List<Pasien> pasienList = loadPasienData();

  Map<String, Pasien> mapById = {for (var p in pasienList) p.id: p};
  Map<String, Pasien> mapByNik = {for (var p in pasienList) p.nik: p};

  Pasien? pasien = mapById[input] ?? mapByNik[input];

  if (pasien != null) {
    List<List<dynamic>> row = [
      [pasien.id, pasien.nama, pasien.nik, pasien.umur, pasien.jenisKelamin.label],
    ];

    TableRenderer tableRenderer = TableRenderer(
      ['ID', 'Nama', 'NIK', 'Umur', 'Jenis Kelamin'],
      row,
    );

    print("\nData Pasien Ditemukan:\n");
    tableRenderer.printTable();
  } else {
    print("Pasien dengan NIK/ID $input tidak ditemukan.");
  }
}

void lihatDaftarPasien() {
  List<Pasien> pasienList = loadPasienData();

  print("Urutkan berdasarkan:");
  print("1. Nama");
  print("2. Umur");
  print("3. ID");
  stdout.write("Pilihan (1/2/3): ");
  String? pilihan = stdin.readLineSync();

  switch (pilihan) {
    case '1':
      pasienList.sort((a, b) => a.nama.compareTo(b.nama));
      break;
    case '2':
      pasienList.sort((a, b) => a.umur.compareTo(b.umur));
      break;
    case '3':
      pasienList.sort((a, b) => a.id.compareTo(b.id));
      break;
    default:
      print("Pilihan tidak valid. Tampilkan data tanpa pengurutan.");
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

  TableRenderer tableRenderer = TableRenderer(
    ['ID', 'Nama', 'NIK', 'Umur', 'Jenis Kelamin'],
    rows,
  );

  tableRenderer.printTable();
}