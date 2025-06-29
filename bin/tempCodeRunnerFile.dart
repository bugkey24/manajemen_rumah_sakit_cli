import 'dart:io';

import 'package:manajemen_rumah_sakit_cli_2/utils/clear_console.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/input_validations.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/print_slow.dart';
import 'package:manajemen_rumah_sakit_cli_2/patient_management.dart';
import 'package:manajemen_rumah_sakit_cli_2/queue_and_schedule.dart';
import 'package:manajemen_rumah_sakit_cli_2/consultation_result.dart';
import 'package:manajemen_rumah_sakit_cli_2/billing.dart';
import 'package:manajemen_rumah_sakit_cli_2/history_lookup.dart';
import 'package:manajemen_rumah_sakit_cli_2/utils/confirmation_helper.dart';

void main() {
  while (true) {
    clearConsole(); // Clear terminal
    print("=== MENU UTAMA MANAJEMEN RUMAH SAKIT ===");

    // 📁 MANAJEMEN DATA PASIEN
    print("\n📁 MANAJEMEN DATA PASIEN");
    print("  1. Tambah Data Pasien");
    print("  2. Cari Pasien");
    print("  3. Lihat Daftar Pasien");

    // 📝 PENDAFTARAN & ANTREAN
    print("\n📝 PENDAFTARAN & ANTREAN");
    print("  4. Pendaftaran & Penjadwalan");
    print("  5. Lihat Semua Antrean");

    // 🩺 KONSULTASI & REKAM MEDIS
    print("\n🩺 KONSULTASI & REKAM MEDIS");
    print("  6. Input Hasil Konsultasi");
    print("  7. Lihat Semua Rekam Medis (Urut Nama)");
    print("  8. Lihat Rekam Medis per Diagnosis");
    print("  9. Lihat Riwayat Pasien (Gabungan)"); // <- Disatukan dan diganti dengan label untuk pusat kendali tagihan

    // 💳 MANAJEMEN TAGIHAN
    print("\n💳 MANAJEMEN TAGIHAN");
    print(" 10. Tambah Tagihan");
    print(" 11. Lihat Semua Tagihan (Urut Nama)");
    print(" 12. Proses Pembayaran");
    print(" 13. Lihat Laporan Tagihan"); // <- Disatukan dan diganti dengan label untuk pusat kendali tagihan

    // 📊 LAPORAN PEMBAYARAN
    print("\n📊 LAPORAN PEMBAYARAN");
    print(" 14. Laporan Harian");
    print(" 15. Laporan Mingguan");
    print(" 16. Laporan Tagihan per Pasien");

    // 🚪 KELUAR
    print("\n🚪 17. Keluar");

    int menu = readIntInRange("Pilih Menu Utama", 1, 17);
    print("\n");

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
        lihatRekamMedisPerDiagnosis();
        break;
      case 9:
        menuRiwayatPasien();
        break;
      case 10:
        totalTagihan();
        break;
      case 11:
        lihatSemuaTagihan();
        break;
      case 12:
        prosesPembayaran();
        break;
      case 13:
        menuLihatTagihan(); // <- Disatukan dan diganti dengan label untuk pusat kendali tagihan
        break;
      case 14:
        laporanHarian();
        break;
      case 15:
        laporanMingguan();
        break;
      case 16:
        laporanPerPasien();
        break;

      case 17:
        if (konfirmasiKeluar()) {
          printSlow("Keluar dari sistem...");
          clearConsole();
          return;
        }
        break;
    }
    print("\nTekan Enter untuk melanjutkan...");
    stdin.readLineSync();
  }
}
