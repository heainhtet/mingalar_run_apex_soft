import 'package:flutter/material.dart';

import '../common/widgets/info_dialog.dart';

class InfoDialogHelper {
  /// Show success dialog
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return InfoDialog.show(
      context,
      title: title,
      description: message,
      buttonText: buttonText,
      buttonTextColor: Colors.green,
      iconData: Icons.check_circle_outline,
      iconColor: Colors.green,
      onPressed: onPressed,
    );
  }

  /// Show error dialog
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return InfoDialog.show(
      context,
      title: title,
      description: message,
      buttonText: buttonText,
      buttonTextColor: Colors.red,
      iconData: Icons.error_outline,
      iconColor: Colors.red,
      onPressed: onPressed,
    );
  }

  /// Show warning dialog
  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return InfoDialog.show(
      context,
      title: title,
      description: message,
      buttonText: buttonText,
      buttonTextColor: Colors.orange,
      iconData: Icons.warning_amber_outlined,
      iconColor: Colors.orange,
      onPressed: onPressed,
    );
  }

  /// Show info dialog
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    final TextAlign? textAlign,
  }) {
    return InfoDialog.show(
      context,
      title: title,
      description: message,
      buttonText: buttonText,
      buttonTextColor: Colors.blue,
      iconData: Icons.info_outline,
      iconColor: Colors.blue,
      onPressed: onPressed,
      textAlign: textAlign,
    );
  }

  static Future<void> showCustomInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    VoidCallback? onCancelPressed,
    final TextAlign? textAlign,
    required Widget icon,
  }) {
    return InfoDialog.show(
      context,
      title: title,
      description: message,
      buttonText: buttonText,
      buttonTextColor: Colors.blue,
      iconData: Icons.info_outline,
      iconColor: Colors.blue,
      onPressed: onPressed,
      textAlign: textAlign,
      icon: icon,
      onCancelPressed: onCancelPressed,
    );
  }

  /// Show notification/alert dialog
  static Future<void> showNotification(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Got it',
    VoidCallback? onPressed,
  }) {
    return InfoDialog.show(
      context,
      title: title,
      description: message,
      buttonText: buttonText,
      buttonTextColor: Colors.blue,
      iconData: Icons.notifications_outlined,
      iconColor: Colors.blue,
      onPressed: onPressed,
    );
  }

  /// Show plain info dialog (no icon)
  static Future<void> showPlainInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return InfoDialog.show(
      context,
      title: title,
      description: message,
      buttonText: buttonText,
      buttonTextColor: Colors.blue,
      onPressed: onPressed,
    );
  }

  /// Show custom dialog with custom icon
  static Future<void> showCustom(
    BuildContext context, {
    required String title,
    required String message,
    required Widget customIcon,
    String buttonText = 'OK',
    Color buttonTextColor = Colors.blue,
    VoidCallback? onPressed,
  }) {
    return InfoDialog.show(
      context,
      title: title,
      description: message,
      buttonText: buttonText,
      buttonTextColor: buttonTextColor,
      icon: customIcon,
      onPressed: onPressed,
    );
  }
}

// Example usage:
/*
// Basic usage
await InfoDialog.show(
  context,
  title: 'Information',
  description: 'This is some important information for you.',
);

// With icon
await InfoDialog.show(
  context,
  title: 'Success',
  description: 'Your action was completed successfully!',
  iconData: Icons.check_circle_outline,
  iconColor: Colors.green,
  buttonTextColor: Colors.green,
);

// Using helper methods
await InfoDialogHelper.showSuccess(
  context,
  title: 'Success',
  message: 'Profile updated successfully!',
);

await InfoDialogHelper.showError(
  context,
  title: 'Error',
  message: 'Failed to connect to server. Please try again.',
);

await InfoDialogHelper.showWarning(
  context,
  title: 'Warning',
  message: 'This action will affect all your data.',
);
*/
