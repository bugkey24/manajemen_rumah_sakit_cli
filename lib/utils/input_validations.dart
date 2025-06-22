import 'dart:io';

int readIntInRange(String prompt, int min, int max) {
  while (true) {
    stdout.write("$prompt ($min–$max): ");
    final input = stdin.readLineSync();
    final value = int.tryParse(input ?? '');
    if (value != null && value >= min && value <= max) {
      return value;
    }
    print("Input tidak valid ❌ Harap masukkan angka $min hingga $max.");
  }
}