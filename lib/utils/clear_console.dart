import 'dart:io';

void clearConsole() {
  if (Platform.isWindows) {
    stdout.write('\x1B[2J\x1B[0;0H'); // Untuk Windows
  } else {
    stdout.write('\x1B[2J\x1B[H'); // Untuk Unix/Mac/Linux
  }
}