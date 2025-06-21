class TableRenderer {
  final List<String> headers;
  final List<List<dynamic>> rows;

  TableRenderer(this.headers, this.rows);

  void printTable() {
    final columnWidths = List<int>.from(headers.map((h) => h.length));

    // Hitung lebar tiap kolom berdasarkan data
    for (var row in rows) {
      for (var i = 0; i < row.length; i++) {
        final cell = row[i]?.toString() ?? '-';
        if (cell.length > columnWidths[i]) {
          columnWidths[i] = cell.length;
        }
      }
    }

    String buildDivider(String left, String mid, String right) {
      final line = List<String>.generate(
        columnWidths.length,
        (i) => ''.padRight(columnWidths[i] + 2, '─'),
      ).join(mid);
      return "$left$line$right";
    }

    String centerText(String text, int width) {
      final len = text.length;
      final pad = width - len;
      final left = (pad / 2).floor();
      final right = pad - left;
      return ' ' * left + text + ' ' * right;
    }

    String buildRow(List<dynamic> row, {bool isHeader = false}) {
      return row
          .asMap()
          .entries
          .map((entry) {
            final i = entry.key;
            final rawText = (entry.value ?? '-').toString();
            final cellText = isHeader
                ? centerText(rawText, columnWidths[i])
                : rawText.padRight(columnWidths[i]);
            return " $cellText ";
          })
          .join("│")
          .replaceAllMapped(RegExp(r"^|$"), (m) => "│");
    }

    print(buildDivider("┌", "┬", "┐"));
    print(buildRow(headers, isHeader: true));
    print(buildDivider("├", "┼", "┤"));
    for (var row in rows) {
      print(buildRow(row));
    }
    print(buildDivider("└", "┴", "┘"));
  }
}