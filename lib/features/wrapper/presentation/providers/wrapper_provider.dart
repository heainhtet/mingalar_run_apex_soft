import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/wrapper_controller.dart';

final wrapperProvider = NotifierProvider<WrapperController, WrapperState>(
  WrapperController.new,
);
