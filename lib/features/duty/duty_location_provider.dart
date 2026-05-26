import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/offline/network_status_provider.dart';
import '../../core/offline/offline_repo.dart';
import 'adaptive_location_scheduler.dart';
import 'location_tracking_service.dart';

final locationTrackingServiceProvider = Provider<LocationTrackingService>(
  (ref) => LocationTrackingService(
    Supabase.instance.client,
    ref.read(offlineRepoProvider),
    ref.read(networkStatusProvider.notifier),
  ),
);

class DutyLocationState {
  const DutyLocationState({
    this.lastReport,
    this.isServiceRunning = false,
    this.trackingStatus = TrackingStatus.idle,
    this.errorMessage,
  });

  final LocationReportResult? lastReport;
  final bool isServiceRunning;
  final TrackingStatus trackingStatus;
  final String? errorMessage;

  bool get isOutsideZone => lastReport?.zoneStatus == 'out_of_zone';
  double? get speedMps => lastReport?.speedMps;
  double get distanceTodayMeters => lastReport?.distanceTodayMeters ?? 0;

  DutyLocationState copyWith({
    LocationReportResult? lastReport,
    bool? isServiceRunning,
    TrackingStatus? trackingStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DutyLocationState(
      lastReport: lastReport ?? this.lastReport,
      isServiceRunning: isServiceRunning ?? this.isServiceRunning,
      trackingStatus: trackingStatus ?? this.trackingStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final dutyLocationProvider =
    NotifierProvider<DutyLocationNotifier, DutyLocationState>(
      DutyLocationNotifier.new,
    );

class DutyLocationNotifier extends Notifier<DutyLocationState> {
  @override
  DutyLocationState build() => const DutyLocationState();

  void setServiceRunning(bool running) {
    state = state.copyWith(isServiceRunning: running);
  }

  void applyReport(LocationReportResult report) {
    final status = switch (report.trackingStatus) {
      'moving' => TrackingStatus.moving,
      'delivery_submit' => TrackingStatus.deliverySubmit,
      _ => TrackingStatus.idle,
    };
    state = state.copyWith(
      lastReport: report,
      trackingStatus: status,
      clearError: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void reset() {
    state = const DutyLocationState();
  }
}
