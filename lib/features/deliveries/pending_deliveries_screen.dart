import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/l10n/l10n.dart';
import '../../core/offline/offline_db.dart';
import '../../core/offline/sync_controller.dart';
import '../../core/theme/app_colors.dart';

final pendingDeliveriesProvider = FutureProvider<List<Map<String, Object?>>>((
  ref,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return const [];
  return OfflineDb.instance.getPendingDeliveries(userId);
});

class PendingDeliveriesScreen extends ConsumerWidget {
  const PendingDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pendingAsync = ref.watch(pendingDeliveriesProvider);
    final sync = ref.watch(syncControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pendingDeliveries),
        actions: [
          IconButton(
            onPressed: sync.running
                ? null
                : () async {
                    await ref.read(syncControllerProvider.notifier).drain();
                    ref.invalidate(pendingDeliveriesProvider);
                  },
            icon: sync.running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: pendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('$error', style: Theme.of(context).textTheme.bodyMedium),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(child: Text(l10n.noPendingDeliveries));
          }
          return Column(
            children: [
              Container(
                color: AppColors.cardBlue,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  l10n.pendingSyncedSummary(rows.length, sync.syncedCount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final orderId = row['order_id'] as String? ?? '';
                    final status = row['status'] as String? ?? 'queued';
                    final error = row['last_error'] as String?;
                    final capturedAtMs = row['captured_at'] as int? ?? 0;
                    final capturedAt = DateTime.fromMillisecondsSinceEpoch(
                      capturedAtMs,
                    );
                    return ListTile(
                      title: Text(l10n.orderIdPrefix(orderId)),
                      subtitle: Text(
                        '${capturedAt.toLocal()}'
                        '${error == null ? '' : '\n$error'}',
                      ),
                      isThreeLine: error != null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatusChip(status: status, pendingLabel: l10n.pending),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: sync.running
                                ? null
                                : () async {
                                    await ref
                                        .read(syncControllerProvider.notifier)
                                        .drain();
                                    ref.invalidate(pendingDeliveriesProvider);
                                  },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await OfflineDb.instance.deletePendingById(
                                table: 'pending_deliveries',
                                id: row['id'] as String,
                              );
                              ref.invalidate(pendingDeliveriesProvider);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.pendingLabel});

  final String status;
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'failed' => (Colors.red.shade50, Colors.red.shade800),
      'uploading' => (Colors.blue.shade50, Colors.blue.shade800),
      _ => (Colors.orange.shade50, Colors.orange.shade800),
    };
    final label = switch (status) {
      'failed' => status,
      'uploading' => status,
      _ => pendingLabel,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
