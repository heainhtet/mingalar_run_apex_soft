import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/utils/measurement_formatter.dart';
import '../../domain/entities/run_day_stat.dart';

abstract final class RunShareService {
  static String formatDay(RunDayStat day) {
    final pace = day.pacePerKilometer;
    final paceText = pace == null
        ? '0:00'
        : '${pace.inMinutes}:${pace.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return '${'profileScreen.sharedRunTitle'.tr()}\n'
        '${DateFormat('dd MMM yyyy').format(day.date)}\n'
        '${MeasurementFormatter.distance(day.distanceKilometers).label} • '
        '${day.duration.inMinutes} min • '
        '${day.calories} cal • $paceText min/km';
  }

  static Future<void> shareDay(RunDayStat day, Rect? origin) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'Mingalar Run',
          subject: 'profileScreen.sharedRunSubject'.tr(),
          text: formatDay(day),
          sharePositionOrigin: origin,
        ),
      );
      logger.i('Run summary shared for ${day.date.toIso8601String()}');
    } catch (error, stackTrace) {
      logger.e(
        'Unable to open the platform share sheet',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
