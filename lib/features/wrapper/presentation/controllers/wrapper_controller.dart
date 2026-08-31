import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WrapperState {
  const WrapperState({this.index = 0});

  final int index;

  WrapperState copyWith({int? index}) =>
      WrapperState(index: index ?? this.index);
}

class WrapperController extends Notifier<WrapperState> {
  @override
  WrapperState build() => const WrapperState();

  void changeIndex(int index) {
    if (index == state.index) return;
    HapticFeedback.lightImpact();
    state = state.copyWith(index: index);
  }
}
