import 'package:intl/intl.dart';
import '../utils/constants.dart';

class DateHelpers {
  // Formatar data como dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormatPattern, 'pt_BR').format(date);
  }

  // Formatar data e hora como dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormatPattern, 'pt_BR').format(date);
  }

  // Formatar hora como HH:mm
  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormatPattern, 'pt_BR').format(date);
  }

  // Obter início do dia
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Obter fim do dia
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Obter início da semana (segunda-feira)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  // Obter fim da semana (domingo)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(
      date.year,
      date.month,
      date.day + (7 - weekday),
      23,
      59,
      59,
    );
  }

  // Obter início do mês
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Obter fim do mês
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  // Obter início do ano
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  // Obter fim do ano
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }

  // Obter nome do mês
  static String getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }

  // Obter nome do dia da semana
  static String getWeekdayName(int weekday) {
    const weekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return weekdays[weekday - 1];
  }

  // Agrupar semanas de um mês
  static List<DateRange> getWeeksInMonth(DateTime month) {
    final firstDay = startOfMonth(month);
    final lastDay = endOfMonth(month);

    List<DateRange> weeks = [];
    DateTime current = firstDay;

    while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
      final weekStart = startOfWeek(current);
      final weekEnd = endOfWeek(current);

      // Ajustar para o mês correto
      final adjustedStart = weekStart.isBefore(firstDay) ? firstDay : weekStart;
      final adjustedEnd = weekEnd.isAfter(lastDay) ? lastDay : weekEnd;

      weeks.add(DateRange(start: adjustedStart, end: adjustedEnd));

      current = adjustedEnd.add(const Duration(days: 1));
    }

    return weeks;
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  bool contains(DateTime date) {
    return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
        (date.isBefore(end) || date.isAtSameMomentAs(end));
  }
}
