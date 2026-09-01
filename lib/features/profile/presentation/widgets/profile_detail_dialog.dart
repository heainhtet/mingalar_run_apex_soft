import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/common/widgets/app_flushbar.dart';
import '../../../../core/common/widgets/primary_button_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/profile_models.dart';
import '../providers/profile_providers.dart';
import 'profile_avatar.dart';
import 'profile_information_form.dart';

/// Opens the local profile editor. QR display remains a separate action.
Future<void> showProfileEditorDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref.read(profileProvider.future);
  if (!context.mounted) return;

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(153),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, _, _) => const ProfileDetailDialog(),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class ProfileDetailDialog extends ConsumerStatefulWidget {
  const ProfileDetailDialog({super.key});

  @override
  ConsumerState<ProfileDetailDialog> createState() =>
      _ProfileDetailDialogState();
}

class _ProfileDetailDialogState extends ConsumerState<ProfileDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).value?.user;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider).value ?? const ProfileState();
    final user = state.user;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: AppColors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProfileEditorHeader(
                  onClose: () => Navigator.of(context).pop(),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      children: [
                        ProfileAvatar(
                          avatarPath: user?.avatarPath,
                          size: 108,
                          showEditIndicator: user != null,
                          onTap: user == null || state.isSaving
                              ? null
                              : _chooseProfilePhoto,
                        ),
                        const Gap(14),
                        if (user != null) ...[
                          PrimaryButtonWidget(
                            text: user.avatarPath == null
                                ? 'profileScreen.addProfilePhoto'.tr()
                                : 'profileScreen.changeProfilePhoto'.tr(),
                            height: 46,
                            borderRadius: 23,
                            variant: PrimaryButtonVariant.outlined,
                            borderColor: AppColors.primaryButtonColor,
                            textColor: AppColors.primaryButtonColor,
                            isLoading: state.isSaving,
                            onPressed: _chooseProfilePhoto,
                          ),
                          const Gap(20),
                        ],
                        ProfileInformationForm(
                          formKey: _formKey,
                          nameController: _nameController,
                          phoneController: _phoneController,
                          isSaving: state.isSaving,
                          onSave: _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref
          .read(profileProvider.notifier)
          .saveProfile(
            name: _nameController.text,
            phoneNumber: _phoneController.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        AppFlushbar.error(context, 'profileScreen.profileSaveFailed'.tr());
      }
    }
  }

  Future<void> _chooseProfilePhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 88,
    );
    if (image == null || !mounted) return;
    try {
      await ref.read(profileProvider.notifier).updateAvatar(image.path);
    } catch (_) {
      if (mounted) {
        AppFlushbar.error(context, 'profileScreen.profilePhotoFailed'.tr());
      }
    }
  }
}

class _ProfileEditorHeader extends StatelessWidget {
  const _ProfileEditorHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.runGradientStart, AppColors.runGradientEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
        child: Row(
          children: [
            const Icon(
              Icons.account_circle_outlined,
              color: AppColors.defaultPrimaryText,
              size: 24,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                'profileScreen.profileInformation'.tr(),
                style: AppTextStyles.semiBold().white
                    .s(20)
                    .copyWith(color: AppColors.defaultPrimaryText),
              ),
            ),
            IconButton(
              onPressed: onClose,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.defaultPrimaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
