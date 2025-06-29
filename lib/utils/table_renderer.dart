class TableRenderer {
  final List<String> headers; // Menyimpan daftar header kolom tabel
  final List<List<dynamic>> rows; // Menyimpan daftar baris data tabel

  // Konstruktor untuk menginisialisasi header dan baris
  TableRenderer(this.headers, this.rows);

  // Fungsi untuk mencetak tabel ke konsol
  void printTable() {
    // Menentukan lebar kolom berdasarkan panjang header masing-masing
    final columnWidths = List<int>.from(headers.map((h) => h.length));

    // Menghitung lebar tiap kolom berdasarkan data di setiap baris
    for (var row in rows) {
      for (var i = 0; i < row.length; i++) {
        final cell =
            row[i]?.toString() ?? '-'; // Mengonversi nilai menjadi string
        if (cell.length > columnWidths[i]) {
          columnWidths[i] =
              cell.length; // Memperbarui lebar kolom jika diperlukan
        }
      }
    }

    // Fungsi untuk membuat pembatas garis untuk tabel
    String buildDivider(String left, String mid, String right) {
      final line = List<String>.generate(
        columnWidths.length,
        (i) => ''.padRight(
          columnWidths[i] + 2,
          '─',
        ), // Membuat garis pembatas berdasarkan lebar kolom
      ).join(mid); // Menggabungkan pembatas antar kolom
      return "$left$line$right"; // Menggabungkan pembatas kiri dan kanan
    }

    // Fungsi untuk meratakan teks ke tengah dalam kolom
    String centerText(String text, int width) {
      final len = text.length;
      final pad = width - len;
      final left = (pad / 2).floor(); // Menghitung spasi kiri
      final right = pad - left; // Menghitung spasi kanan
      return ' ' * left +
          text +
          ' ' * right; // Meratakan teks dengan menambahkan spasi kiri dan kanan
    }

    // Fungsi untuk membangun satu baris dalam tabel
    String buildRow(List<dynamic> row, {bool isHeader = false}) {
      return row
          .asMap() // Mengonversi daftar menjadi map untuk mendapatkan indeks dan nilai
          .entries
          .map((entry) {
            final i = entry.key; // Indeks kolom
            final rawText = (entry.value ?? '-').toString(); // Nilai dalam sel
            // Jika baris adalah header, teks akan diratakan di tengah
            final cellText = isHeader
                ? centerText(rawText, columnWidths[i])
                : rawText.padRight(
                    columnWidths[i],
                  ); // Jika bukan header, teks dipadkan ke kanan
            return " $cellText "; // Menambahkan ruang di sekitar teks untuk penataan
          })
          .join("│") // Menyatukan kolom dengan separator
          .replaceAllMapped(
            RegExp(r"^|$"),
            (m) => "│",
          ); // Menambahkan garis pembatas di awal dan akhir baris
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
