import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/common/widgets/app_flushbar.dart';
import '../../../../core/database/hive_database.dart';
import '../../../../core/routers/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/text_extensions.dart';
import '../../../run/presentation/providers/run_providers.dart';
import '../../../run/presentation/providers/run_session_provider.dart';
import '../models/profile_models.dart';
import '../providers/profile_providers.dart';
import 'profile_information_form.dart';

enum ProfileDialogMode { editor, qr }

Future<void> showProfileQrDialog(BuildContext context, WidgetRef ref) async {
  final profile = await ref.read(profileProvider.future);
  if (!context.mounted) return;
  return _showProfileDialog(
    context,
    mode: profile.user == null
        ? ProfileDialogMode.editor
        : ProfileDialogMode.qr,
  );
}

Future<void> showProfileSettingsDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref.read(profileProvider.future);
  if (!context.mounted) return;
  return _showProfileDialog(context, mode: ProfileDialogMode.editor);
}

Future<void> _showProfileDialog(
  BuildContext context, {
  required ProfileDialogMode mode,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(153),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ProfileQrDialog(mode: mode);
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
  const ProfileQrDialog({super.key, required this.mode});

  final ProfileDialogMode mode;

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
    final showsEditor = widget.mode == ProfileDialogMode.editor;

    return Dialog(
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
                title: showsEditor
                    ? 'profileScreen.profileInformation'.tr()
                    : 'profileScreen.yourQr'.tr(),
                onClose: () => Navigator.of(context).pop(),
              ),
              const Gap(20),
              if (showsEditor)
                ProfileInformationForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  isSaving: state.isSaving,
                  onSave: _save,
                  onDeleteAccount: state.user == null ? null : _deleteAccount,
                )
              else
                _QrContent(user: state.user!),
            ],
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
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'profileScreen.deleteAccountTitle'.tr(),
          style: AppTextStyles.semiBold()
              .s(18)
              .copyWith(color: AppColors.cardLabelText, height: 1.25),
        ),
        content: Text(
          'profileScreen.deleteAccountMessage'.tr(),
          style: AppTextStyles.regular()
              .s(14)
              .copyWith(color: AppColors.cardDescriptionText, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('runScreen.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'profileScreen.deleteEverything'.tr(),
              style: const TextStyle(color: AppColors.caloriesIconColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(runSessionProvider.notifier).reset();
      await HiveDatabase.clearAllUserData();
      ref.invalidate(profileProvider);
      ref.invalidate(runActivitiesProvider);
      if (!mounted) return;
      final router = context.router;
      Navigator.of(context, rootNavigator: true).pop();
      router.replaceAll([const OnBoardingRoute()]);
    } catch (error, stackTrace) {
      logger.e(
        'Unable to clear local user data',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        AppFlushbar.error(context, 'profileScreen.deleteFailed'.tr());
      }
    }
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
  const _QrContent({required this.user});

  final UserProfile user;

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
      ],
    );
  }
}
