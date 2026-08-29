import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

class CommonTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final bool showPasswordToggle;
  final VoidCallback? onTogglePassword;
  final bool enabled;
  final int? maxLength;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final void Function(String)? onChanged;
  final bool? aiSupport;
  final Function(String)? onSubmitted;
  final Color? labelTextColor;
  final String? errorText;
  final bool showError;
  final FocusNode? focusNode;

  final List<TextInputFormatter>? inputFormatters;

  const CommonTextFieldWidget({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.validator,
    this.showPasswordToggle = false,
    this.onTogglePassword,
    this.enabled = true,
    this.maxLength,
    this.labelText = '',
    this.obscureText = false,
    this.keyboardType,
    this.maxLines,
    this.minLines,
    this.readOnly = false,
    this.onChanged,
    this.aiSupport = false,
    this.onSubmitted,
    this.labelTextColor,
    this.errorText,
    this.showError = false,
    this.focusNode,
    this.inputFormatters,
  });

  @override
  State<CommonTextFieldWidget> createState() => CommonTextFieldWidgetState();
}

class CommonTextFieldWidgetState extends State<CommonTextFieldWidget> {
  int _currentLength = 0;

  void _updateCounter() {
    setState(() {
      _currentLength = widget.controller.text.length;
    });
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      counterText: '',
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade500),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.onBoardingWelcomeText,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      errorText: widget.showError ? widget.errorText : null,
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      errorMaxLines: 2,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateCounter);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCounter);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  widget.labelText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: widget.labelTextColor ?? AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.readOnly)
                  Text(
                    ' (read-only)',
                    style: TextStyle(
                      color: widget.labelTextColor ?? AppColors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: widget.obscureText,
              maxLength: widget.maxLength,
              validator: widget.validator,
              enabled: widget.enabled,
              maxLines: widget.maxLines ?? 1,
              minLines: widget.minLines ?? 1,
              readOnly: widget.readOnly,
              inputFormatters: widget.inputFormatters,
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              keyboardType: widget.keyboardType ?? TextInputType.text,
              onFieldSubmitted: widget.onSubmitted,
              decoration: _fieldDecoration(widget.hint).copyWith(
                suffixIcon: widget.isPassword && widget.showPasswordToggle
                    ? IconButton(
                        icon: Icon(
                          widget.obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: widget.showError ? Colors.red : Colors.grey,
                        ),
                        onPressed: widget.onTogglePassword,
                      )
                    : null,
              ),
            ),
            if (widget.maxLength != null)
              Positioned(
                right: 12,
                bottom: 6,
                child: Text(
                  '$_currentLength / ${widget.maxLength}',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.showError ? Colors.red : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        if (widget.showError && widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
