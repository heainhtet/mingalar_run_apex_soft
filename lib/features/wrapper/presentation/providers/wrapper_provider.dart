import 'package:flutter_riverpod/legacy.dart';

import '../controllers/wrapper_controller.dart';

final wrapperProvider = StateNotifierProvider<WrapperController, WrapperState>(
  (ref) => WrapperController(),
);
