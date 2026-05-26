import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/offline/offline_repo.dart';
import '../../core/offline/sync_controller.dart';
import '../home/home_providers.dart';
import 'adaptive_location_scheduler.dart';
import 'duty_background_service.dart';
import 'duty_location_provider.dart';
import 'duty_session_storage.dart';

final dutyLifecycleControllerProvider = Provider<DutyLifecycleController>((
  ref,
) {
  final controller = DutyLifecycleController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class DutyLifecycleController with WidgetsBindingObserver {
  DutyLifecycleController(this._ref) {
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    _ref.listen(homeDashboardProvider, (previous, next) {
      final wasOnDuty = previous?.value?.isOnDuty ?? false;
      final isOnDuty = next.value?.isOnDuty ?? false;
      if (isOnDuty && !wasOnDuty) {
        unawaited(_onDutyStarted());
      } else if (!isOnDuty && wasOnDuty) {
        unawaited(_onDutyStopped());
      } else if (isOnDuty && next.hasValue) {
        unawaited(_ensureServiceRunning());
      }
    });

    WidgetsBinding.instance.addObserver(this);
    unawaited(_bootstrap());
  }

  final Ref _ref;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_ref.read(homeDashboardProvider.notifier).refresh());
      unawaited(_ensureServiceRunning());
      unawaited(_ref.read(syncControllerProvider.notifier).drain());
    }
  }

  Future<void> _bootstrap() async {
    await DutyBackgroundService.init();
    unawaited(_ref.read(syncControllerProvider.notifier).drain());
    final isOnDuty = _ref.read(homeDashboardProvider).value?.isOnDuty ?? false;
    if (isOnDuty) {
      await _onDutyStarted();
    }
  }

  void _onTaskData(Object data) {
    if (data is! String) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      final event = map['event'] as String?;
      if (event == 'auto_checkout_inactive' ||
          event == 'manual_offline_from_notification') {
        unawaited(_onDutyStopped());
        unawaited(_ref.read(homeDashboardProvider.notifier).refresh());
        return;
      }
      if (event == 'queue_location') {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;
        unawaited(
          _ref
              .read(offlineRepoProvider)
              .queueLocation(
                userId: userId,
                latitude: (map['lat'] as num?)?.toDouble() ?? 0,
                longitude: (map['lng'] as num?)?.toDouble() ?? 0,
                speedMps: (map['speed_mps'] as num?)?.toDouble(),
                accuracyMeters: (map['accuracy_meters'] as num?)?.toDouble(),
                batteryPct: (map['battery_pct'] as num?)?.toInt(),
                trackingStatus:
                    map['tracking_status'] as String? ??
                    TrackingStatus.idle.apiValue,
                forceHistory: map['force_history'] as bool? ?? false,
              ),
        );
        return;
      }
      if (event == 'queue_duty_state') {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;
        unawaited(
          _ref
              .read(offlineRepoProvider)
              .queueDutyState(
                userId: userId,
                isOnDuty: map['is_on_duty'] as bool? ?? false,
                isOnline: map['is_online'] as bool? ?? false,
              ),
        );
        return;
      }
      _ref
          .read(dutyLocationProvider.notifier)
          .applyReport(LocationReportResult.fromJson(map));
    } catch (_) {}
  }

  Future<void> _onDutyStarted() async {
    if (!Platform.isAndroid) return;

    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;
    if (token != null && token.isNotEmpty) {
      await DutySessionStorage.saveAccessToken(token);
    }

    final started = await DutyBackgroundService.start();
    _ref.read(dutyLocationProvider.notifier).setServiceRunning(started);
  }

  Future<void> _onDutyStopped() async {
    await DutyBackgroundService.stop();
    await DutySessionStorage.clearAccessToken();
    _ref.read(dutyLocationProvider.notifier).reset();
  }

  Future<void> _ensureServiceRunning() async {
    if (!Platform.isAndroid) return;
    if (!await DutyBackgroundService.isRunning) {
      await _onDutyStarted();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
  }
}
