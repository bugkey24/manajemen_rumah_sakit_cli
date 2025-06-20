import 'dart:io';

import 'package:manajemen_rumah_sakit_cli_2/utils/input_validations.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/print_slow.dart';
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart';
import 'package:manajemen_rumah_sakit_cli_2/queue_and_schedule.dart';
import 'package:manajemen_rumah_sakit_cli_2/consultation_result.dart';
import 'package:manajemen_rumah_sakit_cli_2/billing.dart';
import 'package:manajemen_rumah_sakit_cli_2/history_lookup.dart';

void main() {
  while (true) {
    stdout.write("\x1B[2J\x1B[0;0H"); // Clear terminal screen

    print("=== MENU UTAMA MANAJEMEN RUMAH SAKIT ===");

    print("\n📁 MANAJEMEN PASIEN");
    print("  1. Tambah Data Pasien");
    print("  2. Cari Pasien");
    print("  3. Lihat Daftar Pasien");

    print("\n📝 PENDAFTARAN & JADWAL");
    print("  4. Pendaftaran & Penjadwalan");
    print("  5. Lihat Semua Antrean");

    print("\n🩺 KONSULTASI & REKAM MEDIS");
    print("  6. Input Hasil Konsultasi");
    print("  7. Lihat Semua Rekam Medis");
    print("  8. Cari Riwayat Pasien");

    print("\n💳 TAGIHAN & LAPORAN");
    print("  9. Total Tagihan");
    print(" 10. Lihat Semua Tagihan");
    print(" 11. Laporan Tagihan Hari Ini");
    print(" 12. Laporan Tagihan Mingguan");

    print("\n🚪 13. Keluar");

    int menu = readIntInRange("Pilih Menu Utama", 1, 13);
    print("");

    switch (menu) {
      case 1:
        tambahDataPasien();
        break;
      case 2:
        cariPasien();
        break;
      case 3:
        lihatDaftarPasien();
        break;
      case 4:
        pendaftaranDanPenjadwalan();
        break;
      case 5:
        lihatDaftarAntrean();
        break;
      case 6:
        inputHasilKonsultasi();
        break;
      case 7:
        tampilkanSemuaRekamMedis();
        break;
      case 8:
        menuRiwayatPasien();
        break;
      case 9:
        totalTagihan();
        break;
      case 10:
        lihatSemuaTagihan();
        break;
      case 11:
        laporanHarian();
        break;
      case 12:
        laporanMingguan();
        break;
      case 13:
        printSlow("Keluar dari sistem...");
        return;
    }

    stdout.write("\nTekan ENTER untuk kembali ke menu...");
    stdin.readLineSync();
  }
}