import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/common/widgets/app_confirmation_dialog.dart';

Future<bool> showRunEndConfirmationDialog(BuildContext context) {
  return showAppConfirmationDialog(
    context,
    title: 'runScreen.endRunTitle'.tr(),
    message: 'runScreen.endRunMessage'.tr(),
    cancelLabel: 'runScreen.cancel'.tr(),
    confirmLabel: 'runScreen.confirmEnd'.tr(),
    icon: Icons.stop_rounded,
  );
}
