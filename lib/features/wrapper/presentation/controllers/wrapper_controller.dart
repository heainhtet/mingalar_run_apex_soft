import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

class WrapperState {
  final int index;

  WrapperState({this.index = 0});

  WrapperState copyWith({int? index}) {
    return WrapperState(index: index ?? this.index);
  }
}

class WrapperController extends StateNotifier<WrapperState> {
  WrapperController() : super(WrapperState());

  void changeIndex(int index) {
    HapticFeedback.lightImpact();
    state = state.copyWith(index: index);
  }
}
