import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/profile_models.dart';
import '../providers/profile_providers.dart';
import 'profile_information_form.dart';

Future<void> showProfileQrDialog(
  BuildContext context,
  WidgetRef ref, {
  bool editImmediately = false,
}) async {
  final profileState = await ref.read(profileProvider.future);
  if (editImmediately || profileState.user == null) {
    ref.read(profileProvider.notifier).beginEditing();
  }

  if (!context.mounted) return;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(153),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const ProfileQrDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
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

class ProfileQrDialog extends ConsumerStatefulWidget {
  const ProfileQrDialog({super.key});

  @override
  ConsumerState<ProfileQrDialog> createState() => _ProfileQrDialogState();
}

class _ProfileQrDialogState extends ConsumerState<ProfileQrDialog> {
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
    final showForm = state.user == null || state.isEditing;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && state.isEditing) {
          ref.read(profileProvider.notifier).cancelEditing();
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogHeader(
                  title: showForm
                      ? 'profileScreen.profileInformation'.tr()
                      : 'profileScreen.yourQr'.tr(),
                  onClose: () => Navigator.of(context).pop(),
                ),
                const Gap(20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.96,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: showForm
                      ? ProfileInformationForm(
                          key: const ValueKey('profile-form'),
                          formKey: _formKey,
                          nameController: _nameController,
                          phoneController: _phoneController,
                          isSaving: state.isSaving,
                          onSave: _save,
                        )
                      : _QrContent(
                          key: const ValueKey('profile-qr'),
                          user: state.user!,
                          onEdit: () =>
                              ref.read(profileProvider.notifier).beginEditing(),
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

    await ref
        .read(profileProvider.notifier)
        .saveProfile(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
        );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.semiBold().black
                .s(20)
                .copyWith(
                  color: AppColors.cardLabelText,
                  height: 1.2,
                  letterSpacing: -0.31,
                ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
          color: AppColors.cardLabelText,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _QrContent extends StatelessWidget {
  const _QrContent({super.key, required this.user, required this.onEdit});

  final UserProfile user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withAlpha(26),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: QrImageView(
              data: user.qrPayload,
              size: 220,
              backgroundColor: AppColors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.qrCodeColor,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.qrCodeColor,
              ),
            ),
          ),
        ),
        const Gap(18),
        Text(
          user.name,
          style: AppTextStyles.semiBold().black
              .s(18)
              .copyWith(
                color: AppColors.cardLabelText,
                height: 1.3,
                letterSpacing: -0.31,
              ),
        ),
        Text(
          user.phoneNumber,
          style: AppTextStyles.regular().black
              .s(14)
              .copyWith(
                color: AppColors.scoreSumLabelTextColor,
                height: 20 / 14,
                letterSpacing: -0.15,
              ),
        ),
        const Gap(12),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text('profileScreen.editInformation'.tr()),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.tabIndicatorColor,
          ),
        ),
      ],
    );
  }
}
