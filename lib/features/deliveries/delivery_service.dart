import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/offline/network_status_provider.dart';
import '../../core/offline/offline_repo.dart';
import 'delivery_models.dart';

class DeliveryServiceException implements Exception {
  DeliveryServiceException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class DeliveryService {
  DeliveryService(this._client, this._offlineRepo, this._networkStatus);

  final SupabaseClient _client;
  final OfflineRepo _offlineRepo;
  final NetworkStatusController _networkStatus;

  /// Trim and strip leading `#` before sending to the server.
  static String normalizeOrderIdInput(String raw) {
    var v = raw.trim();
    while (v.startsWith('#')) {
      v = v.substring(1).trim();
    }
    return v;
  }

  Future<CreatedDelivery> createDelivery({
    required String orderId,
    String? orderProofObjectKey,
    required double latitude,
    required double longitude,
  }) async {
    final normalized = normalizeOrderIdInput(orderId);
    if (normalized.isEmpty) {
      throw DeliveryServiceException(
        '',
        code: 'order_id_required',
      );
    }

    final userId = _client.auth.currentUser?.id;
    try {
      if (_networkStatus.isOffline && userId != null) {
        return _offlineRepo.queueDelivery(
          userId: userId,
          orderId: normalized,
          latitude: latitude,
          longitude: longitude,
          proofObjectKey: orderProofObjectKey,
        );
      }
      final result = await _client.rpc(
        'driver_create_delivery',
        params: {
          'p_external_order_id': normalized,
          'p_order_proof_url': orderProofObjectKey,
          'p_delivered_lat': latitude,
          'p_delivered_lng': longitude,
        },
      );

      final row = result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result as Map);
      _networkStatus.recordRpcSuccess();
      return CreatedDelivery.fromJson(row);
    } on PostgrestException catch (e) {
      _networkStatus.recordRpcFailure();
      if (userId != null && _isRecoverableNetworkError(e.message)) {
        return _offlineRepo.queueDelivery(
          userId: userId,
          orderId: normalized,
          latitude: latitude,
          longitude: longitude,
          proofObjectKey: orderProofObjectKey,
        );
      }
      throw _mapPostgrest(e);
    }
  }

  Future<List<DriverDelivery>> listMyDeliveries({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    try {
      final rows = await _client
          .from('deliveries')
          .select('''
          id, external_order_id, status, delivered_at, order_proof_url,
          partners ( name, logo_url )
        ''')
          .order('delivered_at', ascending: false)
          .limit(limit);

      final mapped = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
      _networkStatus.recordRpcSuccess();
      if (userId != null) {
        await _offlineRepo.saveDeliveriesCache(userId, mapped);
      }
      return mapped.map(DriverDelivery.fromJson).toList(growable: false);
    } catch (_) {
      _networkStatus.recordRpcFailure();
      if (userId != null) {
        final cached = await _offlineRepo.loadDeliveriesCache(userId);
        if (cached.isNotEmpty) {
          return cached.map(DriverDelivery.fromJson).toList(growable: false);
        }
      }
      rethrow;
    }
  }

  DeliveryServiceException _mapPostgrest(PostgrestException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('not_authenticated')) {
      return DeliveryServiceException('', code: 'auth');
    }
    if (msg.contains('driver_not_active')) {
      return DeliveryServiceException(
        '',
        code: 'inactive',
      );
    }
    if (msg.contains('delivery_out_of_range') ||
        msg.contains('outside the allowed delivery area')) {
      return DeliveryServiceException(
        '',
        code: 'delivery_out_of_range',
      );
    }
    if (msg.contains('driver_off_duty') ||
        msg.contains('must be on duty')) {
      return DeliveryServiceException(
        '',
        code: 'driver_off_duty',
      );
    }
    if (msg.contains('location_required')) {
      return DeliveryServiceException(
        '',
        code: 'location_required',
      );
    }
    return DeliveryServiceException(e.message);
  }

  bool _isRecoverableNetworkError(String message) {
    final msg = message.toLowerCase();
    return msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('timeout') ||
        msg.contains('connection');
  }
}

final deliveryServiceProvider = Provider<DeliveryService>((ref) {
  return DeliveryService(
    Supabase.instance.client,
    ref.read(offlineRepoProvider),
    ref.read(networkStatusProvider.notifier),
  );
});

final myDeliveriesProvider = FutureProvider<List<DriverDelivery>>((ref) async {
  return ref.read(deliveryServiceProvider).listMyDeliveries();
});
