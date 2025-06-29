// library yang diperlukan
import 'dart:io' show File, stdin, stdout;
import 'dart:convert' show jsonDecode, jsonEncode;

// Modul
import 'package:manajemen_rumah_sakit_cli_2/utils/table_renderer.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/input_validations.dart';

// Enum JenisKelamin untuk mendefinisikan jenis kelamin pasien
enum JenisKelamin { lakiLaki, perempuan }

// Ekstensi untuk menambahkan method pada enum JenisKelamin
extension JenisKelaminExtension on JenisKelamin {
  // Menentukan label untuk jenis kelamin, 'L' untuk laki-laki dan 'P' untuk perempuan
  String get label => this == JenisKelamin.lakiLaki ? 'L' : 'P';

  // Fungsi untuk mengonversi input menjadi nilai JenisKelamin
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

// Kelas Pasien untuk menyimpan data pasien
class Pasien {
  String id;
  String nama;
  String nik;
  int umur;
  JenisKelamin jenisKelamin;
  String noHandphone;
  String alamat;

  // Konstruktor untuk inisialisasi objek Pasien
  Pasien({
    required this.id,
    required this.nama,
    required this.nik,
    required this.umur,
    required this.jenisKelamin,
    required this.noHandphone,
    required this.alamat,
  });

  // Mengonversi objek Pasien menjadi map JSON
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

  // Mengonversi map JSON menjadi objek Pasien
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

// Fungsi untuk memuat data pasien dari file JSON
List<Pasien> loadPasienData() => _loadPasienData();

// Fungsi untuk memuat data pasien dari file JSON
List<Pasien> _loadPasienData() {
  try {
    String jsonData = File(
      'data/pasien_data.json',
    ).readAsStringSync(); 
    List<dynamic> pasienJson = jsonDecode(jsonData);
    return pasienJson
        .map((e) => Pasien.fromJson(e))
        .toList();
  } catch (e) {
    return [];
  }
}

// Fungsi untuk menyimpan data pasien ke file JSON
void _savePasienData(List<Pasien> pasienList) {
  String jsonData = jsonEncode(
    pasienList.map((p) => p.toJson()).toList(),
  );
  File(
    'data/pasien_data.json',
  ).writeAsStringSync(jsonData);
}

// Fungsi untuk menambah data pasien baru
void tambahDataPasien() {
  List<Pasien> pasienList =
      loadPasienData();
  Set<String> nikSet = pasienList
      .map((p) => p.nik)
      .toSet();

  stdout.write("🪪  Masukkan NIK Pasien : ");
  String? nik = stdin.readLineSync();
  if (nik == null || nik.trim().isEmpty) {
    print("NIK tidak boleh kosong ⚠️");
    return;
  }
  if (nikSet.contains(nik)) {
    print("NIK sudah terdaftar. Tambah pasien dibatalkan ⛔");
    return;
  }

  // Membuat ID pasien baru berdasarkan jumlah pasien yang ada
  String id = 'P${(pasienList.length + 1).toString().padLeft(4, '0')}';

  stdout.write("Masukkan Nama Pasien : ");
  String? nama = stdin.readLineSync();
  if (nama == null || nama.trim().isEmpty) {
    print("Nama tidak boleh kosong ⚠️");
    return;
  }

  stdout.write("Masukkan Umur Pasien : ");
  int? umur = int.tryParse(
    stdin.readLineSync() ?? '',
  );
  if (umur == null || umur <= 0) {
    print("Umur tidak valid ❌");
    return;
  }

  stdout.write("Masukkan Jenis Kelamin (L/P) : ");
  String? genderInput = stdin
      .readLineSync();
  JenisKelamin? jenisKelamin = JenisKelaminExtension.fromInput(
    genderInput ?? '',
  );
  if (jenisKelamin == null) {
    print(
      "Jenis kelamin tidak valid. Gunakan L untuk Laki-laki atau P untuk Perempuan ⚠️",
    );
    return;
  }

  stdout.write("Masukkan No Handphone : ");
  String? noHandphone = stdin
      .readLineSync();
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

  // Membuat objek Pasien dan menyimpannya ke list pasienList
  Pasien pasien = Pasien(
    id: id,
    nama: nama.trim(),
    nik: nik.trim(),
    umur: umur,
    jenisKelamin: jenisKelamin,
    noHandphone: noHandphone.trim(),
    alamat: alamat.trim(),
  );

  pasienList.add(pasien); // Menambahkan pasien ke dalam list
  _savePasienData(pasienList); // Menyimpan list pasien ke file

  print(
    'Data pasien ${pasien.nama} berhasil disimpan dengan NIK : $nik dan ID : $id ✅',
  );
  print('📋 Total pasien saat ini : ${pasienList.length}');
}

// Fungsi untuk mencari pasien berdasarkan NIK atau ID
void cariPasien() {
  stdout.write("🪪  Masukkan NIK atau ID Pasien : ");
  String? input = stdin.readLineSync(); // Meminta input NIK atau ID pasien
  if (input == null || input.trim().isEmpty) {
    print("Input tidak boleh kosong ⚠️");
    return;
  }

  List<Pasien> pasienList =
      loadPasienData();
  Map<String, Pasien> mapById = {
    for (var p in pasienList) p.id: p,
  };
  Map<String, Pasien> mapByNik = {
    for (var p in pasienList) p.nik: p,
  };

  Pasien? pasien =
      mapById[input.trim()] ??
      mapByNik[input.trim()];

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

// Fungsi untuk melihat daftar pasien yang sudah terdaftar
void lihatDaftarPasien() {
  List<Pasien> pasienList =
      loadPasienData();
  if (pasienList.isEmpty) {
    print("Data pasien masih kosong ❌");
    return;
  }

  // Menampilkan menu untuk mengurutkan daftar pasien berdasarkan nama, umur, atau ID
  print("Urutkan berdasarkan:");
  print("1. Nama");
  print("2. Umur");
  print("3. ID");
  int pilihan = readIntInRange(
    "Pilih opsi",
    1,
    3,
  );

  switch (pilihan) {
    case 1:
      pasienList.sort(
        (a, b) => a.nama.compareTo(b.nama),
      ); // Mengurutkan berdasarkan nama
      break;
    case 2:
      pasienList.sort(
        (a, b) => a.umur.compareTo(b.umur),
      ); // Mengurutkan berdasarkan umur
      break;
    case 3:
      pasienList.sort(
        (a, b) => a.id.compareTo(b.id),
      ); // Mengurutkan berdasarkan ID
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
