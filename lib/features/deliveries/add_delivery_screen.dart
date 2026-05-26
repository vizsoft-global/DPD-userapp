import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/geo/device_location_resolver.dart';
import '../../core/offline/network_status_provider.dart';
import '../../core/offline/offline_db.dart';
import '../../core/offline/offline_repo.dart';
import '../../core/storage/driver_upload_messages.dart';
import '../../core/storage/driver_upload_provider.dart';
import '../../core/storage/driver_upload_service.dart';
import '../../core/storage/order_proof_constraints.dart';
import '../../core/l10n/l10n.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/offline_banner.dart';
import 'delivery_messages.dart';
import 'delivery_proximity_preview.dart';
import 'delivery_proximity_service.dart';
import 'delivery_service.dart';
import 'pending_deliveries_screen.dart';
import '../duty/adaptive_location_scheduler.dart';
import '../duty/duty_background_service.dart';
import '../duty/duty_location_provider.dart';
import '../home/home_providers.dart';

class AddDeliveryScreen extends ConsumerStatefulWidget {
  const AddDeliveryScreen({super.key});

  @override
  ConsumerState<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends ConsumerState<AddDeliveryScreen> {
  final _orderIdController = TextEditingController();

  XFile? _proofFile;
  String? _proofMime;
  int? _proofSizeBytes;
  double _uploadProgress = 0;
  bool _submitting = false;
  bool _uploadingProof = false;
  String? _error;

  Timer? _proximityPollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProximityMonitoring();
    });
  }

  @override
  void dispose() {
    _proximityPollTimer?.cancel();
    _orderIdController.dispose();
    super.dispose();
  }

  void _startProximityMonitoring() {
    final preview = ref.read(deliveryProximityPreviewProvider);
    if (!preview.initialized) {
      unawaited(ref.read(deliveryProximityPreviewProvider.notifier).warmUp());
    }

    // Force a fresh proximity context fetch on entry so admin-side changes
    // (zone/restaurant assignment, proximity radius) are reflected immediately
    // instead of waiting for the next coordinator tick.
    unawaited(ref.read(deliveryProximityContextProvider.notifier).refresh());

    // Re-evaluate against the latest GPS every 5 seconds while the screen is
    // open. Combined with the proximity-preview's coordinator subscription,
    // this keeps the banner in sync with admin changes within ~5s.
    _proximityPollTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _submitting) return;
      final ctx =
          ref.read(deliveryProximityContextProvider).value ??
          ref.read(deliveryProximityPreviewProvider).context;
      if (ctx != null) {
        unawaited(
          ref
              .read(deliveryProximityPreviewProvider.notifier)
              .reevaluate(ctx, showLoading: false),
        );
      }
    });
  }

  bool _hasOrderId() =>
      DeliveryService.normalizeOrderIdInput(_orderIdController.text).isNotEmpty;

  bool _canSubmitDelivery(DeliveryProximityPreviewState preview) {
    if (_submitting) return false;
    if (!_hasOrderId()) return false;
    return preview.canSubmitDelivery;
  }

  Future<void> _showProofSourcePicker() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                  l10n.addOrders,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.imageFormatsMax10Mb,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.takePhoto),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.chooseFromGallery),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !mounted) return;
    await _pickProof(source);
  }

  Future<void> _pickProof(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (file == null) return;

    final size = await file.length();
    final filename = file.name.isNotEmpty ? file.name : 'proof.jpg';
    final sizeError = OrderProofConstraints.validateFile(
      filename: filename,
      sizeBytes: size,
    );
    if (sizeError != null) {
      setState(() => _error = sizeError);
      return;
    }

    final mime =
        file.mimeType ?? OrderProofConstraints.mimeFromFilename(filename);
    final mimeError = OrderProofConstraints.validateMime(mime, filename);
    if (mimeError != null) {
      setState(() => _error = mimeError);
      return;
    }

    setState(() {
      _proofFile = file;
      _proofMime = mime;
      _proofSizeBytes = size;
      _uploadProgress = 0;
      _error = null;
    });
  }

  void _removeProof() {
    setState(() {
      _proofFile = null;
      _proofMime = null;
      _proofSizeBytes = null;
      _uploadProgress = 0;
    });
  }

  Future<void> _submit() async {
    final dashboard = ref.read(homeDashboardProvider).value;
    if (dashboard == null || !dashboard.isOnDuty) {
      setState(() => _error = context.l10n.mustBeOnDutyToAddDelivery);
      return;
    }

    final orderId = DeliveryService.normalizeOrderIdInput(
      _orderIdController.text,
    );
    if (orderId.isEmpty) {
      setState(() => _error = context.l10n.orderIdRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final position = await DeviceLocationResolver.instance.resolve(
        highAccuracy: true,
      );

      final preview = ref.read(deliveryProximityPreviewProvider);
      final contextData =
          preview.context ?? ref.read(deliveryProximityContextProvider).value;
      if (contextData != null && contextData.proximityEnabled) {
        final status = ref
            .read(deliveryProximityServiceProvider)
            .evaluate(
              context: contextData,
              latitude: position.latitude,
              longitude: position.longitude,
            );
        if (!status.allowed) {
          if (mounted) {
            setState(
              () => _error = messageForProximityStatus(status, context.l10n),
            );
            await ref
                .read(deliveryProximityPreviewProvider.notifier)
                .reevaluate(contextData, showLoading: false);
          }
          return;
        }
      }

      String? objectKey;
      final isOffline = ref.read(networkStatusProvider).isOffline;
      String? proofLocalPath;
      if (isOffline && _proofFile != null) {
        final ext = _proofFile!.name.contains('.')
            ? '.${_proofFile!.name.split('.').last}'
            : '.jpg';
        proofLocalPath = await OfflineDb.instance.copyProofToQueue(
          sourcePath: _proofFile!.path,
          extensionWithDot: ext,
        );
      } else if (_proofFile != null) {
        if (mounted) setState(() => _uploadingProof = true);
        try {
          final bytes = await _proofFile!.readAsBytes();
          final name = _proofFile!.name.isNotEmpty
              ? _proofFile!.name
              : 'proof.jpg';
          final mime = _proofMime ?? 'image/jpeg';
          final upload = await ref
              .read(driverUploadServiceProvider)
              .uploadOrderProof(
                bytes: bytes,
                contentType: mime,
                filename: name,
                onProgress: (p) {
                  if (mounted) setState(() => _uploadProgress = p);
                },
              );
          objectKey = upload.objectKey;
        } finally {
          if (mounted) setState(() => _uploadingProof = false);
        }
      }

      final created = isOffline
          ? await ref
                .read(offlineRepoProvider)
                .queueDelivery(
                  userId: Supabase.instance.client.auth.currentUser!.id,
                  orderId: orderId,
                  latitude: position.latitude,
                  longitude: position.longitude,
                  proofLocalPath: proofLocalPath,
                  proofMime: _proofMime,
                  proofObjectKey: objectKey,
                )
          : await ref
                .read(deliveryServiceProvider)
                .createDelivery(
                  orderId: orderId,
                  orderProofObjectKey: objectKey,
                  latitude: position.latitude,
                  longitude: position.longitude,
                );

      try {
        await ref
            .read(locationTrackingServiceProvider)
            .reportLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              speedMps: position.speed >= 0 ? position.speed : null,
              accuracyMeters: position.accuracy,
              trackingStatus: TrackingStatus.deliverySubmit,
              deliveryId: created.id,
              forceHistory: true,
            );
        DutyBackgroundService.notifyDeliverySubmitted();
      } catch (_) {
        // Delivery saved; location audit is best-effort.
      }

      ref.invalidate(myDeliveriesProvider);
      ref.invalidate(pendingDeliveriesProvider);

      if (!mounted) return;
      final queued = created.status == 'queued';
      context.pushReplacement(
        '/deliveries/success${queued ? '?queued=1' : ''}',
      );
    } on DeliveryServiceException catch (e) {
      if (mounted) {
        setState(
          () => _error = messageForDeliveryServiceException(e, context.l10n),
        );
      }
    } on DriverUploadException catch (e) {
      if (mounted) {
        setState(
          () => _error = messageForDriverUploadException(e, context.l10n),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = context.l10n.somethingWentWrong);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = ref.watch(deliveryProximityPreviewProvider);
    final proximityAsync = ref.watch(deliveryProximityContextProvider);
    final showProximityLoading =
        !preview.initialized &&
        (preview.evaluating || proximityAsync.isLoading);
    final contextError = proximityAsync.whenOrNull(
      error: (error, _) => error is DeliveryServiceException
          ? messageForDeliveryServiceException(error, l10n)
          : null,
    );
    final proximityBannerMessage = preview.status != null && !preview.status!.allowed
        ? messageForProximityStatus(preview.status!, l10n)
        : contextError;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _submitting ? null : () => context.pop(),
        ),
        title: Text(l10n.addDelivery),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showProximityLoading) ...[
                    _ProximityBanner(
                      icon: Icons.my_location_outlined,
                      message: l10n.checkingYourLocation,
                      tone: _ProximityTone.info,
                    ),
                    const SizedBox(height: 12),
                  ] else if (proximityBannerMessage != null) ...[
                    _ProximityBanner(
                      icon: preview.status?.allowed == true
                          ? Icons.check_circle_outline
                          : Icons.location_off_outlined,
                      message: proximityBannerMessage,
                      tone: preview.status?.allowed == true
                          ? _ProximityTone.success
                          : _ProximityTone.warning,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _FormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.orderId,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _orderIdController,
                          enabled: !_submitting,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: l10n.orderIdHint,
                            helperText: l10n.required,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.uploadOrderProof,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        _ProofUploadArea(
                          onTap: _submitting ? null : _showProofSourcePicker,
                        ),
                        if (_proofFile != null) ...[
                          const SizedBox(height: 12),
                          _ProofFileRow(
                            name: _proofFile!.name,
                            sizeBytes: _proofSizeBytes,
                            progress: _uploadProgress,
                            uploading: _uploadingProof,
                            onRemove: _submitting ? null : _removeProof,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: Colors.red.shade800)),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _canSubmitDelivery(preview) ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: AppColors.white,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          l10n.markAsDelivered,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProofUploadArea extends StatelessWidget {
  const _ProofUploadArea({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 36,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.takePhotoOrChooseGallery,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.imageFormatsMax10MbShort,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.dayLabelGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProofFileRow extends StatelessWidget {
  const _ProofFileRow({
    required this.name,
    required this.sizeBytes,
    required this.progress,
    required this.uploading,
    required this.onRemove,
  });

  final String name;
  final int? sizeBytes;
  final double progress;
  final bool uploading;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.imgLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  uploading
                      ? l10n.uploadingProgress(
                          (progress * 100).clamp(0, 100).round(),
                        )
                      : _readyLabel(l10n),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: uploading
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                ),
                if (uploading) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress > 0 && progress < 1 ? progress : null,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!uploading)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.progressGreen,
              ),
            ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  String _readyLabel(AppLocalizations l10n) {
    final size = sizeBytes;
    if (size == null) return l10n.readyToUpload;
    final kb = size / 1024;
    if (kb < 1024) {
      return l10n.readyToUploadWithSizeKb(kb.toStringAsFixed(0));
    }
    final mb = kb / 1024;
    return l10n.readyToUploadWithSizeMb(mb.toStringAsFixed(1));
  }
}

enum _ProximityTone { info, success, warning }

class _ProximityBanner extends StatelessWidget {
  const _ProximityBanner({
    required this.icon,
    required this.message,
    required this.tone,
  });

  final IconData icon;
  final String message;
  final _ProximityTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (tone) {
      _ProximityTone.info => (
        AppColors.cardBlue,
        AppColors.primaryBlue,
        AppColors.primaryBlue.withValues(alpha: 0.2),
      ),
      _ProximityTone.success => (
        AppColors.progressGreen.withValues(alpha: 0.12),
        AppColors.progressGreen,
        AppColors.progressGreen.withValues(alpha: 0.25),
      ),
      _ProximityTone.warning => (
        Colors.orange.shade50,
        Colors.orange.shade900,
        Colors.orange.shade200,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
