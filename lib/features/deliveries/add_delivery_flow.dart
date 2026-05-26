import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shift/on_duty_gate.dart';

/// Opens Add Delivery after ensuring the driver is on duty (shift + gate).
Future<void> openAddDelivery(
  BuildContext context,
  WidgetRef ref, {
  bool replace = false,
}) async {
  final ok = await ensureOnDutyForAction(
    context,
    ref,
    action: OnDutyAction.addDelivery,
  );
  if (!ok || !context.mounted) return;
}
