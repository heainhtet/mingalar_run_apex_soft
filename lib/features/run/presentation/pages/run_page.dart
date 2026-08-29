import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_extensions.dart';

@RoutePage()
class RunPage extends StatelessWidget {
  const RunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Run Page",
          style: AppTextStyles.medium().white
              .s(9)
              .copyWith(
                color: AppColors.onBoardingWelcomeText,
                height: 1.4,
                letterSpacing: 0,
              ),
        ),
      ),
    );
  }
}
