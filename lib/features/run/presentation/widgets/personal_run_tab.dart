import 'package:flutter/widgets.dart';

import 'run_tab_content.dart';

class PersonalRunTab extends StatelessWidget {
  const PersonalRunTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RunTabContent(titleKey: 'runScreen.personalRun');
  }
}
