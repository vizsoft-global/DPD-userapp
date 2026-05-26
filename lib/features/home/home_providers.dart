import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/offline/network_status_provider.dart';
import '../../core/offline/offline_repo.dart';
import 'home_models.dart';

class HomeServiceException implements Exception {
  HomeServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HomeService {
  HomeService(this._client, this._offlineRepo, this._networkStatus);

  final SupabaseClient _client;
  final OfflineRepo _offlineRepo;
  final NetworkStatusController _networkStatus;

  Future<HomeDashboard> fetchDashboard() async {
    final userId = _client.auth.currentUser?.id;
    try {
      final result = await _client.rpc('driver_get_home_dashboard');
      final map = result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result as Map);
      _networkStatus.recordRpcSuccess();
      if (userId != null) {
        await _offlineRepo.saveHomeDashboardCache(userId, map);
      }
      return HomeDashboard.fromJson(map);
    } on PostgrestException catch (e) {
      _networkStatus.recordRpcFailure();
      if (userId != null) {
        final cached = await _offlineRepo.loadHomeDashboardCache(userId);
        if (cached != null) {
          return HomeDashboard.fromJson(cached);
        }
      }
      throw HomeServiceException(_friendlyError(e));
    }
  }

  Future<HomeDashboard> setDutyState({
    required bool isOnDuty,
    required bool isOnline,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (_networkStatus.isOffline && userId != null) {
      await _offlineRepo.queueDutyState(
        userId: userId,
        isOnDuty: isOnDuty,
        isOnline: isOnline,
      );
      final fallback = await fetchDashboard();
      return fallback;
    }
    try {
      final result = await _client.rpc(
        'driver_set_duty_state',
        params: {'p_is_on_duty': isOnDuty, 'p_is_online': isOnline},
      );
      final map = result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result as Map);
      _networkStatus.recordRpcSuccess();
      if (userId != null) {
        await _offlineRepo.saveHomeDashboardCache(userId, map);
      }
      return HomeDashboard.fromJson(map);
    } on PostgrestException catch (e) {
      _networkStatus.recordRpcFailure();
      if (userId != null) {
        await _offlineRepo.queueDutyState(
          userId: userId,
          isOnDuty: isOnDuty,
          isOnline: isOnline,
        );
        final cached = await _offlineRepo.loadHomeDashboardCache(userId);
        if (cached != null) {
          return HomeDashboard.fromJson(cached);
        }
      }
      throw HomeServiceException(_friendlyError(e));
    }
  }

  String _friendlyError(PostgrestException e) {
    final msg = e.message.trim();
    if (msg.contains('not_authenticated')) {
      return 'Session expired. Please sign in again.';
    }
    if (msg.contains('Could not find the function')) {
      return 'Server update required. Contact support.';
    }
    if (msg.contains('shift_required')) {
      return 'Submit today\'s shift before going on duty.';
    }
    return msg.isEmpty ? 'Could not load home dashboard' : msg;
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService(
    Supabase.instance.client,
    ref.read(offlineRepoProvider),
    ref.read(networkStatusProvider.notifier),
  );
});

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboard>(
      HomeDashboardNotifier.new,
    );

class HomeDashboardNotifier extends AsyncNotifier<HomeDashboard> {
  @override
  Future<HomeDashboard> build() async {
    return ref.read(homeServiceProvider).fetchDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(homeServiceProvider).fetchDashboard(),
    );
  }

  Future<void> setDutyState({
    required bool isOnDuty,
    required bool isOnline,
  }) async {
    state = await AsyncValue.guard(
      () => ref
          .read(homeServiceProvider)
          .setDutyState(isOnDuty: isOnDuty, isOnline: isOnline),
    );
  }
}
