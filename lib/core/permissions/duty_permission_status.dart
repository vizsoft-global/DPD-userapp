import '../../l10n/app_localizations.dart';

enum DutyPermissionKind {
  locationServices,
  fineLocation,
  backgroundLocation,
  notifications,
  batteryOptimization,
  camera,
}

enum DutyPermissionState { granted, denied, restricted, unknown }

class DutyPermissionItem {
  const DutyPermissionItem({
    required this.kind,
    required this.state,
    required this.requiredForDuty,
    required this.title,
    required this.description,
  });

  final DutyPermissionKind kind;
  final DutyPermissionState state;
  final bool requiredForDuty;
  final String title;
  final String description;

  bool get isOk => state == DutyPermissionState.granted;

  bool get needsSettings =>
      state == DutyPermissionState.restricted ||
      kind == DutyPermissionKind.locationServices ||
      kind == DutyPermissionKind.batteryOptimization;

  String fixActionLabel(AppLocalizations l10n) {
    if (isOk) return '';
    switch (kind) {
      case DutyPermissionKind.locationServices:
        return l10n.openLocationSettings;
      case DutyPermissionKind.batteryOptimization:
        return l10n.openBatterySettings;
      case DutyPermissionKind.backgroundLocation:
        return l10n.openAppSettings;
      case DutyPermissionKind.fineLocation:
      case DutyPermissionKind.notifications:
      case DutyPermissionKind.camera:
        return needsSettings ? l10n.openAppSettings : l10n.allow;
    }
  }
}

class DutyReadinessReport {
  const DutyReadinessReport({required this.items});

  final List<DutyPermissionItem> items;

  bool get canStartDuty =>
      items.where((i) => i.requiredForDuty).every((i) => i.isOk);

  List<DutyPermissionItem> get actionRequired =>
      items.where((i) => !i.isOk && i.requiredForDuty).toList(growable: false);
}
