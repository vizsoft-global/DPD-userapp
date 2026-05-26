import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'integrity_checker.dart';
import 'security_bypass_store.dart';
import '../l10n/localizations_loader.dart';
import '../router/app_router.dart';
import 'screen_protector_service.dart';
import 'security_event_repository.dart';
import 'security_event_types.dart';
import 'security_warning_dialog.dart';

class SecurityGuardState {
  const SecurityGuardState({this.active = false, this.lastCaptureAttemptAt});

  final bool active;
  final DateTime? lastCaptureAttemptAt;

  SecurityGuardState copyWith({bool? active, DateTime? lastCaptureAttemptAt}) {
    return SecurityGuardState(
      active: active ?? this.active,
      lastCaptureAttemptAt: lastCaptureAttemptAt ?? this.lastCaptureAttemptAt,
    );
  }
}

final securityGuardProvider =
    NotifierProvider<SecurityGuardController, SecurityGuardState>(
      SecurityGuardController.new,
    );

class SecurityGuardController extends Notifier<SecurityGuardState>
    with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSub;
  late final ScreenProtectorService _screenProtector;
  late final SecurityEventRepository _repository;
  late final IntegrityChecker _integrity;
  bool _started = false;

  @override
  SecurityGuardState build() {
    _screenProtector = ScreenProtectorService();
    _repository = ref.read(securityEventRepositoryProvider);
    _integrity = IntegrityChecker(
      repository: _repository,
      screenProtectorService: _screenProtector,
    );

    WidgetsBinding.instance.addObserver(this);
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedOut) {
        unawaited(disable());
      } else if (state.session != null) {
        unawaited(enable());
      }
    });
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _authSub?.cancel();
      unawaited(_screenProtector.disable());
    });

    ref.listen(securityBypassProvider, (previous, bypassEnabled) {
      if (bypassEnabled) {
        unawaited(disable());
      } else if (Supabase.instance.client.auth.currentSession != null) {
        unawaited(enable());
      }
    });

    final bypassEnabled = ref.watch(securityBypassProvider);
    final signedIn = Supabase.instance.client.auth.currentSession != null;
    if (signedIn && !bypassEnabled) {
      unawaited(enable());
    } else if (bypassEnabled) {
      unawaited(disable());
    }
    return SecurityGuardState(active: signedIn && !bypassEnabled);
  }

  Future<void> enable() async {
    if (SecurityBypassStore.isEnabled) return;
    if (_started) return;
    _started = true;
    await _screenProtector.enable(_onCaptureAttempt);
    state = state.copyWith(active: true);
    unawaited(_integrity.checkDeveloperMode(warn: true));
    unawaited(_integrity.checkMockLocationSetting(warn: true));
  }

  Future<void> disable() async {
    _started = false;
    await _screenProtector.disable();
    state = state.copyWith(active: false);
  }

  Future<void> _onCaptureAttempt(SecurityEventType type) async {
    await _repository.logEvent(
      type: type,
      severity: SecuritySeverity.warning,
      context: {
        'route': _currentRouteName(),
        'at': DateTime.now().toIso8601String(),
      },
    );
    state = state.copyWith(lastCaptureAttemptAt: DateTime.now());
    final l10n = await loadSavedLocalizations();
    await SecurityWarningDialog.show(
      title: l10n.screenCaptureBlockedTitle,
      message: l10n.screenCaptureBlockedMessage,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (SecurityBypassStore.isEnabled) return;
    if (!this.state.active) return;
    if (state == AppLifecycleState.resumed) {
      unawaited(_integrity.checkDeveloperMode(warn: true));
      unawaited(_integrity.checkMockLocationSetting(warn: true));
      if (_started) {
        // Defensive re-enable; some OEMs clear FLAG_SECURE across transitions.
        unawaited(_screenProtector.enable(_onCaptureAttempt));
      }
    }
  }

  String _currentRouteName() {
    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return 'unknown';
    return context.widget.runtimeType.toString();
  }
}
