// Lirbary
import 'dart:io' show stdin, stdout;

int readIntInRange(String prompt, int min, int max) {
  while (true) {
    stdout.write("$prompt ($min–$max): ");
    final input = stdin.readLineSync();

    // Mencoba mengonversi input menjadi integer
    final value = int.tryParse(input ?? '');

    // Memeriksa apakah input adalah angka dan berada dalam rentang yang valid
    if (value != null && value >= min && value <= max) {
      return value;
    }
    print("Input tidak valid ❌ Harap masukkan angka $min hingga $max.");
  }
}
