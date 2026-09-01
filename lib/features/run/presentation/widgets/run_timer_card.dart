import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/common/widgets/primary_button_widget.dart';
import '../../../../core/constants/assets_constant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';
import '../providers/run_session_provider.dart';
import 'run_live_stats.dart';
import 'run_session_actions.dart';

class RunTimerCard extends ConsumerWidget {
  const RunTimerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(runSessionProvider);
    final controller = ref.read(runSessionProvider.notifier);
    ref.listen(runSessionProvider.select((value) => value.sensorError), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        RunSessionActions.showMessage(context, 'runScreen.sensorPaused'.tr());
      }
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x80989898), width: 0.71),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A101828),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 25,
            spreadRadius: -5,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'runScreen.startYourRun'.tr(),
                  style: AppTextStyles.semiBold()
                      .s(18)
                      .copyWith(
                        color: AppColors.primaryText(context),
                        height: 28 / 18,
                        letterSpacing: -0.44,
                      ),
                ),
              ),
              SvgPicture.asset(AssetsConstant.upIcon, width: 24, height: 24),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              _formatElapsed(session.elapsed),
              style: AppTextStyles.medium().white
                  .s(72)
                  .copyWith(
                    color: AppColors.counterTextColor,
                    height: 100 / 80,
                    letterSpacing: 0,
                  ),
            ),
          ),
          if (session.hasStarted) ...[
            const Gap(6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  session.stage.labelKey.tr(),
                  style: AppTextStyles.medium()
                      .s(12)
                      .copyWith(
                        color: AppColors.primaryText(context),
                        height: 1,
                        letterSpacing: 0,
                      ),
                ),
              ),
            ),
          ],
          const Gap(10),
          if (session.hasStarted)
            RunLiveStats(state: session)
          else
            Text(
              'runScreen.motivation'.tr(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.regular()
                  .s(14)
                  .copyWith(
                    color: AppColors.secondaryText(context),
                    height: 20 / 14,
                    letterSpacing: -0.15,
                  ),
            ),
          const SizedBox(height: 22),
          if (!session.hasStarted)
            PrimaryButtonWidget(
              text: 'runScreen.startRun'.tr(),
              onPressed: () => RunSessionActions.start(context, ref),
              height: 52,
              borderRadius: 30,
              backgroundColor: AppColors.primaryButtonColor,
              textColor: AppColors.defaultPrimaryText,
              textStyle: AppTextStyles.semiBold().white
                  .s(18)
                  .copyWith(
                    color: AppColors.defaultPrimaryText,
                    height: 20 / 18,
                    letterSpacing: 0,
                  ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: PrimaryButtonWidget(
                    text: session.isRunning
                        ? 'runScreen.pause'.tr()
                        : 'runScreen.resume'.tr(),
                    onPressed: session.isRunning
                        ? controller.pause
                        : controller.resume,
                    isLoading: session.isSaving,
                    height: 52,
                    borderRadius: 30,
                    backgroundColor: AppColors.primaryButtonColor,
                    textColor: AppColors.defaultPrimaryText,
                    textStyle: AppTextStyles.semiBold().white
                        .s(18)
                        .copyWith(
                          color: AppColors.defaultPrimaryText,
                          height: 20 / 18,
                          letterSpacing: 0,
                        ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: PrimaryButtonWidget(
                    text: 'runScreen.end'.tr(),
                    onPressed: () => RunSessionActions.confirmEnd(context, ref),
                    isLoading: session.isSaving,
                    height: 52,
                    borderRadius: 30,
                    variant: PrimaryButtonVariant.outlined,
                    borderColor: AppColors.caloriesIconColor,
                    textColor: AppColors.caloriesIconColor,
                    textStyle: AppTextStyles.semiBold().white
                        .s(18)
                        .copyWith(
                          color: AppColors.caloriesIconColor,
                          height: 20 / 18,
                          letterSpacing: 0,
                        ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatElapsed(Duration elapsed) {
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
