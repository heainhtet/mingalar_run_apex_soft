import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/common/widgets/primary_button_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class ProfileInformationForm extends StatelessWidget {
  const ProfileInformationForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.isSaving,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _ProfileTextField(
            controller: nameController,
            label: 'profileScreen.name'.tr(),
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'profileScreen.nameRequired'.tr()
                : null,
          ),
          const Gap(14),
          _ProfileTextField(
            controller: phoneController,
            label: 'profileScreen.phoneNumber'.tr(),
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSave(),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'profileScreen.phoneRequired'.tr()
                : null,
          ),
          const Gap(22),
          PrimaryButtonWidget(
            text: 'profileScreen.saveAndGenerate'.tr(),
            height: 50,
            borderRadius: 25,
            isLoading: isSaving,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: AppTextStyles.regular().black
          .s(14)
          .copyWith(color: AppColors.cardLabelText, letterSpacing: -0.15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.tabIndicatorColor),
        filled: true,
        fillColor: AppColors.scoreSumLabelTextColor.withAlpha(13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.tabIndicatorColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
