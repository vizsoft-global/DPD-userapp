import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shift_models.dart';
import 'shift_service.dart';

final todayShiftProvider =
    AsyncNotifierProvider<TodayShiftNotifier, DailyShift?>(TodayShiftNotifier.new);

class TodayShiftNotifier extends AsyncNotifier<DailyShift?> {
  @override
  Future<DailyShift?> build() async {
    return ref.read(shiftServiceProvider).fetchTodayShift();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(shiftServiceProvider).fetchTodayShift(),
    );
  }

  void setLocal(DailyShift shift) {
    state = AsyncData(shift);
  }
}
