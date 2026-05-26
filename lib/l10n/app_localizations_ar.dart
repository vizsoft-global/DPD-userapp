// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitleDefault => 'مسلم للتوصيل';

  @override
  String get appSubtitleDefault => 'شريك التوصيل';

  @override
  String get loginHintDefault => 'أدخل رقمك ورمز الدخول من لوحة الإدارة';

  @override
  String get maintenanceMessageDefault =>
      'تطبيق السائق غير متاح مؤقتاً. يرجى المحاولة لاحقاً.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'موافق';

  @override
  String get exit => 'خروج';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutQuestion => 'تسجيل الخروج؟';

  @override
  String get comingSoon => 'قريباً';

  @override
  String comingSoonMessage(String featureName) {
    return '$featureName قريباً.';
  }

  @override
  String get somethingWentWrong => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get sessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get serverUpdateRequired => 'مطلوب تحديث من الخادم. تواصل مع الدعم.';

  @override
  String get contactAdmin => 'تواصل مع المسؤول للتفاصيل.';

  @override
  String get contactSupport => 'تواصل مع الدعم.';

  @override
  String get notificationFallback => 'إشعار';

  @override
  String get justNow => 'الآن';

  @override
  String get now => 'الآن';

  @override
  String minutesAgo(int minutes) {
    return 'منذ $minutes د';
  }

  @override
  String hoursAgo(int hours) {
    return 'منذ $hours س';
  }

  @override
  String daysAgo(int days) {
    return 'منذ $days ي';
  }

  @override
  String get paid => 'مدفوع';

  @override
  String get approved => 'موافق عليه';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get verified => 'موثّق';

  @override
  String get rejected => 'مرفوض';

  @override
  String get underReview => 'قيد المراجعة';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get notProvided => 'غير متوفر';

  @override
  String get driverFallback => 'سائق';

  @override
  String orderIdPrefix(String orderId) {
    return 'طلب #$orderId';
  }

  @override
  String get deliverySingular => 'توصيل';

  @override
  String get deliveryPlural => 'توصيلات';

  @override
  String deliveriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count توصيل',
      many: '$count توصيلاً',
      few: '$count توصيلات',
      two: 'توصيلان',
      one: 'توصيل واحد',
    );
    return '$_temp0';
  }

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get imgLabel => 'صورة';

  @override
  String get required => 'مطلوب';

  @override
  String uploadingProgress(int percent) {
    return 'جاري الرفع… $percent%';
  }

  @override
  String get readyToUpload => 'جاهز للرفع';

  @override
  String readyToUploadWithSizeKb(String sizeKb) {
    return '$sizeKb ك.ب · جاهز للرفع';
  }

  @override
  String readyToUploadWithSizeMb(String sizeMb) {
    return '$sizeMb م.ب · جاهز للرفع';
  }

  @override
  String get fileEmpty => 'الملف فارغ';

  @override
  String get fileTooLarge10Mb => 'يجب أن تكون الصورة 10 م.ب أو أقل';

  @override
  String get fileTooLarge2Mb => 'يجب أن تكون صورة الملف 2 م.ب أو أقل';

  @override
  String get imagesAllowedOnly => 'يُسمح فقط بصور JPG أو PNG أو WebP';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get driverId => 'رقم السائق';

  @override
  String get passcode => 'رمز الدخول';

  @override
  String get passcodeHint => 'رمز مكوّن من 6 أرقام من لوحة الإدارة';

  @override
  String get continueButton => 'متابعة';

  @override
  String get enterDriverId => 'أدخل رقم السائق المكوّن من 5 أرقام.';

  @override
  String get enterPasscode => 'أدخل رمز الدخول المكوّن من 6 أرقام.';

  @override
  String get authNotConfigured =>
      'التطبيق غير مهيأ. أضف SUPABASE_ANON_KEY عند التشغيل.';

  @override
  String get authInvalidCredentials =>
      'رقم السائق أو رمز الدخول غير صحيح. حاول مرة أخرى.';

  @override
  String get authDriverNotActive =>
      'حساب السائق غير نشط بعد. تواصل مع المسؤول.';

  @override
  String get authStaffNotAllowed => 'هذا الحساب مخصص للوحة الإدارة فقط.';

  @override
  String get authProfileSyncFailed =>
      'تم تسجيل الدخول لكن إعداد الملف فشل. تواصل مع الدعم.';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabDeliveries => 'التوصيلات';

  @override
  String get tabEarnings => 'الأرباح';

  @override
  String get tabVehicle => 'المركبة';

  @override
  String get tabProfile => 'الملف';

  @override
  String get exitAppQuestion => 'الخروج من التطبيق؟';

  @override
  String get exitAppMessage => 'أنت غير متصل وخارج الخدمة. الخروج من التطبيق؟';

  @override
  String get offlineMode => 'وضع عدم الاتصال';

  @override
  String get offlineModeDescription =>
      'يتم حفظ تغييراتك على الجهاز وستُزامَن تلقائياً عند عودة الاتصال.';

  @override
  String get accessBlocked => 'الوصول محظور';

  @override
  String get accountBlockedDefault =>
      'تم حظر حسابك. تواصل مع المسؤول للتفاصيل.';

  @override
  String get backToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get underMaintenance => 'تحت الصيانة';

  @override
  String get pullDownToRefresh => 'اسحب للأسفل للتحديث';

  @override
  String get developerModeDetectedTitle => 'تم اكتشاف وضع المطوّر';

  @override
  String get developerModeDetectedMessage =>
      'خيارات المطوّر مفعّلة على هذا الجهاز. تم تسجيل هذا النشاط.';

  @override
  String get mockLocationDetectedTitle => 'تم اكتشاف موقع وهمي';

  @override
  String get mockLocationDetectedMessage =>
      'إعداد الموقع الوهمي مفعّل على هذا الجهاز. تم تسجيل ذلك.';

  @override
  String get fakeGpsDetectedTitle => 'تم اكتشاف GPS وهمي';

  @override
  String get fakeGpsDetectedMessage =>
      'تم اكتشاف GPS وهمي. إجراءات التوصيل والموقع محظورة حتى يتم إيقافه.';

  @override
  String get fakeGpsBlockedAction =>
      'تم اكتشاف GPS وهمي. أوقف الموقع الوهمي وحاول مرة أخرى.';

  @override
  String get screenCaptureBlockedTitle => 'التقاط الشاشة محظور';

  @override
  String get screenCaptureBlockedMessage =>
      'لقطات الشاشة والتسجيل غير مسموحين. تم تسجيل هذه المحاولة.';

  @override
  String get sosComingSoon => 'SOS قريباً';

  @override
  String get couldNotStartDuty => 'تعذّر بدء الخدمة';

  @override
  String get couldNotUpdateDutyStatus => 'تعذّر تحديث حالة الخدمة';

  @override
  String get currentSpeed => 'السرعة الحالية';

  @override
  String get distanceToday => 'المسافة اليوم';

  @override
  String speedValue(String speed) {
    return '$speed كم/س';
  }

  @override
  String distanceValue(String distance) {
    return '$distance كم';
  }

  @override
  String get welcomeBack => 'مرحباً بعودتك،';

  @override
  String get online => 'في الخدمة';

  @override
  String get offline => 'خارج الخدمة';

  @override
  String get sos => 'SOS';

  @override
  String get bonusOnTrackDefault =>
      'أنت على المسار الصحيح — استمر في التوصيل لفتح المكافآت';

  @override
  String get addDelivery => 'إضافة توصيل';

  @override
  String get startDuty => 'بدء الخدمة';

  @override
  String get thisWeeksProgress => 'تقدم هذا الأسبوع';

  @override
  String get week => 'أسبوع';

  @override
  String get earnings => 'الأرباح';

  @override
  String get onlineTime => 'وقت الخدمة';

  @override
  String get weeklyBumperBonus => 'مكافأة الأسبوع';

  @override
  String get deliveredOrders => 'الطلبات المُسلّمة:';

  @override
  String get fewMoreToUnlock => 'بضع توصيلات إضافية لفتح مكافأتك 💰';

  @override
  String get weeklyBonusUnlockedCelebration => 'تم فتح مكافأة الأسبوع 🎉';

  @override
  String get weeklyBonusUnlocked => 'تم فتح مكافأة الأسبوع!';

  @override
  String get weeklyBonusUnlockedShort => 'تم فتح مكافأة الأسبوع';

  @override
  String deliveriesAwayFromBonus(int remaining, String reward) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'توصيلات',
      one: 'توصيل',
    );
    return 'باقي $remaining $_temp0 للحصول على مكافأة $reward د.ك';
  }

  @override
  String deliverMoreToUnlockKd(int remaining, String reward) {
    return 'سلّم $remaining طلبات إضافية لفتح $reward د.ك مضمونة';
  }

  @override
  String get weeklyBonusDefault => 'مكافأة أسبوعية';

  @override
  String get deliveryRuleDefault => 'قاعدة توصيل';

  @override
  String get deliveryRules => 'قواعد التوصيل';

  @override
  String get allVerifiedCountTowardIncentives =>
      'جميع التوصيلات الموثّقة تُحتسب ضمن الحوافز';

  @override
  String get countsTowardIncentiveDeliveries => 'تُحتسب ضمن توصيلات الحوافز';

  @override
  String get outsideDeliveryAreaReturnSoon => 'خارج منطقة التوصيل. عد قريباً.';

  @override
  String get completeMoreEarnMore => 'أكمل المزيد. اربح المزيد.';

  @override
  String get liveBonusQuestsToday => 'مهام المكافآت النشطة لليوم';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String extraMore(int count) {
    return '+$count أخرى';
  }

  @override
  String get completed => 'مكتمل';

  @override
  String get noActiveQuestsRightNow => 'لا توجد مهام نشطة حالياً';

  @override
  String get tapToSeeAllOffers =>
      'اضغط لعرض جميع عروض الحوافز — عروض جديدة كل أسبوع.';

  @override
  String questUnlockedEarned(String amount) {
    return 'تم فتح المهمة — ربحت $amount';
  }

  @override
  String get keepDeliveringEveryOrderPays => 'استمر في التوصيل — كل طلب يُدفع';

  @override
  String get keepDeliveringToEarnBonus => 'استمر في التوصيل لربح هذه المكافأة';

  @override
  String remainingMoreToMaxEarnedSoFar(int remaining, String amount) {
    return '$remaining متبقية للحد الأقصى — ربحت حتى الآن $amount';
  }

  @override
  String remainingMoreToUnlock(int remaining, String amount) {
    return '$remaining متبقية لفتح $amount';
  }

  @override
  String unlockReward(String amount) {
    return 'افتح $amount';
  }

  @override
  String perDeliveryRate(String rate) {
    return '× $rate / توصيل';
  }

  @override
  String get periodToday => 'اليوم';

  @override
  String get periodThisWeek => 'هذا الأسبوع';

  @override
  String get periodThisMonth => 'هذا الشهر';

  @override
  String get periodThisPeriod => 'هذه الفترة';

  @override
  String get importantNotifications => 'إشعارات مهمة';

  @override
  String get couldNotLoadNotifications => 'تعذّر تحميل الإشعارات.';

  @override
  String get allCaughtUpShort => 'لا توجد إشعارات جديدة.';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get viewMore => 'عرض المزيد';

  @override
  String get couldNotLoadHomeDashboard => 'تعذّر تحميل الصفحة الرئيسية';

  @override
  String get readyForDuty => 'جاهز للخدمة';

  @override
  String get beforeYouGoOnline => 'قبل بدء الخدمة';

  @override
  String get startDutyChecksSubtitle =>
      'أكمل هذه الفحوصات مرة واحدة لبدء التتبع أثناء الخدمة.';

  @override
  String get goOnlineChecksSubtitle =>
      'ما زلت في الخدمة. أصلح ما يلي ثم ابدأ الخدمة.';

  @override
  String get goOnline => 'ابدأ الخدمة';

  @override
  String get refreshChecks => 'تحديث الفحوصات';

  @override
  String allChecksPassed(int ok, int total) {
    return 'اجتازت جميع الفحوصات ($ok/$total).';
  }

  @override
  String someChecksPassed(int ok, int total) {
    return '$ok من $total فحوصات مطلوبة — اضغط على صف للإصلاح.';
  }

  @override
  String get permissionLocationServicesTitle => 'خدمات الموقع';

  @override
  String get permissionLocationServicesDesc =>
      'يجب تفعيل GPS لتتبع المنطقة أثناء الخدمة.';

  @override
  String get permissionLocationAccessTitle => 'صلاحية الموقع';

  @override
  String get permissionLocationAccessDesc =>
      'اسمح بالموقع الدقيق أثناء استخدام التطبيق.';

  @override
  String get permissionBackgroundLocationTitle => 'الموقع في الخلفية';

  @override
  String get permissionBackgroundLocationDesc =>
      'موصى به لاستمرار التتبع عند تصغير التطبيق.';

  @override
  String get permissionNotificationsTitle => 'الإشعارات';

  @override
  String get permissionNotificationsDesc => 'مطلوبة لخدمة التتبع أثناء الخدمة.';

  @override
  String get permissionBatteryOptimizationTitle => 'تحسين البطارية';

  @override
  String get permissionBatteryOptimizationDesc =>
      'استثنِ التطبيق من قيود البطارية أثناء الخدمة.';

  @override
  String get permissionCameraTitle => 'الكاميرا';

  @override
  String get permissionCameraDesc => 'مطلوبة لتصوير إثبات التوصيل.';

  @override
  String get openLocationSettings => 'فتح إعدادات الموقع';

  @override
  String get openBatterySettings => 'فتح إعدادات البطارية';

  @override
  String get openAppSettings => 'فتح إعدادات التطبيق';

  @override
  String get allow => 'سماح';

  @override
  String get goOffline => 'قطع الاتصال';

  @override
  String get onDutyTapToOpen => 'في الخدمة — اضغط للفتح';

  @override
  String get onDutySignInAgain => 'في الخدمة — سجّل الدخول مجدداً';

  @override
  String get onDutyTurnOnGps => 'في الخدمة — فعّل GPS';

  @override
  String get onDutyLocationPermissionNeeded =>
      'في الخدمة — صلاحية الموقع مطلوبة';

  @override
  String get onDutyStationaryGpsPaused => 'في الخدمة — ثابت (GPS متوقف)';

  @override
  String get onDutyLocationUpdateFailed => 'في الخدمة — فشل تحديث الموقع';

  @override
  String get checkedOutInactive5Min => 'تم الخروج — غير نشط لـ 5 د';

  @override
  String get onDutyAutoCheckoutFailed => 'في الخدمة — فشل الخروج التلقائي';

  @override
  String get onDutyGoOfflineFailed => 'في الخدمة — فشل قطع الاتصال';

  @override
  String get onDutyFakeGpsDetected => 'في الخدمة — GPS وهمي';

  @override
  String get inZone => 'داخل المنطقة';

  @override
  String get outsideDeliveryArea => 'خارج منطقة التوصيل';

  @override
  String get onDuty => 'في الخدمة';

  @override
  String get moving => 'متحرك';

  @override
  String get deliveryLogged => 'تم تسجيل التوصيل';

  @override
  String get idle => 'خامل';

  @override
  String get onDutyTrackingChannelName => 'تتبع أثناء الخدمة';

  @override
  String get onDutyTrackingChannelDesc => 'يظهر أثناء الخدمة لتتبع GPS.';

  @override
  String get mustBeOnDutyToReportLocation =>
      'يجب أن تكون في الخدمة للإبلاغ عن الموقع.';

  @override
  String get couldNotReportLocation => 'تعذّر الإبلاغ عن الموقع';

  @override
  String get locationReportFailed => 'فشل تقرير الموقع';

  @override
  String pendingDeliveriesWaitingToSync(int count) {
    return '$count توصيلات معلّقة بانتظار المزامنة';
  }

  @override
  String get couldNotLoadDeliveries => 'تعذّر تحميل التوصيلات';

  @override
  String get pendingDeliveries => 'توصيلات معلّقة';

  @override
  String get noPendingDeliveries => 'لا توصيلات معلّقة';

  @override
  String pendingSyncedSummary(int pending, int synced) {
    return 'معلّق: $pending · مُزامَن: $synced';
  }

  @override
  String get noDeliveriesAdded => 'لم تُضف توصيلات';

  @override
  String get startAddingDeliveries => 'ابدأ بإضافة توصيلاتك لتتبع عملك';

  @override
  String get addOrders => 'إضافة طلبات';

  @override
  String get imageFormatsMax10Mb => 'JPG أو PNG أو WebP · حد أقصى 10 م.ب';

  @override
  String get checkingYourLocation => 'جاري التحقق من موقعك…';

  @override
  String get orderId => 'رقم الطلب';

  @override
  String get orderIdHint => 'مثال: 12345';

  @override
  String get uploadOrderProof => 'رفع إثبات الطلب';

  @override
  String get takePhotoOrChooseGallery => 'التقط صورة أو اختر من المعرض';

  @override
  String get imageFormatsMax10MbShort => 'JPG, PNG, WebP · حد أقصى 10 م.ب';

  @override
  String get markAsDelivered => 'تعليم كمُسلّم';

  @override
  String get orderIdRequired => 'رقم الطلب مطلوب';

  @override
  String get deliverySavedOffline => 'تم حفظ التوصيل دون اتصال';

  @override
  String get deliveryAddedSuccessfully => 'تمت إضافة التوصيل بنجاح';

  @override
  String get deliveryWillSyncWhenOnline =>
      'ستُزامَن هذه الإدخالات تلقائياً عند عودة الإنترنت.';

  @override
  String get keepGoingEveryDeliveryCounts => 'استمر — كل توصيل يُحتسب!';

  @override
  String get addAnotherDelivery => 'إضافة توصيل آخر';

  @override
  String get offlineModePendingSync => 'وضع عدم الاتصال: مزامنة معلّقة';

  @override
  String get backToDeliveries => 'العودة للتوصيلات';

  @override
  String get deliveryDetails => 'تفاصيل التوصيل';

  @override
  String get status => 'الحالة';

  @override
  String get submitted => 'تم الإرسال';

  @override
  String get partner => 'الشريك';

  @override
  String get deliveryProof => 'إثبات التوصيل';

  @override
  String get noProofImageUploaded => 'لم يُرفع إثبات';

  @override
  String get couldNotLoadProofImage => 'تعذّر تحميل إثبات التوصيل';

  @override
  String get couldNotDisplayImage => 'تعذّر عرض الصورة';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String selectedDayVerifiedOrders(int count) {
    return 'طلبات اليوم الموثّقة: $count';
  }

  @override
  String thisMonthVerifiedOrders(int count) {
    return 'طلبات الشهر الموثّقة: $count';
  }

  @override
  String get apply => 'تطبيق';

  @override
  String get today => 'اليوم';

  @override
  String get pleaseSignInAgain => 'يرجى تسجيل الدخول مجدداً';

  @override
  String get accountNotActive => 'حسابك غير نشط';

  @override
  String get outsideAllowedDeliveryArea =>
      'أنت خارج منطقة التوصيل المسموحة. اقترب من منطقتك أو مطعم مُعيَّن.';

  @override
  String get gpsRequiredForDelivery => 'موقع GPS مطلوب لتسجيل التوصيل';

  @override
  String get zoneNotConfigured => 'منطقتك غير مهيأة. تواصل مع المسؤول.';

  @override
  String get noRestaurantsAssigned => 'لا مطاعم مُعيَّنة. تواصل مع المسؤول.';

  @override
  String moveWithinRangeToLog(String range, String target) {
    return 'اقترب ضمن $range من $target لتسجيل التوصيل.';
  }

  @override
  String outsideRangeDetails(String distance, String range, String target) {
    return 'أنت على بعد $distance خارج النطاق (ضمن $range من $target).';
  }

  @override
  String get yourZone => 'منطقتك';

  @override
  String get assignedRestaurant => 'مطعم مُعيَّن';

  @override
  String get accountNotSetupAsDriver => 'حسابك غير مهيأ كسائق.';

  @override
  String get couldNotLoadDeliveryLocationRules =>
      'تعذّر تحميل قواعد موقع التوصيل. اسحب للتحديث أو حاول مجدداً.';

  @override
  String get notSignedIn => 'غير مسجّل الدخول';

  @override
  String get proofImageMissing => 'صورة الإثبات مفقودة';

  @override
  String get proofImageNotFound => 'صورة الإثبات غير موجودة';

  @override
  String get cannotViewProofImage => 'لا يمكنك عرض صورة الإثبات';

  @override
  String get couldNotLoadEarnings => 'تعذّر تحميل الأرباح';

  @override
  String get performanceSummary => 'ملخص الأداء';

  @override
  String get totalDeliveries => 'إجمالي التوصيلات';

  @override
  String get workingDays => 'أيام العمل';

  @override
  String get attendance => 'الحضور';

  @override
  String get incentives => 'الحوافز';

  @override
  String get reimbursements => 'المستردات';

  @override
  String get deductions => 'الخصومات';

  @override
  String get extraEarnings => 'أرباح إضافية';

  @override
  String get dailyEarnings => 'الأرباح اليومية';

  @override
  String get noEarningsActivityThisMonth => 'لا نشاط أرباح هذا الشهر.';

  @override
  String deliveryCountSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count توصيل',
      many: '$count توصيلاً',
      few: '$count توصيلات',
      two: 'توصيلان',
      one: 'توصيل واحد',
    );
    return '$_temp0';
  }

  @override
  String bonusesApplied(int count) {
    return '$count مكافآت مُطبَّقة';
  }

  @override
  String get bonusSuffix => 'مكافأة';

  @override
  String get deductionsComingSoonTitle => 'الخصومات';

  @override
  String get deductionsComingSoonBody =>
      'قريباً — تفصيل القروض أو الغرامات المطبّقة على أرباحك.';

  @override
  String get payslipHistory => 'سجل كشوف الرواتب';

  @override
  String get latestFirst => 'الأحدث أولاً';

  @override
  String get noPayslipsYet =>
      'لا كشوف رواتب بعد. عند موافقة فريق العمليات على دفعة، ستظهر هنا.';

  @override
  String deliveriesInPeriod(int count) {
    return '$count توصيلات';
  }

  @override
  String deliveriesInPayoutPeriod(int count) {
    return '$count توصيلات في هذه الفترة';
  }

  @override
  String get activeOffers => 'عروض نشطة';

  @override
  String get noActiveIncentivesRightNow => 'لا حوافز نشطة حالياً';

  @override
  String get checkBackLaterIncentives =>
      'عد لاحقاً — فريق العمليات يُعد قواعد الحوافز من لوحة الإدارة.';

  @override
  String get couldNotLoadExtraEarnings => 'تعذّر تحميل الأرباح الإضافية';

  @override
  String get progress => 'التقدم';

  @override
  String get bonusDefault => 'مكافأة';

  @override
  String get incentiveDefault => 'حافز';

  @override
  String upToAmount(String amount) {
    return 'حتى $amount';
  }

  @override
  String perDeliveryAmount(String amount) {
    return '$amount/توصيل';
  }

  @override
  String completeDeliveriesScope(int target, String scope, String period) {
    return 'أكمل $target توصيلات$scope $period';
  }

  @override
  String earnRewardsScope(String scope, String period) {
    return 'اربح مكافآت$scope $period';
  }

  @override
  String get periodTodayLower => 'اليوم';

  @override
  String get periodThisWeekLower => 'هذا الأسبوع';

  @override
  String get periodThisMonthLower => 'هذا الشهر';

  @override
  String get periodThisPeriodLower => 'هذه الفترة';

  @override
  String fromScope(String scope) {
    return 'من $scope';
  }

  @override
  String forScope(String scope) {
    return 'لـ $scope';
  }

  @override
  String get netEarnings => 'صافي الأرباح';

  @override
  String get eligibleDeliveries => 'التوصيلات المؤهلة';

  @override
  String get basePay => 'الأجر الأساسي';

  @override
  String get noDeliveriesLoggedThisDay => 'لا توصيلات مسجّلة هذا اليوم.';

  @override
  String get incentiveRules => 'قواعد الحوافز';

  @override
  String get noIncentiveRulesPaidThisDay => 'لا قواعد حوافز دُفعت هذا اليوم.';

  @override
  String overrideRuleApplied(String amount) {
    return 'قاعدة استثناء مُطبَّقة — الحافز النهائي $amount';
  }

  @override
  String eligibleDeliveriesProgress(int current, int target) {
    return '$current / $target توصيلات مؤهلة';
  }

  @override
  String eligibleDeliveriesCount(int count) {
    return '$count توصيلات مؤهلة';
  }

  @override
  String get couldNotLoadThisDay => 'تعذّر تحميل هذا اليوم';

  @override
  String get payslip => 'كشف راتب';

  @override
  String get netPayable => 'صافي المستحق';

  @override
  String paidAt(String date, String time) {
    return 'دُفع $date الساعة $time';
  }

  @override
  String get breakdown => 'التفصيل';

  @override
  String get loanDeduction => 'خصم قرض';

  @override
  String get penalty => 'غرامة';

  @override
  String get adjustment => 'تعديل';

  @override
  String get notes => 'ملاحظات';

  @override
  String get detailedSnapshot => 'لقطة تفصيلية';

  @override
  String get frozenAtApproval => 'مجمّدة وقت الموافقة على هذه الدفعة.';

  @override
  String get couldNotLoadThisPayslip => 'تعذّر تحميل كشف الراتب';

  @override
  String get payslipNoLongerAvailable => 'كشف الراتب لم يعد متاحاً.';

  @override
  String get couldNotLoadAttendance => 'تعذّر تحميل الحضور';

  @override
  String attendanceDaysCompleted(int present, int elapsed) {
    return 'أتم $present/$elapsed يومًا';
  }

  @override
  String get noLogin => 'لم يسجّل دخول';

  @override
  String get lessThanZeroHours => 'أقل من 0 س';

  @override
  String get moreThanZeroHours => 'أكثر من 0 س';

  @override
  String get weekdayMon => 'إث';

  @override
  String get weekdayTue => 'ثل';

  @override
  String get weekdayWed => 'أر';

  @override
  String get weekdayThu => 'خم';

  @override
  String get weekdayFri => 'جم';

  @override
  String get weekdaySat => 'سب';

  @override
  String get weekdaySun => 'أح';

  @override
  String get weekdayMonUpper => 'إث';

  @override
  String get weekdayTueUpper => 'ثل';

  @override
  String get weekdayWedUpper => 'أر';

  @override
  String get weekdayThuUpper => 'خم';

  @override
  String get weekdayFriUpper => 'جم';

  @override
  String get weekdaySatUpper => 'سب';

  @override
  String get weekdaySunUpper => 'أح';

  @override
  String get monthJanuary => 'يناير';

  @override
  String get monthFebruary => 'فبراير';

  @override
  String get monthMarch => 'مارس';

  @override
  String get monthApril => 'أبريل';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthJune => 'يونيو';

  @override
  String get monthJuly => 'يوليو';

  @override
  String get monthAugust => 'أغسطس';

  @override
  String get monthSeptember => 'سبتمبر';

  @override
  String get monthOctober => 'أكتوبر';

  @override
  String get monthNovember => 'نوفمبر';

  @override
  String get monthDecember => 'ديسمبر';

  @override
  String get monthJan => 'ينا';

  @override
  String get monthFeb => 'فبر';

  @override
  String get monthMar => 'مار';

  @override
  String get monthApr => 'أبر';

  @override
  String get monthMayShort => 'ماي';

  @override
  String get monthJun => 'يون';

  @override
  String get monthJul => 'يول';

  @override
  String get monthAug => 'أغس';

  @override
  String get monthSep => 'سبت';

  @override
  String get monthOct => 'أكت';

  @override
  String get monthNov => 'نوف';

  @override
  String get monthDec => 'ديس';

  @override
  String profileImageUploadFailed(String error) {
    return 'فشل رفع صورة الملف: $error';
  }

  @override
  String get profilePictureUpdated => 'تم تحديث صورة الملف';

  @override
  String get uploadedPreviewFailed =>
      'تم الرفع لكن تعذّر عرض المعاينة. اسحب للتحديث — تواصل مع الدعم إن استمر.';

  @override
  String get notificationsSettingsComingSoon => 'إعدادات الإشعارات قريباً';

  @override
  String get signOutConfirmBody =>
      'ستحتاج رقم السائق ورمز الدخول لتسجيل الدخول مجدداً.';

  @override
  String get accountSection => 'الحساب';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get attendanceAndLeaves => 'الحضور والإجازات';

  @override
  String get wrongAction => 'مخالفة';

  @override
  String get paymentDetails => 'تفاصيل الدفع';

  @override
  String get assets => 'الأصول';

  @override
  String get preferencesSection => 'التفضيلات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get trainingSection => 'التدريب';

  @override
  String get tutorialMaterial => 'مواد تعليمية';

  @override
  String get video => 'فيديو';

  @override
  String get couldNotLoadProfile => 'تعذّر تحميل الملف';

  @override
  String get profileSessionExpiredHint =>
      'ربما انتهت جلستك. حاول مجدداً أو سجّل الخروج والدخول.';

  @override
  String get profile => 'الملف';

  @override
  String get help => 'مساعدة';

  @override
  String driverIdLabel(String code) {
    return 'الرقم: $code';
  }

  @override
  String get updateProfilePicture => 'تحديث صورة الملف';

  @override
  String couldNotLoadNotificationsWithError(String error) {
    return 'تعذّر تحميل الإشعارات.\n$error';
  }

  @override
  String get allCaughtUp => 'لا إشعارات جديدة';

  @override
  String get notificationsEmptyHint =>
      'ستظهر هنا التنبيهات والتذكيرات المهمة من مسلم.';

  @override
  String get musallamAlertsChannelName => 'تنبيهات مسلم';

  @override
  String get musallamAlertsChannelDesc => 'تنبيهات وتذكيرات تشغيلية للسائقين';

  @override
  String get vehicle => 'المركبة';

  @override
  String get vehicleComingSoon => 'معلومات المركبة والصيانة. قريباً.';

  @override
  String get am => 'ص';

  @override
  String get pm => 'م';

  @override
  String onDutyStatusLabel(String status, String speed, String zone) {
    return '$status$speed · $zone';
  }

  @override
  String get couldNotStartUpload => 'تعذّر بدء الرفع';

  @override
  String get couldNotConfirmUpload => 'تعذّر تأكيد الرفع';

  @override
  String get networkErrorReachingAdminUploadServer =>
      'خطأ شبكة عند الاتصال بخادم الرفع';

  @override
  String uploadFailedWithStatus(int statusCode) {
    return 'فشل الرفع ($statusCode)';
  }

  @override
  String get availabilitySubmission => 'تقديم التوفر';

  @override
  String get shiftSubmissionSubtitle =>
      'حدّد وردية اليوم قبل بدء الخدمة. بعد الحفظ لا يمكن تغييرها حتى انتهاء الوردية.';

  @override
  String get shiftType => 'نوع الوردية';

  @override
  String get selectShift => 'اختر الوردية';

  @override
  String get singleShift => 'وردية واحدة';

  @override
  String get splitShift => 'وردية مقسّمة';

  @override
  String get setTimeline => 'حدّد الوقت';

  @override
  String get fromTime => 'من';

  @override
  String get toTime => 'إلى';

  @override
  String get session2 => 'الجلسة 2';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get confirm => 'تأكيد';

  @override
  String get shiftEndsNextDay => 'ينتهي في اليوم التالي';

  @override
  String get session1Required => 'يرجى تحديد وقت بداية ونهاية الجلسة 1';

  @override
  String get session2Required => 'يرجى تحديد وقت بداية ونهاية الجلسة 2';

  @override
  String get invalidSessionDuration =>
      'وقت النهاية يجب أن يكون بعد وقت البداية';

  @override
  String get sessionTooLong => 'كل جلسة يجب ألا تتجاوز 24 ساعة';

  @override
  String get sessionsOverlap => 'لا يمكن أن تتداخل الجلسات';

  @override
  String get shiftLocked => 'وردية اليوم مقفلة حتى انتهائها';

  @override
  String get couldNotSubmitShift => 'تعذّر حفظ الوردية';

  @override
  String get outsideShiftWindowTitle => 'خارج وقت الوردية';

  @override
  String get outsideShiftWindowMessage =>
      'أنت خارج ساعات الوردية المحددة. يمكنك المتابعة، لكن قد يتم مراجعتها.';

  @override
  String get continueAnyway => 'متابعة على أي حال';

  @override
  String get mustBeOnDutyToAddDelivery => 'يجب أن تكون في الخدمة لإضافة توصيل';

  @override
  String get shiftRequiredBeforeDuty => 'قدّم وردية اليوم قبل بدء الخدمة';
}
