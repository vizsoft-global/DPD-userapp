import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../duty/duty_location_provider.dart';
import 'home_providers.dart';

const zoneTimeoutSeconds = 600;

class ZoneMonitorState {
  const ZoneMonitorState({
    this.isOutsideZone = false,
    this.remainingSeconds = zoneTimeoutSeconds,
    this.isChecking = false,
    this.locationDenied = false,
  });

  final bool isOutsideZone;
  final int remainingSeconds;
  final bool isChecking;
  final bool locationDenied;

  ZoneMonitorState copyWith({
    bool? isOutsideZone,
    int? remainingSeconds,
    bool? isChecking,
    bool? locationDenied,
  }) {
    return ZoneMonitorState(
      isOutsideZone: isOutsideZone ?? this.isOutsideZone,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isChecking: isChecking ?? this.isChecking,
      locationDenied: locationDenied ?? this.locationDenied,
    );
  }
}

final zoneMonitorProvider =
    NotifierProvider<ZoneMonitorNotifier, ZoneMonitorState>(
  ZoneMonitorNotifier.new,
);

class ZoneMonitorNotifier extends Notifier<ZoneMonitorState> {
  Timer? _countdownTimer;
  DateTime? _outsideSince;

  @override
  ZoneMonitorState build() {
    ref.onDispose(_dispose);

    ref.listen(homeDashboardProvider, (previous, next) {
      final wasOnDuty = previous?.value?.isOnDuty ?? false;
      final isOnDuty = next.value?.isOnDuty ?? false;
      if (!isOnDuty && wasOnDuty) {
        _stopMonitoring(reset: true);
      }
    });

    ref.listen(dutyLocationProvider, (previous, next) {
      if (!(ref.read(homeDashboardProvider).value?.isOnDuty ?? false)) {
        return;
      }
      if (next.isServiceRunning) {
        _applyOutsideState(next.isOutsideZone);
      }
    });

    return const ZoneMonitorState();
  }

  void _dispose() {
    _countdownTimer?.cancel();
  }

  void _stopMonitoring({required bool reset}) {
    _countdownTimer?.cancel();
    _outsideSince = null;
    if (reset) {
      state = const ZoneMonitorState();
    }
  }

  void _applyOutsideState(bool outside) {
    if (!outside) {
      _outsideSince = null;
      _countdownTimer?.cancel();
      state = state.copyWith(
        isOutsideZone: false,
        remainingSeconds: zoneTimeoutSeconds,
        isChecking: false,
        locationDenied: false,
      );
      return;
    }

    _outsideSince ??= DateTime.now();
    _ensureCountdownRunning();

    final elapsed = DateTime.now().difference(_outsideSince!).inSeconds;
    final remaining =
        (zoneTimeoutSeconds - elapsed).clamp(0, zoneTimeoutSeconds);
    state = state.copyWith(
      isOutsideZone: true,
      remainingSeconds: remaining,
      isChecking: false,
      locationDenied: false,
    );
  }

  void _ensureCountdownRunning() {
    _countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (_outsideSince == null) return;
      final elapsed = DateTime.now().difference(_outsideSince!).inSeconds;
      final remaining =
          (zoneTimeoutSeconds - elapsed).clamp(0, zoneTimeoutSeconds);
      state = state.copyWith(isOutsideZone: true, remainingSeconds: remaining);
      if (remaining <= 0) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
      }
    });
  }
}

String formatCountdown(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
