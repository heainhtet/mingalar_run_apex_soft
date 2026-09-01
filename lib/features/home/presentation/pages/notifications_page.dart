import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/measurement_formatter.dart';
import '../../../../core/utils/text_extensions.dart';
import '../models/home_notification.dart';
import '../providers/home_notification_providers.dart';

@RoutePage()
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(homeNotificationsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.homeGradient(context).first,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground(context),
        body: Column(
          children: [
            _NotificationHeader(onBack: context.router.maybePop),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                physics: const BouncingScrollPhysics(),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _NotificationTile(notification: notifications[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.homeGradient(context),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 20, 22),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.defaultPrimaryText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'notificationsScreen.title'.tr(),
                      style: AppTextStyles.semiBold().white
                          .s(22)
                          .copyWith(
                            color: AppColors.defaultPrimaryText,
                            height: 1.15,
                            letterSpacing: -0.31,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'notificationsScreen.subtitle'.tr(),
                      style: AppTextStyles.regular().white
                          .s(12)
                          .copyWith(
                            color: AppColors.defaultPrimaryText.withAlpha(190),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final HomeNotification notification;

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(notification);
    final isActive = notification.type == HomeNotificationType.activeRun;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.tabIndicatorColor.withAlpha(13)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.tabIndicatorColor.withAlpha(45)
              : AppColors.inactiveIconColor.withAlpha(150),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context, lightAlpha: 12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: content.color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(content.icon, color: content.color, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        content.titleKey.tr(),
                        style: AppTextStyles.semiBold()
                            .s(14)
                            .copyWith(
                              color: AppColors.primaryText(context),
                              height: 1.25,
                            ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.completeRecordColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  content.message,
                  style: AppTextStyles.regular()
                      .s(12)
                      .copyWith(
                        color: AppColors.secondaryText(context),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(notification.createdAt),
                  style: AppTextStyles.regular()
                      .s(10)
                      .copyWith(
                        color: AppColors.secondaryText(context),
                        height: 1,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _NotificationContent _contentFor(HomeNotification item) {
    return switch (item.type) {
      HomeNotificationType.activeRun => _NotificationContent(
        icon: Icons.directions_run_rounded,
        color: AppColors.tabIndicatorColor,
        titleKey: 'notificationsScreen.activeRun',
        message:
            '${MeasurementFormatter.distance(item.distanceKilometers).label} • '
            '${MeasurementFormatter.duration(item.duration)} • '
            '${item.calories} cal',
      ),
      HomeNotificationType.completedRun => _NotificationContent(
        icon: Icons.check_rounded,
        color: AppColors.completeRecordColor,
        titleKey: 'notificationsScreen.runCompleted',
        message:
            '${MeasurementFormatter.distance(item.distanceKilometers).label} • '
            '${MeasurementFormatter.duration(item.duration)} • '
            '${item.calories} cal',
      ),
      HomeNotificationType.welcome => _NotificationContent(
        icon: Icons.waving_hand_outlined,
        color: AppColors.tabIndicatorColor,
        titleKey: 'notificationsScreen.welcomeTitle',
        message: 'notificationsScreen.welcomeMessage'.tr(),
      ),
    };
  }
}

class _NotificationContent {
  const _NotificationContent({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String titleKey;
  final String message;
}
