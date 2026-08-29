import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class InfoDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    VoidCallback? onCancelPressed,
    Color buttonTextColor = Colors.blue,
    bool isDismissible = true,
    Widget? icon,
    Color? iconColor,
    IconData? iconData,
    final TextAlign? textAlign,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return _IOSInfoDialog(
          title: title,
          description: description,
          buttonText: buttonText,
          onPressed: onPressed,
          buttonTextColor: buttonTextColor,
          icon: icon,
          iconColor: iconColor,
          iconData: iconData,
          textAlign: textAlign,
          onCancelPressed: onCancelPressed,
        );
      },
    );
  }
}

class _IOSInfoDialog extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onPressed;
  final VoidCallback? onCancelPressed;
  final Color buttonTextColor;
  final Widget? icon;
  final Color? iconColor;
  final IconData? iconData;
  final TextAlign? textAlign;
  const _IOSInfoDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    this.onPressed,
    this.onCancelPressed,
    required this.buttonTextColor,
    this.icon,
    this.iconColor,
    this.iconData,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  // Icon (if provided)
                  if (icon != null || iconData != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child:
                          icon ??
                          Icon(
                            iconData,
                            size: 64,
                            color: iconColor ?? Colors.blue,
                          ),
                    ),
                  ],
                  // Title
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: textAlign ?? TextAlign.center,
                  ),
                ],
              ),
            ),
            // Button
            Column(
              children: [
                // Divider
                Container(height: 0.5, color: Colors.grey.shade300),
                // OK Button
                _DialogButton(
                  text: buttonText,
                  textColor: buttonTextColor,
                  fontWeight: FontWeight.w600,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPressed?.call();
                  },
                ),
                if (onCancelPressed != null) ...[
                  // Divider
                  Container(height: 0.5, color: Colors.grey.shade300),
                  // Cancel Button
                  _DialogButton(
                    text: 'Cancel',
                    textColor: AppColors.primaryButtonColor,
                    fontWeight: FontWeight.w600,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancelPressed?.call();
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final FontWeight fontWeight;
  final VoidCallback onPressed;

  const _DialogButton({
    required this.text,
    required this.textColor,
    required this.fontWeight,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        child: Container(
          width: double.infinity,
          height: 44,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
