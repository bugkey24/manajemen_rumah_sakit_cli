import 'dart:io';

void printSlow(String text, [Duration delay = const Duration(milliseconds: 40)]) {
  for (var rune in text.runes) {
    stdout.write(String.fromCharCode(rune));
    sleep(delay);
  }
  stdout.writeln();
}