/// library
import 'dart:io' show Platform, stdout;

void clearConsole() {
  // Memeriksa apakah sistem operasi adalah Windows
  if (Platform.isWindows) {
    // Jika Windows, gunakan escape sequence untuk membersihkan layar
    stdout.write('\x1B[2J\x1B[0;0H');
  } else {
    // Jika sistem operasi adalah Unix, Mac, atau Linux, gunakan escape sequence yang berbeda
    stdout.write('\x1B[2J\x1B[H');
  }
}
