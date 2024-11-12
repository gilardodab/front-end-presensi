const List<String> _dayNames = [
  'Minggu',
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu'
];

const List<String> _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember'
];

extension DateTimeExt on DateTime {
  String toFormattedDate() {
    final String dayName = _dayNames[this.weekday - 1]; // Ambil nama hari
    final String day = this.day.toString().padLeft(2, '0');
    final String month = _monthNames[this.month - 1];
    final String year = this.year.toString();

    return '$dayName, $day $month $year';
  }

  String toFormattedTime() {
    // Konversi waktu ke UTC+7 (WIB)
    final DateTime wibTime = this.toUtc().add(const Duration(hours: 7));
    final String hour = wibTime.hour.toString().padLeft(2, '0');
    final String minute = wibTime.minute.toString().padLeft(2, '0');
    final String second = wibTime.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second WIB';
  }
}
