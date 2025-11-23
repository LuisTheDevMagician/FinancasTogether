import 'package:flutter/material.dart';

class AppConstants {
  // Paleta de cores para categorias e usuários
  static const List<Color> availableColors = [
    Color(0xFF4A90E2), // Azul
    Color(0xFF50C878), // Verde
    Color(0xFFE67E22), // Laranja
    Color(0xFF9B59B6), // Roxo
    Color(0xFFE74C3C), // Vermelho
    Color(0xFF1ABC9C), // Turquesa
    Color(0xFFF39C12), // Amarelo dourado
    Color(0xFF34495E), // Azul acinzentado
    Color(0xFFC0392B), // Vermelho escuro
    Color(0xFF16A085), // Verde marinho
    Color(0xFFD35400), // Abóbora
    Color(0xFF8E44AD), // Roxo escuro
  ];

  // Converte lista de Color para String hex
  static List<String> get availableColorHexList {
    return availableColors
        .map(
          (color) =>
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
        )
        .toList();
  }

  // Converte String hex para Color
  static Color hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  // Converte Color para String hex
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  // SharedPreferences Keys
  static const String prefKeyActiveUserId = 'active_user_id';
  static const String prefKeyThemeMode = 'theme_mode';

  // Database
  static const String databaseName = 'financas_together.db';
  static const int databaseVersion = 1;

  // Paginação
  static const int historyPageSize = 50;

  // Formato de data
  static const String dateFormatPattern = 'dd/MM/yyyy';
  static const String dateTimeFormatPattern = 'dd/MM/yyyy HH:mm';
  static const String timeFormatPattern = 'HH:mm';
}

// Enum para períodos de filtro
enum Period {
  day,
  week,
  month,
  year;

  String get label {
    switch (this) {
      case Period.day:
        return 'Dia';
      case Period.week:
        return 'Semana';
      case Period.month:
        return 'Mês';
      case Period.year:
        return 'Ano';
    }
  }
}
