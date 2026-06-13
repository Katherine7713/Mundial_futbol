import 'package:intl/intl.dart';

class MundialUtils {
  static String toApiFormat(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);
  static String toDisplayDate(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'es').format(date);
  static String toLocalDate(String? mdlDateString) {
    if (mdlDateString == null || mdlDateString.isEmpty) return '-';
    try {
      final mdlDate = DateTime.parse(mdlDateString).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm', 'es').format(mdlDate);
    } catch (_) {
      return mdlDateString;
    }
  }

  static bool sameDay(DateTime actual, DateTime partido) =>
      actual.year == partido.year &&
      actual.month == partido.month &&
      actual.day == partido.day;
  static DateTime get worldCupStart => DateTime(2026, 6, 11);
  static DateTime get worldCupEnd => DateTime(2026, 7, 19);
}
