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

    String buildRow(List<dynamic> row, {bool isHeader = false}) {
      return row
          .asMap()
          .entries
          .map((entry) {
            final i = entry.key;
            final text = (entry.value ?? '-').toString().padRight(
              columnWidths[i],
            );
            return " ${text} ";
          })
          .join("│")
          .replaceAllMapped(RegExp(r"^|$"), (m) => "│");
    }

    // Print
    print(buildDivider("┌", "┬", "┐"));
    print(buildRow(headers, isHeader: true));
    print(buildDivider("├", "┼", "┤"));
    for (var row in rows) {
      print(buildRow(row));
    }
    print(buildDivider("└", "┴", "┘"));
  }
}
