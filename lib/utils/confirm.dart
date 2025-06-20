import 'dart:io';

bool confirm(String prompt) {
  stdout.write("$prompt (y/n): ");
  final input = stdin.readLineSync()?.toLowerCase();
  return input == 'y' || input == 'ya';
}