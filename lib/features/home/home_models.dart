import '../../l10n/app_localizations.dart';

class HomeDashboard {
  const HomeDashboard({
    required this.driver,
    required this.session,
    required this.week,
    this.primaryWeeklyIncentive,
    this.deliveryRules = const [],
  });

  final HomeDriverInfo driver;
  final HomeSessionInfo session;
  final HomeWeekStats week;
  final HomeIncentiveProgress? primaryWeeklyIncentive;
  final List<HomeDeliveryRuleSummary> deliveryRules;

  bool get isOnline => session.isOnline;
  bool get isOnDuty => driver.isOnDuty;
  bool get isOnlineOnDuty => isOnline && isOnDuty;

  factory HomeDashboard.fromJson(Map<String, dynamic> json) {
    final incentiveRaw = json['primary_weekly_incentive'];
    return HomeDashboard(
      driver: HomeDriverInfo.fromJson(
        Map<String, dynamic>.from(json['driver'] as Map? ?? {}),
      ),
      session: HomeSessionInfo.fromJson(
        Map<String, dynamic>.from(json['session'] as Map? ?? {}),
      ),
      week: HomeWeekStats.fromJson(
        Map<String, dynamic>.from(json['week'] as Map? ?? {}),
      ),
      primaryWeeklyIncentive:
          incentiveRaw == null ||
              incentiveRaw is! Map ||
              incentiveRaw['name'] == null
          ? null
          : HomeIncentiveProgress.fromJson(
              Map<String, dynamic>.from(incentiveRaw),
            ),
      deliveryRules: (json['delivery_rules'] as List? ?? [])
          .map(
            (e) => HomeDeliveryRuleSummary.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}

class HomeDriverInfo {
  const HomeDriverInfo({
    required this.fullName,
    required this.isOnDuty,
    this.partnerName,
    this.partnerLogoUrl,
  });

  final String fullName;
  final bool isOnDuty;
  final String? partnerName;
  final String? partnerLogoUrl;

  bool get hasDisplayablePartnerLogo {
    final url = partnerLogoUrl?.trim();
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  factory HomeDriverInfo.fromJson(Map<String, dynamic> json) {
    return HomeDriverInfo(
      fullName: json['full_name'] as String? ?? 'Driver',
      isOnDuty: json['is_on_duty'] as bool? ?? false,
      partnerName: json['partner_name'] as String?,
      partnerLogoUrl: json['partner_logo_url'] as String?,
    );
  }
}

class HomeSessionInfo {
  const HomeSessionInfo({
    required this.isOnline,
    this.wentOnlineAt,
    this.speedMps,
    this.distanceTodayMeters = 0,
  });

  final bool isOnline;
  final DateTime? wentOnlineAt;
  final double? speedMps;
  final double distanceTodayMeters;

  factory HomeSessionInfo.fromJson(Map<String, dynamic> json) {
    final wentOnlineRaw = json['went_online_at'] as String?;
    return HomeSessionInfo(
      isOnline: json['is_online'] as bool? ?? false,
      wentOnlineAt: wentOnlineRaw != null
          ? DateTime.tryParse(wentOnlineRaw)
          : null,
      speedMps: (json['speed_mps'] as num?)?.toDouble(),
      distanceTodayMeters:
          (json['distance_today_meters'] as num?)?.toDouble() ?? 0,
    );
  }
}

class HomeWeekStats {
  const HomeWeekStats({
    required this.startDate,
    required this.endDate,
    required this.earningsKwd,
    required this.deliveriesCount,
    required this.onlineSeconds,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final double earningsKwd;
  final int deliveriesCount;
  final int onlineSeconds;

  String get earningsLabel {
    final value = earningsKwd == earningsKwd.roundToDouble()
        ? earningsKwd.toInt().toString()
        : earningsKwd.toStringAsFixed(3);
    return '$value KD';
  }

  String get onlineTimeLabel {
    final hours = onlineSeconds ~/ 3600;
    final minutes = (onlineSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  factory HomeWeekStats.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    return HomeWeekStats(
      startDate: parseDate(json['start_date'] as String?),
      endDate: parseDate(json['end_date'] as String?),
      earningsKwd: (json['earnings_kwd'] as num?)?.toDouble() ?? 0,
      deliveriesCount: (json['deliveries_count'] as num?)?.toInt() ?? 0,
      onlineSeconds: (json['online_seconds'] as num?)?.toInt() ?? 0,
    );
  }
}

class HomeIncentiveProgress {
  const HomeIncentiveProgress({
    required this.name,
    required this.eligibleCount,
    required this.target,
    required this.rewardKwd,
    required this.remainingDeliveries,
    this.targetMode = 'single',
    this.tiers = const [],
  });

  final String name;
  final int eligibleCount;
  final int target;
  final double rewardKwd;
  final int remainingDeliveries;
  final String targetMode;
  final List<HomeIncentiveTier> tiers;

  String bonusHeadline(AppLocalizations l10n) {
    if (remainingDeliveries <= 0) {
      return l10n.weeklyBonusUnlocked;
    }
    final reward = rewardKwd == rewardKwd.roundToDouble()
        ? rewardKwd.toInt().toString()
        : rewardKwd.toStringAsFixed(0);
    return l10n.deliveriesAwayFromBonus(remainingDeliveries, reward);
  }

  String bumperSubtitle(AppLocalizations l10n) {
    if (remainingDeliveries <= 0) return l10n.weeklyBonusUnlockedShort;
    final reward = rewardKwd == rewardKwd.roundToDouble()
        ? rewardKwd.toInt().toString()
        : rewardKwd.toStringAsFixed(0);
    return l10n.deliverMoreToUnlockKd(remainingDeliveries, reward);
  }

  int get maxTierThreshold {
    if (tiers.isNotEmpty) {
      return tiers.map((t) => t.threshold).reduce((a, b) => a > b ? a : b);
    }
    return target > 0 ? target : 1;
  }

  factory HomeIncentiveProgress.fromJson(Map<String, dynamic> json) {
    return HomeIncentiveProgress(
      name: json['name'] as String? ?? 'Weekly Bonus',
      eligibleCount: (json['eligible_count'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 0,
      rewardKwd: (json['reward_kwd'] as num?)?.toDouble() ?? 0,
      remainingDeliveries: (json['remaining_deliveries'] as num?)?.toInt() ?? 0,
      targetMode: json['target_mode'] as String? ?? 'single',
      tiers: (json['tiers'] as List? ?? [])
          .map(
            (e) =>
                HomeIncentiveTier.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(growable: false),
    );
  }
}

class HomeIncentiveTier {
  const HomeIncentiveTier({
    required this.threshold,
    this.rewardKwd,
    this.rewardPerDeliveryKwd,
    this.rewardMode = 'fixed',
  });

  final int threshold;
  final double? rewardKwd;
  final double? rewardPerDeliveryKwd;
  final String rewardMode;

  String get rewardLabel {
    if (rewardMode == 'per_delivery' && rewardPerDeliveryKwd != null) {
      final v = rewardPerDeliveryKwd!;
      return v == 0.25
          ? '1/4 KD'
          : v == 0.5
          ? '1/2 KD'
          : '$v KD';
    }
    if (rewardKwd == null) return '';
    final v = rewardKwd!;
    if (v == 0.25) return '1/4 KD';
    if (v == 0.5) return '1/2 KD';
    if (v == 1) return '1 KD';
    return '$v KD';
  }

  factory HomeIncentiveTier.fromJson(Map<String, dynamic> json) {
    return HomeIncentiveTier(
      threshold: (json['threshold'] as num?)?.toInt() ?? 0,
      rewardKwd: (json['reward_kwd'] as num?)?.toDouble(),
      rewardPerDeliveryKwd: (json['reward_per_delivery_kwd'] as num?)
          ?.toDouble(),
      rewardMode: json['reward_mode'] as String? ?? 'fixed',
    );
  }
}

class HomeDeliveryRuleSummary {
  const HomeDeliveryRuleSummary({
    required this.id,
    required this.name,
    required this.scopeType,
    this.restaurantName,
    this.startDate,
    this.endDate,
    this.summary,
  });

  final String id;
  final String name;
  final String scopeType;
  final String? restaurantName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? summary;

  factory HomeDeliveryRuleSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    return HomeDeliveryRuleSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Delivery rule',
      scopeType: json['scope_type'] as String? ?? 'restaurant',
      restaurantName: json['restaurant_name'] as String?,
      startDate: parseDate(json['start_date'] as String?),
      endDate: parseDate(json['end_date'] as String?),
      summary: json['summary'] as String?,
    );
  }
}
