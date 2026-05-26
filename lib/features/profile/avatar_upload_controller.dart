import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/storage/driver_upload_provider.dart';
import '../auth/rider_auth_service.dart';

final avatarUploadControllerProvider =
    AsyncNotifierProvider<AvatarUploadController, AvatarUploadOutcome?>(
      AvatarUploadController.new,
    );

enum AvatarUploadOutcome {
  cancelled,
  uploadedAndVisible,
  uploadedButPreviewFailed,
}

class AvatarUploadController extends AsyncNotifier<AvatarUploadOutcome?> {
  @override
  Future<AvatarUploadOutcome?> build() async => null;

  Future<void> pickAndUpload(ImageSource source) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return AvatarUploadOutcome.cancelled;

      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      final contentType = _mimeTypeForPath(picked.path);
      final upload = await ref
          .read(driverUploadServiceProvider)
          .uploadDriverAvatar(
            bytes: bytes,
            contentType: contentType,
            filename: picked.name,
          );

      await Supabase.instance.client.rpc(
        'driver_update_avatar',
        params: {'p_object_key': upload.objectKey},
      );

      ref.invalidate(riderProfileProvider);
      ref.invalidate(profileAvatarUrlProvider);
      await ref.read(riderProfileProvider.future);
      final avatarUrl = await ref.read(profileAvatarUrlProvider.future);

      return (avatarUrl?.isNotEmpty ?? false)
          ? AvatarUploadOutcome.uploadedAndVisible
          : AvatarUploadOutcome.uploadedButPreviewFailed;
    });
  }

  String _mimeTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }
}
