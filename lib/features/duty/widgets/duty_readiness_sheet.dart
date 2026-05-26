import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/permissions/duty_permission_status.dart';
import '../../../core/permissions/duty_permissions_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

typedef DutyReadinessCallback = Future<bool> Function();

enum DutyReadinessFlow {
  startDuty,
  goOnline;
}

Future<bool> showDutyReadinessSheet(
  BuildContext context, {
  required DutyReadinessCallback onContinue,
  DutyReadinessFlow flow = DutyReadinessFlow.startDuty,
}) async {
  if (!Platform.isAndroid) {
    return onContinue();
  }

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DutyReadinessSheet(
      flow: flow,
      onContinue: onContinue,
    ),
  );

  return result ?? false;
}

class DutyReadinessSheet extends StatefulWidget {
  const DutyReadinessSheet({
    required this.onContinue,
    this.flow = DutyReadinessFlow.startDuty,
    super.key,
  });

  final DutyReadinessCallback onContinue;
  final DutyReadinessFlow flow;

  @override
  State<DutyReadinessSheet> createState() => _DutyReadinessSheetState();
}

class _DutyReadinessSheetState extends State<DutyReadinessSheet>
    with WidgetsBindingObserver {
  final _service = DutyPermissionsService();
  DutyReadinessReport? _report;
  bool _loading = true;
  bool _continuing = false;
  DutyPermissionKind? _fixingKind;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final report = await _service.audit(context.l10n);
    if (!mounted) return;
    setState(() {
      _report = report;
      _loading = false;
    });
  }

  Future<void> _fix(DutyPermissionItem item) async {
    setState(() => _fixingKind = item.kind);
    await _service.fix(item);
    if (!mounted) return;
    setState(() => _fixingKind = null);
    await _load();
  }

  Future<void> _continue() async {
    setState(() => _continuing = true);
    final ok = await widget.onContinue();
    if (!mounted) return;
    setState(() => _continuing = false);
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  int _requiredOkCount(DutyReadinessReport report) =>
      report.items.where((i) => i.requiredForDuty && i.isOk).length;

  int _requiredTotal(DutyReadinessReport report) =>
      report.items.where((i) => i.requiredForDuty).length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final report = _report;
    final flow = widget.flow;
    final allRequiredOk = report?.canStartDuty ?? false;
    final flowTitle = switch (flow) {
      DutyReadinessFlow.startDuty => l10n.readyForDuty,
      DutyReadinessFlow.goOnline => l10n.beforeYouGoOnline,
    };
    final flowSubtitle = switch (flow) {
      DutyReadinessFlow.startDuty => l10n.startDutyChecksSubtitle,
      DutyReadinessFlow.goOnline => l10n.goOnlineChecksSubtitle,
    };
    final continueLabel = switch (flow) {
      DutyReadinessFlow.startDuty => l10n.startDuty,
      DutyReadinessFlow.goOnline => l10n.goOnline,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            flowTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            flowSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (!_loading && report != null) ...[
            const SizedBox(height: 12),
            _StatusBanner(
              allRequiredOk: allRequiredOk,
              okCount: _requiredOkCount(report),
              total: _requiredTotal(report),
              l10n: l10n,
            ),
          ],
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (report != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.42,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: report.items.map(
                    (item) => _PermissionRow(
                      item: item,
                      l10n: l10n,
                      busy: _fixingKind == item.kind,
                      onFix: () => _fix(item),
                    ),
                  ).toList(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ||
                    _continuing ||
                    report == null ||
                    !report.canStartDuty
                ? null
                : _continue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blueberry,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _continuing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(continueLabel),
          ),
          TextButton(
            onPressed: _loading ? null : _load,
            child: Text(l10n.refreshChecks),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.allRequiredOk,
    required this.okCount,
    required this.total,
    required this.l10n,
  });

  final bool allRequiredOk;
  final int okCount;
  final int total;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final bg = allRequiredOk
        ? AppColors.progressGreen.withValues(alpha: 0.12)
        : Colors.orange.shade50;
    final fg =
        allRequiredOk ? AppColors.progressGreen : Colors.orange.shade900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            allRequiredOk ? Icons.verified_outlined : Icons.info_outline,
            color: fg,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              allRequiredOk
                  ? l10n.allChecksPassed(okCount, total)
                  : l10n.someChecksPassed(okCount, total),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.item,
    required this.l10n,
    required this.onFix,
    this.busy = false,
  });

  final DutyPermissionItem item;
  final AppLocalizations l10n;
  final VoidCallback onFix;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final ok = item.isOk;
    final tappable = !ok;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tappable
            ? AppColors.blueberry.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: tappable && !busy ? onFix : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  ok ? Icons.check_circle : Icons.error_outline,
                  color:
                      ok ? AppColors.progressGreen : Colors.orange.shade800,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      if (tappable) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.fixActionLabel(l10n),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.blueberry,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (tappable)
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.blueberry.withValues(alpha: 0.8),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
