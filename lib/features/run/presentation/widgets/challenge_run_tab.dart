import 'package:flutter/widgets.dart';

import 'run_mode_card.dart';
import 'run_tab_content.dart';

class ChallengeRunTab extends StatelessWidget {
  const ChallengeRunTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RunTabContent(
      titleKey: 'runScreen.challengeRun',
      introduction: RunModeCard(modeIndex: 2),
    );
  }
}
