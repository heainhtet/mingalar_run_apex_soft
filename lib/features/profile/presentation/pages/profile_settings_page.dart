import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/common/widgets/app_confirmation_dialog.dart';
import '../../../../core/common/widgets/app_flushbar.dart';
import '../../../../core/common/widgets/custom_theme_switch.dart';
import '../../../../core/database/hive_database.dart';
import '../../../../core/routers/app_router.gr.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/text_extensions.dart';
import '../../../run/presentation/providers/run_providers.dart';
import '../../../run/presentation/providers/run_session_provider.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_settings_header.dart';
import '../widgets/profile_settings_surface.dart';

@RoutePage()
class ProfileSettingsPage extends ConsumerWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
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
            ProfileSettingsHeader(onBack: () => context.router.maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  Text(
                    'profileScreen.appearance'.tr(),
                    style: _sectionStyle(context),
                  ),
                  const Gap(12),
                  ProfileSettingsSurface(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.dark_mode_outlined,
                        color: AppColors.primaryButtonColor,
                      ),
                      title: Text(
                        'profileScreen.darkMode'.tr(),
                        style: _titleStyle(context),
                      ),
                      subtitle: Text(
                        settings.themeMode == ThemeMode.dark
                            ? 'profileScreen.darkModeEnabled'.tr()
                            : 'profileScreen.lightModeEnabled'.tr(),
                        style: _subtitleStyle(context),
                      ),
                      trailing: const CustomThemeSwitch(),
                    ),
                  ),
                  const Gap(28),
                  Text(
                    'profileScreen.language'.tr(),
                    style: _sectionStyle(context),
                  ),
                  const Gap(12),
                  ProfileSettingsSurface(
                    child: RadioGroup<AppLanguage>(
                      groupValue: settings.language,
                      onChanged: (language) {
                        if (language != null) {
                          _setLanguage(context, ref, language);
                        }
                      },
                      child: Column(
                        children: [
                          _LanguageOption(
                            title: 'profileScreen.english'.tr(),
                            value: AppLanguage.english,
                          ),
                          Divider(
                            height: 1,
                            color: AppColors.scoreSumLabelTextColor.withAlpha(
                              38,
                            ),
                          ),
                          _LanguageOption(
                            title: 'profileScreen.burmese'.tr(),
                            value: AppLanguage.burmese,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(28),
                  Text(
                    'profileScreen.account'.tr(),
                    style: _sectionStyle(context),
                  ),
                  const Gap(12),
                  ProfileSettingsSurface(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.caloriesIconColor,
                      ),
                      title: Text(
                        'profileScreen.deleteAccount'.tr(),
                        style: _titleStyle(
                          context,
                        ).copyWith(color: AppColors.caloriesIconColor),
                      ),
                      subtitle: Text(
                        'profileScreen.deleteAccountHint'.tr(),
                        style: _subtitleStyle(context),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.scoreSumLabelTextColor,
                      ),
                      onTap: () => _deleteAccount(context, ref),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
  ) async {
    await ref.read(appSettingsProvider.notifier).setLanguage(language);
    if (context.mounted) {
      await context.setLocale(language.locale);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'profileScreen.deleteAccountTitle'.tr(),
      message: 'profileScreen.deleteAccountMessage'.tr(),
      cancelLabel: 'runScreen.cancel'.tr(),
      confirmLabel: 'profileScreen.deleteEverything'.tr(),
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(runSessionProvider.notifier).reset();
      await HiveDatabase.clearAllUserData();
      ref.invalidate(profileProvider);
      ref.invalidate(runActivitiesProvider);
      if (context.mounted) {
        context.router.replaceAll([const OnBoardingRoute()]);
      }
    } catch (error, stackTrace) {
      logger.e(
        'Unable to clear local user data',
        error: error,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        AppFlushbar.error(context, 'profileScreen.deleteFailed'.tr());
      }
    }
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.title, required this.value});

  final String title;
  final AppLanguage value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppLanguage>(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeColor: AppColors.primaryButtonColor,
      title: Text(title, style: _titleStyle(context)),
    );
  }
}

TextStyle _sectionStyle(BuildContext context) => AppTextStyles.semiBold().black
    .s(16)
    .copyWith(letterSpacing: -0.5)
    .copyWith(color: AppColors.primaryText(context), letterSpacing: -0.5);
TextStyle _titleStyle(BuildContext context) => AppTextStyles.medium().black
    .s(14)
    .copyWith(color: AppColors.primaryText(context), letterSpacing: -0.5);
TextStyle _subtitleStyle(BuildContext context) => AppTextStyles.regular().black
    .s(12)
    .copyWith(color: AppColors.secondaryText(context), letterSpacing: -0.5);
