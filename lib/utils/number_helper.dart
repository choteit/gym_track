class NumberHelper {
  /// Convertit un nombre au format français (virgule) vers le format anglais (point)
  static String convertFrenchToEnglishDecimal(String input) {
    return input.replaceAll(',', '.');
  }

  /// Parse un double en gérant les formats français et anglais
  static double? parseDouble(String input) {
    if (input.isEmpty) return null;

    try {
      // Convertir les virgules en points
      String normalizedInput = convertFrenchToEnglishDecimal(input);
      return double.parse(normalizedInput);
    } catch (e) {
      return null;
    }
  }

  /// Valide si une chaîne peut être convertie en double
  static bool isValidDouble(String input) {
    return parseDouble(input) != null;
  }
}
