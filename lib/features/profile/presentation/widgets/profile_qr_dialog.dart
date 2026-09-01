import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';
import 'profile_detail_dialog.dart';

Future<void> showProfileQrDialog(BuildContext context, WidgetRef ref) async {
  final state = await ref.read(profileProvider.future);
  if (!context.mounted) return;
  if (state.user == null) {
    await showProfileEditorDialog(context, ref);
    return;
  }

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.black.withAlpha(153),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, _, _) => _ProfileQrDialog(user: state.user!),
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

class _ProfileQrDialog extends ConsumerWidget {
  const _ProfileQrDialog({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rank = ref.watch(profileRankProvider);
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'profileScreen.yourQr'.tr(),
                      style: AppTextStyles.semiBold().black
                          .s(20)
                          .copyWith(color: AppColors.cardLabelText),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.cardLabelText,
                  ),
                ],
              ),
              const Gap(20),
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
                    data: user.qrPayloadFor(
                      tier: rank.tier.label,
                      ionPoints: rank.ionPoints,
                    ),
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
                    .copyWith(color: AppColors.cardLabelText),
              ),
              Text(
                user.phoneNumber,
                style: AppTextStyles.regular().black
                    .s(14)
                    .copyWith(color: AppColors.scoreSumLabelTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
