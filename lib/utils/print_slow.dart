// Library
import 'dart:io' show sleep, stdout;

void printSlow(
  String text, [
  Duration delay = const Duration(milliseconds: 40),
]) {
  // Mengiterasi setiap karakter dalam string "text"
  for (var rune in text.runes) {
    // Menulis karakter ke stdout (layar konsol) satu per satu
    stdout.write(String.fromCharCode(rune));

    // Memberikan jeda waktu antar karakter sesuai durasi "delay"
    sleep(delay);
  }
  stdout.writeln();
}
