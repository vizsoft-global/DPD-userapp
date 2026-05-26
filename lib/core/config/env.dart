/// Supabase config. Pass values via `--dart-define` (see scripts/run_dev.sh).
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ytfmsgckjatiserpgdbz.supabase.co',
  );

  // TODO(prod): remove hardcoded default; pass SUPABASE_ANON_KEY via --dart-define only.
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl0Zm1zZ2NramF0aXNlcnBnZGJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4NDk0NzcsImV4cCI6MjA5MzQyNTQ3N30.U3a-TyxhdQTuceeQFskp1ZfFmqRR75UnoGGFmxLU-h0',
  );

  /// Admin panel origin for driver R2 presign/confirm (no R2 keys in app).
  static const adminApiBaseUrl = String.fromEnvironment(
    'ADMIN_API_BASE_URL',
    defaultValue: 'https://dpdadmin.vercel.app',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Firebase client SDK overrides (optional — defaults match docs/firebase).
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'musallam-delivery-kw',
  );

  static const firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBeDbxBUMG6tOv6cwYVwvtWJ6dQPWsodH4',
  );

  static const firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:942102607123:android:2b709642cb7ab7a48096e6',
  );

  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '942102607123',
  );

  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'musallam-delivery-kw.firebasestorage.app',
  );

  static const firebaseIosAppId = String.fromEnvironment(
    'FIREBASE_IOS_APP_ID',
    defaultValue: '1:942102607123:ios:442ef4381a6480f48096e6',
  );

  static const firebaseIosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'kw.musallam.delivery',
  );

  static bool get isFirebaseConfigured => firebaseProjectId.isNotEmpty;

  /// Sentry crash reporting (vizsoft-global / flutter-mussalam).
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue:
        'https://93a1c90701f01ef9b795cb3e6867ed85@o4511238625624064.ingest.us.sentry.io/4511453198614528',
  );

  static const sentryEnvironment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: 'production',
  );

  static bool get isSentryConfigured => sentryDsn.isNotEmpty;
}
