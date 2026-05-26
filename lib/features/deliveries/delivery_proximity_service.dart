import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/delivery/delivery_proximity_cache.dart';
import '../../core/geo/zone_geometry.dart';
import '../../core/offline/network_status_provider.dart';
import '../../core/settings/live_db_refresh.dart';
import 'delivery_service.dart';

class ProximityRestaurant {
  const ProximityRestaurant({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  factory ProximityRestaurant.fromJson(Map<String, dynamic> json) {
    return ProximityRestaurant(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Restaurant',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };

  LatLng get latLng => LatLng(latitude, longitude);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProximityRestaurant &&
            id == other.id &&
            name == other.name &&
            latitude == other.latitude &&
            longitude == other.longitude;
  }

  @override
  int get hashCode => Object.hash(id, name, latitude, longitude);
}

class DeliveryProximityContext {
  const DeliveryProximityContext({
    required this.proximityMeters,
    this.zoneId,
    this.zoneType,
    this.zoneGeometry,
    this.restaurants = const [],
  });

  final int proximityMeters;
  final String? zoneId;
  final String? zoneType;
  final Map<String, dynamic>? zoneGeometry;
  final List<ProximityRestaurant> restaurants;

  bool get proximityEnabled => proximityMeters > 0;

  ZoneShape? get zoneShape => zoneShapeFromContext(
        zoneType: zoneType,
        zoneGeometry: zoneGeometry,
      );

  factory DeliveryProximityContext.fromJson(Map<String, dynamic> json) {
    final restaurantsRaw = json['restaurants'];
    final restaurants = restaurantsRaw is List
        ? restaurantsRaw
            .map(
              (e) => ProximityRestaurant.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(growable: false)
        : const <ProximityRestaurant>[];

    return DeliveryProximityContext(
      proximityMeters: (json['proximity_meters'] as num?)?.toInt() ?? 500,
      zoneId: json['zone_id'] as String?,
      zoneType: json['zone_type'] as String?,
      zoneGeometry: json['zone_geometry'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['zone_geometry'] as Map)
          : null,
      restaurants: restaurants,
    );
  }

  Map<String, dynamic> toJson() => {
        'proximity_meters': proximityMeters,
        'zone_id': zoneId,
        'zone_type': zoneType,
        'zone_geometry': zoneGeometry,
        'restaurants': restaurants.map((r) => r.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DeliveryProximityContext &&
            proximityMeters == other.proximityMeters &&
            zoneId == other.zoneId &&
            zoneType == other.zoneType &&
            _mapEquals(zoneGeometry, other.zoneGeometry) &&
            listEquals(restaurants, other.restaurants);
  }

  @override
  int get hashCode => Object.hash(
        proximityMeters,
        zoneId,
        zoneType,
        zoneGeometry == null ? null : Object.hashAll(zoneGeometry!.entries),
        Object.hashAll(restaurants),
      );

  static bool _mapEquals(
    Map<String, dynamic>? a,
    Map<String, dynamic>? b,
  ) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

enum DeliveryProximityBlockReason {
  none,
  proximityDisabled,
  inRange,
  outOfRange,
  locationUnavailable,
  contextUnavailable,
}

class DeliveryProximityStatus {
  const DeliveryProximityStatus({
    required this.allowed,
    required this.reason,
    this.proximityMeters = 0,
    this.distanceBeyondRangeMeters,
    this.zoneTarget = false,
  });

  final bool allowed;
  final DeliveryProximityBlockReason reason;
  final int proximityMeters;
  final double? distanceBeyondRangeMeters;
  final bool zoneTarget;

  static DeliveryProximityStatus allowedInRange({required int proximityMeters}) {
    return DeliveryProximityStatus(
      allowed: true,
      reason: DeliveryProximityBlockReason.inRange,
      proximityMeters: proximityMeters,
    );
  }

  static DeliveryProximityStatus proximityDisabled() {
    return const DeliveryProximityStatus(
      allowed: true,
      reason: DeliveryProximityBlockReason.proximityDisabled,
      proximityMeters: 0,
    );
  }
}

class DeliveryProximityService {
  DeliveryProximityService(this._client, this._networkStatus);

  final SupabaseClient _client;
  final NetworkStatusController _networkStatus;

  Future<DeliveryProximityContext> fetchContext() async {
    try {
      final result = await _client.rpc('driver_get_delivery_proximity_context');
      final map = result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result as Map);
      _networkStatus.recordRpcSuccess();
      return DeliveryProximityContext.fromJson(map);
    } on PostgrestException catch (e) {
      _networkStatus.recordRpcFailure();
      throw DeliveryServiceException(
        _friendlyContextError(e),
        code: 'proximity_context_unavailable',
      );
    }
  }

  DeliveryProximityStatus evaluate({
    required DeliveryProximityContext context,
    required double latitude,
    required double longitude,
  }) {
    if (!context.proximityEnabled) {
      return DeliveryProximityStatus.proximityDisabled();
    }

    final proximityMeters = context.proximityMeters;
    final hasAssignedZone =
        context.zoneId != null && context.zoneId!.trim().isNotEmpty;
    final zone = context.zoneShape;

    if (hasAssignedZone) {
      if (zone == null) {
        return DeliveryProximityStatus(
          allowed: false,
          reason: DeliveryProximityBlockReason.contextUnavailable,
          proximityMeters: proximityMeters,
          zoneTarget: true,
        );
      }

      if (isWithinZoneProximity(
        lat: latitude,
        lng: longitude,
        zone: zone,
        bufferMeters: proximityMeters,
      )) {
        return DeliveryProximityStatus.allowedInRange(
          proximityMeters: proximityMeters,
        );
      }

      final boundaryDist = distanceToZoneBoundaryMeters(
        lat: latitude,
        lng: longitude,
        zone: zone,
      );
      final beyond = boundaryDist.isFinite
          ? (boundaryDist - proximityMeters)
              .clamp(0.0, double.infinity)
              .toDouble()
          : double.infinity;

      return DeliveryProximityStatus(
        allowed: false,
        reason: DeliveryProximityBlockReason.outOfRange,
        proximityMeters: proximityMeters,
        distanceBeyondRangeMeters: beyond,
        zoneTarget: true,
      );
    }

    final restaurants = context.restaurants;
    if (restaurants.isEmpty) {
      return DeliveryProximityStatus(
        allowed: false,
        reason: DeliveryProximityBlockReason.contextUnavailable,
        proximityMeters: proximityMeters,
        zoneTarget: false,
      );
    }

    final restaurantCoords = restaurants.map((r) => r.latLng);
    final nearestRestaurant = nearestRestaurantDistanceMeters(
      lat: latitude,
      lng: longitude,
      restaurants: restaurantCoords,
    );

    if (nearestRestaurant <= proximityMeters) {
      return DeliveryProximityStatus.allowedInRange(
        proximityMeters: proximityMeters,
      );
    }

    final beyond = (nearestRestaurant - proximityMeters)
        .clamp(0.0, double.infinity)
        .toDouble();

    return DeliveryProximityStatus(
      allowed: false,
      reason: DeliveryProximityBlockReason.outOfRange,
      proximityMeters: proximityMeters,
      distanceBeyondRangeMeters: beyond,
      zoneTarget: false,
    );
  }

  String _friendlyContextError(PostgrestException e) => e.message;
}

final deliveryProximityServiceProvider = Provider<DeliveryProximityService>(
  (ref) => DeliveryProximityService(
    Supabase.instance.client,
    ref.read(networkStatusProvider.notifier),
  ),
);

final deliveryProximityContextProvider =
    AsyncNotifierProvider<DeliveryProximityContextNotifier, DeliveryProximityContext>(
  DeliveryProximityContextNotifier.new,
);

class DeliveryProximityContextNotifier
    extends AsyncNotifier<DeliveryProximityContext> {
  late final VoidCallback _refreshListener;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<DeliveryProximityContext> build() async {
    final coordinator = ref.watch(liveDbRefreshCoordinatorProvider);
    _refreshListener = () => unawaited(refresh());
    coordinator.addListener(_refreshListener);
    ref.onDispose(() => coordinator.removeListener(_refreshListener));

    final userId = _userId;
    if (userId != null) {
      final cached = await DeliveryProximityCache.load(userId);
      if (cached != null) {
        unawaited(_refreshInBackground(userId));
        return cached;
      }
    }

    return _loadFromNetwork(userId);
  }

  Future<DeliveryProximityContext> _loadFromNetwork(String? userId) async {
    final next = await ref.read(deliveryProximityServiceProvider).fetchContext();
    if (userId != null) {
      await DeliveryProximityCache.save(userId, next);
    }
    return next;
  }

  Future<void> _refreshInBackground(String userId) async {
    final previous = state;
    try {
      final next = await ref.read(deliveryProximityServiceProvider).fetchContext();
      await DeliveryProximityCache.save(userId, next);
      if (previous.hasValue && previous.value == next) return;
      state = AsyncValue.data(next);
    } catch (_) {
      // Keep serving cached data when the network refresh fails.
    }
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;

    final previous = state;
    try {
      final next = await ref.read(deliveryProximityServiceProvider).fetchContext();
      await DeliveryProximityCache.save(userId, next);
      if (previous.hasValue && previous.value == next) return;
      state = AsyncValue.data(next);
    } catch (e, st) {
      state = previous.hasValue ? previous : AsyncValue.error(e, st);
    }
  }
}
