import '../../core/geo/zone_geometry.dart';
import '../../l10n/app_localizations.dart';
import 'delivery_proximity_service.dart';
import 'delivery_service.dart';

String messageForDeliveryServiceException(
  DeliveryServiceException error,
  AppLocalizations l10n,
) {
  return switch (error.code) {
    'order_id_required' => l10n.orderIdRequired,
    'auth' => l10n.pleaseSignInAgain,
    'inactive' => l10n.accountNotActive,
    'delivery_out_of_range' => l10n.outsideAllowedDeliveryArea,
    'driver_off_duty' => l10n.mustBeOnDutyToAddDelivery,
    'location_required' => l10n.gpsRequiredForDelivery,
    'proximity_context_unavailable' => l10n.couldNotLoadDeliveryLocationRules,
    _ => error.message.isNotEmpty ? error.message : l10n.somethingWentWrong,
  };
}

String? messageForProximityStatus(
  DeliveryProximityStatus status,
  AppLocalizations l10n,
) {
  if (status.allowed) return null;

  switch (status.reason) {
    case DeliveryProximityBlockReason.contextUnavailable:
      return status.zoneTarget
          ? l10n.zoneNotConfigured
          : l10n.noRestaurantsAssigned;
    case DeliveryProximityBlockReason.outOfRange:
      final range = formatDistanceMeters(status.proximityMeters.toDouble());
      final target = status.zoneTarget ? l10n.yourZone : l10n.assignedRestaurant;
      final beyond = status.distanceBeyondRangeMeters;
      if (beyond == null || !beyond.isFinite || beyond <= 0) {
        return l10n.moveWithinRangeToLog(range, target);
      }
      return l10n.outsideRangeDetails(
        formatDistanceMeters(beyond),
        range,
        target,
      );
    case DeliveryProximityBlockReason.locationUnavailable:
      return l10n.gpsRequiredForDelivery;
    case DeliveryProximityBlockReason.none:
    case DeliveryProximityBlockReason.inRange:
    case DeliveryProximityBlockReason.proximityDisabled:
      return null;
  }
}

String messageForProximityContextError(String rawMessage, AppLocalizations l10n) {
  final msg = rawMessage.toLowerCase();
  if (msg.contains('not_authenticated')) {
    return l10n.sessionExpired;
  }
  if (msg.contains('not_a_driver')) {
    return l10n.accountNotSetupAsDriver;
  }
  if (msg.contains('could not find the function')) {
    return l10n.serverUpdateRequired;
  }
  return l10n.couldNotLoadDeliveryLocationRules;
}
