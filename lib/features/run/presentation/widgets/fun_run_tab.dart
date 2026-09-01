import 'package:flutter/widgets.dart';

import 'run_mode_card.dart';
import 'run_tab_content.dart';

class FunRunTab extends StatelessWidget {
  const FunRunTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RunTabContent(
      titleKey: 'runScreen.funRun',
      introduction: RunModeCard(modeIndex: 1),
    );
  }
}
