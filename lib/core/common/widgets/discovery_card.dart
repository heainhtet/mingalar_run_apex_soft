import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/text_extensions.dart';

class DiscoveryMetadata {
  const DiscoveryMetadata({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({
    super.key,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.metadata,
    this.badge,
    this.onTap,
  });

  final String assetPath;
  final String title;
  final String subtitle;
  final String? badge;
  final List<DiscoveryMetadata> metadata;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context, lightAlpha: 16),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 2,
                      child: Image.asset(
                        assetPath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    if (badge case final badge?)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.tabIndicatorColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            child: Text(
                              badge,
                              style: AppTextStyles.medium().white
                                  .s(10)
                                  .copyWith(
                                    color: AppColors.defaultPrimaryText,
                                    height: 1,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.semiBold()
                            .s(17)
                            .copyWith(
                              color: AppColors.primaryText(context),
                              height: 1.25,
                              letterSpacing: -0.25,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.regular()
                            .s(12)
                            .copyWith(
                              color: AppColors.secondaryText(context),
                              height: 1.4,
                              letterSpacing: 0,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: metadata
                            .map((item) => _MetadataItem(data: item))
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({required this.data});

  final DiscoveryMetadata data;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(data.icon, size: 15, color: AppColors.onBoardingWelcomeText),
        const SizedBox(width: 5),
        Text(
          data.label,
          style: AppTextStyles.medium()
              .s(10)
              .copyWith(
                color: AppColors.secondaryText(context),
                height: 1,
                letterSpacing: 0,
              ),
        ),
      ],
    );
  }
}
