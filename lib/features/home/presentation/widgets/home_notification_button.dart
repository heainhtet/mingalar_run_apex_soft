import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

class HomeNotificationButton extends StatelessWidget {
  const HomeNotificationButton({super.key, this.count = 12, this.onPressed});

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$count notifications',
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: SizedBox.square(
          dimension: 40,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.defaultPrimaryText,
                size: 28,
              ),
              Positioned(
                top: 1,
                right: -1,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8A00),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: 18,
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: AppTextStyles.bold().white
                            .s(8)
                            .copyWith(
                              color: AppColors.defaultPrimaryText,
                              height: 1,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
