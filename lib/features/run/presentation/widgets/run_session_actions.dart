import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/app_confirmation_dialog.dart';
import '../../../../core/common/widgets/app_flushbar.dart';
import '../../domain/services/run_sensor_service.dart';
import '../providers/run_session_provider.dart';
import 'run_end_confirmation_dialog.dart';

abstract final class RunSessionActions {
  static Future<void> start(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(runSessionProvider.notifier);
    final result = await controller.start();
    if (!context.mounted || result == RunPermissionResult.granted) return;

    switch (result) {
      case RunPermissionResult.locationServiceDisabled:
        await _showAccessDialog(
          context,
          titleKey: 'runScreen.locationServiceTitle',
          messageKey: 'runScreen.locationServiceMessage',
          actionKey: 'runScreen.openSettings',
          onAction: controller.openLocationSettings,
        );
      case RunPermissionResult.locationPermissionPermanentlyDenied:
        await _showAccessDialog(
          context,
          titleKey: 'runScreen.locationPermissionTitle',
          messageKey: 'runScreen.locationPermissionPermanentMessage',
          actionKey: 'runScreen.openSettings',
          onAction: controller.openAppSettings,
        );
      case RunPermissionResult.locationPermissionDenied:
        await _showAccessDialog(
          context,
          titleKey: 'runScreen.locationPermissionTitle',
          messageKey: 'runScreen.locationPermissionMessage',
          actionKey: 'runScreen.tryAgain',
          onAction: () async {
            if (context.mounted) await start(context, ref);
            return true;
          },
        );
      case RunPermissionResult.motionPermissionPermanentlyDenied:
        await _showAccessDialog(
          context,
          titleKey: 'runScreen.motionPermissionTitle',
          messageKey: 'runScreen.motionPermissionPermanentMessage',
          actionKey: 'runScreen.openSettings',
          icon: Icons.directions_run_rounded,
          onAction: controller.openAppSettings,
        );
      case RunPermissionResult.motionPermissionDenied:
        await _showAccessDialog(
          context,
          titleKey: 'runScreen.motionPermissionTitle',
          messageKey: 'runScreen.motionPermissionMessage',
          actionKey: 'runScreen.tryAgain',
          icon: Icons.directions_run_rounded,
          onAction: () async {
            if (context.mounted) await start(context, ref);
            return true;
          },
        );
      case RunPermissionResult.failed:
        showMessage(context, 'runScreen.permissionRequestFailed'.tr());
      case RunPermissionResult.granted:
        break;
    }
  }

  static Future<void> confirmEnd(BuildContext context, WidgetRef ref) async {
    final confirmed = await showRunEndConfirmationDialog(context);

    if (confirmed) {
      try {
        final result = await ref.read(runSessionProvider.notifier).end();
        if (context.mounted && result == RunEndResult.discarded) {
          showMessage(context, 'runScreen.runDiscarded'.tr());
        }
      } catch (_) {
        if (context.mounted) {
          showMessage(context, 'runScreen.saveFailed'.tr());
        }
      }
    }
  }

  static void showMessage(BuildContext context, String message) {
    AppFlushbar.info(context, message);
  }

  static Future<void> _showAccessDialog(
    BuildContext context, {
    required String titleKey,
    required String messageKey,
    required String actionKey,
    required Future<bool> Function() onAction,
    IconData icon = Icons.location_on_rounded,
  }) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: titleKey.tr(),
      message: messageKey.tr(),
      cancelLabel: 'runScreen.cancel'.tr(),
      confirmLabel: actionKey.tr(),
      icon: icon,
    );
    if (confirmed) await onAction();
  }
}
