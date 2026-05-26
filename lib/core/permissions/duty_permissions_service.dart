import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/app_localizations.dart';
import 'duty_permission_status.dart';

class DutyPermissionsService {
  Future<DutyReadinessReport> audit(AppLocalizations l10n) async {
    if (!Platform.isAndroid) {
      return const DutyReadinessReport(items: []);
    }

    final locationServices = await Geolocator.isLocationServiceEnabled();
    final fine = await Permission.location.status;
    final background = await Permission.locationAlways.status;
    final notifications = await Permission.notification.status;
    final camera = await Permission.camera.status;

    final batteryOk = await _isBatteryOptimizationDisabled();

    return DutyReadinessReport(
      items: [
        DutyPermissionItem(
          kind: DutyPermissionKind.locationServices,
          state: locationServices
              ? DutyPermissionState.granted
              : DutyPermissionState.denied,
          requiredForDuty: true,
          title: l10n.permissionLocationServicesTitle,
          description: l10n.permissionLocationServicesDesc,
        ),
        DutyPermissionItem(
          kind: DutyPermissionKind.fineLocation,
          state: _mapStatus(fine),
          requiredForDuty: true,
          title: l10n.permissionLocationAccessTitle,
          description: l10n.permissionLocationAccessDesc,
        ),
        DutyPermissionItem(
          kind: DutyPermissionKind.backgroundLocation,
          state: _mapStatus(background),
          requiredForDuty: false,
          title: l10n.permissionBackgroundLocationTitle,
          description: l10n.permissionBackgroundLocationDesc,
        ),
        DutyPermissionItem(
          kind: DutyPermissionKind.notifications,
          state: _mapStatus(notifications),
          requiredForDuty: true,
          title: l10n.permissionNotificationsTitle,
          description: l10n.permissionNotificationsDesc,
        ),
        DutyPermissionItem(
          kind: DutyPermissionKind.batteryOptimization,
          state: batteryOk
              ? DutyPermissionState.granted
              : DutyPermissionState.denied,
          requiredForDuty: true,
          title: l10n.permissionBatteryOptimizationTitle,
          description: l10n.permissionBatteryOptimizationDesc,
        ),
        DutyPermissionItem(
          kind: DutyPermissionKind.camera,
          state: _mapStatus(camera),
          requiredForDuty: false,
          title: l10n.permissionCameraTitle,
          description: l10n.permissionCameraDesc,
        ),
      ],
    );
  }

  /// Opens the right system screen for the user to fix this check.
  Future<void> fix(DutyPermissionItem item) async {
    if (item.isOk) return;

    switch (item.kind) {
      case DutyPermissionKind.locationServices:
        await Geolocator.openLocationSettings();
        return;
      case DutyPermissionKind.batteryOptimization:
        await DisableBatteryOptimization
            .showDisableBatteryOptimizationSettings();
        return;
      case DutyPermissionKind.backgroundLocation:
        final fine = await Permission.location.status;
        if (fine.isGranted) {
          await openAppSettings();
          return;
        }
        await _fixRuntimePermission(item);
        return;
      case DutyPermissionKind.fineLocation:
      case DutyPermissionKind.notifications:
      case DutyPermissionKind.camera:
        await _fixRuntimePermission(item);
        return;
    }
  }

  Future<void> _fixRuntimePermission(DutyPermissionItem item) async {
    if (item.state == DutyPermissionState.restricted) {
      await openSettings(item.kind);
      return;
    }

    final granted = await request(item.kind);
    if (granted) return;

    final permission = _permissionFor(item.kind);
    if (permission == null) {
      await openSettings(item.kind);
      return;
    }

    final status = await permission.status;
    if (status.isPermanentlyDenied || status.isDenied) {
      await openSettings(item.kind);
    }
  }

  Permission? _permissionFor(DutyPermissionKind kind) {
    switch (kind) {
      case DutyPermissionKind.fineLocation:
        return Permission.location;
      case DutyPermissionKind.backgroundLocation:
        return Permission.locationAlways;
      case DutyPermissionKind.notifications:
        return Permission.notification;
      case DutyPermissionKind.camera:
        return Permission.camera;
      case DutyPermissionKind.locationServices:
      case DutyPermissionKind.batteryOptimization:
        return null;
    }
  }

  Future<bool> request(DutyPermissionKind kind) async {
    switch (kind) {
      case DutyPermissionKind.locationServices:
        return Geolocator.openLocationSettings();
      case DutyPermissionKind.fineLocation:
        final result = await Permission.location.request();
        return result.isGranted;
      case DutyPermissionKind.backgroundLocation:
        if (!await Permission.location.isGranted) {
          await Permission.location.request();
        }
        final result = await Permission.locationAlways.request();
        return result.isGranted;
      case DutyPermissionKind.notifications:
        final result = await Permission.notification.request();
        return result.isGranted;
      case DutyPermissionKind.batteryOptimization:
        final opened =
            await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
        return opened ?? false;
      case DutyPermissionKind.camera:
        final result = await Permission.camera.request();
        return result.isGranted;
    }
  }

  Future<bool> openSettings(DutyPermissionKind kind) async {
    switch (kind) {
      case DutyPermissionKind.locationServices:
        return Geolocator.openLocationSettings();
      case DutyPermissionKind.batteryOptimization:
        final opened =
            await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
        return opened ?? false;
      case DutyPermissionKind.fineLocation:
      case DutyPermissionKind.backgroundLocation:
      case DutyPermissionKind.notifications:
      case DutyPermissionKind.camera:
        return openAppSettings();
    }
  }

  DutyPermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return DutyPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return DutyPermissionState.restricted;
    }
    if (status.isDenied) {
      return DutyPermissionState.denied;
    }
    return DutyPermissionState.unknown;
  }

  Future<bool> _isBatteryOptimizationDisabled() async {
    try {
      final disabled =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled;
      if (disabled == true) return true;
      final manufacturer =
          await DisableBatteryOptimization.isManufacturerBatteryOptimizationDisabled;
      return manufacturer == true;
    } catch (_) {
      return false;
    }
  }
}
