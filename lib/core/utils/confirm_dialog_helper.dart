import 'package:flutter/material.dart';

class ConfirmDialogHelper {
  /// Show confirmation dialog
  static Future<void> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmButtonText = 'Confirm',
    String cancelButtonText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return _showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmButtonText: confirmButtonText,
      cancelButtonText: cancelButtonText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Private helper to show confirmation dialog
  static Future<void> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmButtonText,
    required String cancelButtonText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
                      // Message
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Buttons
                Column(
                  children: [
                    // Divider
                    Container(height: 0.5, color: Colors.grey.shade300),
                    // Confirm Button
                    _DialogButton(
                      text: confirmButtonText,
                      textColor: Colors.blue,
                      fontWeight: FontWeight.w600,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                    ),

                    // Cancel Button
                    Container(height: 0.5, color: Colors.grey.shade300),
                    _DialogButton(
                      text: cancelButtonText,
                      textColor: Colors.grey,
                      fontWeight: FontWeight.w600,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
