extension NumberFormatting on num {
  String formatWithCommas() {
    final parts = toString().split('.');
    final integerPart = parts[0];
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    if (parts.length > 1) {
      return '$formattedInteger.${parts[1]}';
    }
    return formattedInteger;
  }
}
