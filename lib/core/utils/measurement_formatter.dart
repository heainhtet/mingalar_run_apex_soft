class DistanceDisplay {
  const DistanceDisplay({required this.value, required this.unit});

  final String value;
  final String unit;

  String get label => '$value $unit';
}

abstract final class MeasurementFormatter {
  static DistanceDisplay distance(double kilometers) {
    if (!kilometers.isFinite || kilometers <= 0) {
      return const DistanceDisplay(value: '0', unit: 'm');
    }

    if (kilometers < 1) {
      return DistanceDisplay(
        value: (kilometers * 1000).round().toString(),
        unit: 'm',
      );
    }

    return DistanceDisplay(value: kilometers.toStringAsFixed(1), unit: 'km');
  }

  static String duration(Duration duration) {
    if (duration.inHours > 0) {
      final minutes = duration.inMinutes.remainder(Duration.minutesPerHour);
      return '${duration.inHours} hr ${minutes.toString().padLeft(2, '0')} min';
    }
    if (duration.inMinutes > 0) return '${duration.inMinutes} min';
    return '${duration.inSeconds} sec';
  }

  static String pace(Duration? pace) {
    if (pace == null || pace <= Duration.zero) return '0:00';
    final seconds = pace.inSeconds.remainder(Duration.secondsPerMinute);
    return '${pace.inMinutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
