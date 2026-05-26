import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../deliveries/delivery_proximity_preview.dart';
import '../duty/widgets/duty_readiness_sheet.dart';
import '../home/home_models.dart';
import '../home/home_providers.dart';
import 'shift_providers.dart';
import 'shift_service.dart';
import 'widgets/shift_submission_sheet.dart';

enum OnDutyAction { toggleOff, goOnDuty, addDelivery }

Future<bool> ensureOnDutyForAction(
  BuildContext context,
  WidgetRef ref, {
  required OnDutyAction action,
  HomeDashboard? dashboard,
}) async {
  final l10n = context.l10n;
  final current = dashboard ?? ref.read(homeDashboardProvider).value;
  if (current == null) return false;

  if (action == OnDutyAction.toggleOff) {
    await ref
        .read(homeDashboardProvider.notifier)
        .setDutyState(isOnDuty: false, isOnline: false);
    return true;
  }

  if (current.isOnlineOnDuty) {
    if (action == OnDutyAction.addDelivery) {
      await _openAddDelivery(context, ref);
    }
    return true;
  }

  var shift = ref.read(todayShiftProvider).value;
  if (shift == null) {
    shift = await ref.read(shiftServiceProvider).fetchTodayShift();
    if (shift != null) {
      ref.read(todayShiftProvider.notifier).setLocal(shift);
    }
  }

  if (shift == null) {
    if (!context.mounted) return false;
    final submitted = await showShiftSubmissionSheet(context);
    if (!submitted || !context.mounted) return false;
    shift = ref.read(todayShiftProvider).value;
    if (shift == null) return false;
  }

  if (!shift.isWithinWindow && context.mounted) {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.outsideShiftWindowTitle),
        content: Text(l10n.outsideShiftWindowMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.continueAnyway),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return false;
  }

  if (Platform.isAndroid && context.mounted) {
    final ok = await showDutyReadinessSheet(
      context,
      flow: DutyReadinessFlow.startDuty,
      onContinue: () => _applyOnDuty(ref),
    );
    if (!ok) return false;
  } else {
    final ok = await _applyOnDuty(ref);
    if (!ok) return false;
  }

  if (action == OnDutyAction.addDelivery && context.mounted) {
    await _openAddDelivery(context, ref);
  }

  return true;
}

Future<bool> _applyOnDuty(WidgetRef ref) async {
  try {
    await ref
        .read(homeDashboardProvider.notifier)
        .setDutyState(isOnDuty: true, isOnline: true);
    return ref.read(homeDashboardProvider).value?.isOnlineOnDuty ?? false;
  } catch (_) {
    return false;
  }
}

Future<void> _openAddDelivery(BuildContext context, WidgetRef ref) async {
  unawaited(ref.read(deliveryProximityPreviewProvider.notifier).warmUp());
  if (context.mounted) {
    context.push('/deliveries/add');
  }
}
