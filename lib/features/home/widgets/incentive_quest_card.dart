import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../earnings/earnings_models.dart';
import '../../earnings/earnings_providers.dart';
import 'kd_note.dart';

/// "Complete more. Earn more." card on the home screen.
///
/// Replaces the dry `DeliveryRulesCard`. Instead of listing rule names, this
/// pulls the same `driver_get_extra_earnings` data as the dedicated
/// Extra Earnings screen and renders each applicable incentive rule as a
/// gamified "quest" with progress, base/target milestones, and a multiplier
/// chip that lights up when the driver is past the base minimum.
///
/// Behaviour:
///   - Loading -> skeleton placeholder
///   - Error or no offers -> friendly empty-state CTA pointing to extras
///   - Otherwise -> up to 2 most relevant quests inline + a "View all" link
///
/// The whole card is tap-to-extra-earnings so drivers can always drill in.
class IncentiveQuestCard extends ConsumerWidget {
  const IncentiveQuestCard({super.key});

  static const _inlineQuestLimit = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extraAsync = ref.watch(extraEarningsProvider);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/earnings/extra'),
        child: extraAsync.when(
          loading: () => const _QuestSkeleton(),
          error: (_, _) => const _QuestEmpty(),
          data: (extra) {
            final offers = _orderOffers(extra.activeOffers);
            if (offers.isEmpty) return const _QuestEmpty();
            return _QuestList(
              offers: offers.take(_inlineQuestLimit).toList(),
              moreCount: offers.length - _inlineQuestLimit,
            );
          },
        ),
      ),
    );
  }

  /// Push completed offers to the bottom, then in-progress closest-to-target
  /// first so the driver sees the "almost there!" quest at the top.
  static List<ActiveOffer> _orderOffers(List<ActiveOffer> offers) {
    final sorted = [...offers];
    sorted.sort((a, b) {
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      // Higher progress first
      return b.progressFraction.compareTo(a.progressFraction);
    });
    return sorted;
  }
}

// ---------------------------------------------------------------------------
// Hero band — shared shell around every state of the card
// ---------------------------------------------------------------------------

class _QuestShell extends StatelessWidget {
  const _QuestShell({required this.child, this.trailingMore = 0});

  final Widget child;

  /// When > 0 a "+N more" chip appears in the header instead of "View all".
  final int trailingMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bonusNavy,
            AppColors.bonusNavy.withValues(alpha: 0.92),
            AppColors.blueberry,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.bonusNavy.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.tomatoOrange.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🏆', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.completeMoreEarnMore,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        l10n.liveBonusQuestsToday,
                        style: const TextStyle(
                          color: Color(0xFFD9D6F4),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _ViewAllChip(extraMore: trailingMore, l10n: l10n),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ViewAllChip extends StatelessWidget {
  const _ViewAllChip({this.extraMore = 0, required this.l10n});

  final int extraMore;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final label =
        extraMore > 0 ? l10n.extraMore(extraMore) : l10n.viewAll;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List of quests
// ---------------------------------------------------------------------------

class _QuestList extends StatelessWidget {
  const _QuestList({required this.offers, required this.moreCount});

  final List<ActiveOffer> offers;
  final int moreCount;

  @override
  Widget build(BuildContext context) {
    return _QuestShell(
      trailingMore: moreCount > 0 ? moreCount : 0,
      child: Column(
        children: [
          for (var i = 0; i < offers.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _QuestRow(offer: offers[i]),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// One quest
// ---------------------------------------------------------------------------

class _QuestRow extends StatelessWidget {
  const _QuestRow({required this.offer});

  final ActiveOffer offer;

  bool get _isPerDelivery => offer.rewardMode == 'per_delivery';

  String _multiplierLabel(AppLocalizations l10n) {
    if (_isPerDelivery) {
      final rate = offer.rewardPerDeliveryKwd ?? 0;
      return l10n.perDeliveryRate(formatKwd(rate));
    }
    return l10n.unlockReward(
      formatKwd(offer.headlineRewardKwd, plus: true),
    );
  }

  String _statusLine(AppLocalizations l10n) {
    if (offer.completed) {
      final earned = offer.currentPayoutKwd > 0
          ? offer.currentPayoutKwd
          : offer.rewardKwd;
      return l10n.questUnlockedEarned(formatKwd(earned, plus: true));
    }
    if (offer.target <= 0) {
      return _isPerDelivery
          ? l10n.keepDeliveringEveryOrderPays
          : l10n.keepDeliveringToEarnBonus;
    }
    final remaining = offer.remainingDeliveries;
    if (_isPerDelivery) {
      return l10n.remainingMoreToMaxEarnedSoFar(
        remaining,
        formatKwd(offer.currentPayoutKwd, plus: true),
      );
    }
    return l10n.remainingMoreToUnlock(
      remaining,
      formatKwd(offer.headlineRewardKwd, plus: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final completed = offer.completed;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed
              ? AppColors.verifiedGreen.withValues(alpha: 0.6)
              : const Color(0xFFE1DBFF),
          width: completed ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuestHeader(offer: offer, l10n: l10n),
          const SizedBox(height: 4),
          _BikeTrack(offer: offer),
          const SizedBox(height: 4),
          Row(
            children: [
              _MultiplierChip(
                label: _multiplierLabel(l10n),
                active: _isPerDelivery
                    ? offer.currentCount > offer.baseMinimumDeliveries
                    : completed,
                completed: completed,
              ),
              const Spacer(),
              if (completed)
                _CompletedBadge(l10n: l10n)
              else if (offer.target > 0)
                Text(
                  '${offer.currentCount} / ${offer.target}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF141414),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _statusLine(l10n),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: completed
                  ? AppColors.verifiedGreen
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestHeader extends StatelessWidget {
  const _QuestHeader({required this.offer, required this.l10n});

  final ActiveOffer offer;
  final AppLocalizations l10n;

  String _scopeLabel() {
    final scope = offer.scopeLabel?.trim();
    if (scope == null || scope.isEmpty) return '';
    return ' · $scope';
  }

  String _periodLabel() {
    return switch (offer.period) {
      'daily' => l10n.periodToday,
      'weekly' => l10n.periodThisWeek,
      'monthly' => l10n.periodThisMonth,
      _ => l10n.periodThisPeriod,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.title(context.l10n),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141414),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${_periodLabel()}${_scopeLabel()}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF666666),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BikeTrack extends StatelessWidget {
  const _BikeTrack({required this.offer});

  final ActiveOffer offer;

  List<_TrackStop> get _stops {
    if (offer.tiers.isNotEmpty) {
      final sorted = [...offer.tiers]
        ..sort((a, b) => a.threshold.compareTo(b.threshold));
      final filtered = sorted
          .where((tier) => tier.threshold > 0)
          .toList(growable: false);
      return filtered
          .asMap()
          .entries
          .map(
            (entry) => _TrackStop(
              threshold: entry.value.threshold,
              rewardKwd: entry.value.headlineRewardKwd > 0
                  ? entry.value.headlineRewardKwd
                  : offer.headlineRewardKwd,
              isLast: entry.key == filtered.length - 1,
            ),
          )
          .toList(growable: false);
    }
    if (offer.target <= 0) return const [];
    return [
      _TrackStop(
        threshold: offer.target,
        rewardKwd: offer.headlineRewardKwd,
        isLast: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final stops = _stops;
    if (stops.isEmpty) return const SizedBox.shrink();
    final multiTier = stops.length > 1;
    final maxThreshold = stops.isNotEmpty
        ? stops.last.threshold
        : (offer.target > 0 ? offer.target : 1);
    final current = offer.currentCount.clamp(0, maxThreshold);
    final fraction = maxThreshold > 0 ? (current / maxThreshold) : 0.0;
    final completed = offer.completed;

    final progressColor = completed
        ? AppColors.verifiedGreen
        : AppColors.tomatoOrange;
    final trackColor = const Color(0xFFEDEAF8);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            const bikeHeight = 80.0;
            const bikeWidth = bikeHeight * BikeMarker.aspectRatio;
            const dotSize = 10.0;
            final bikeLeft = (w * value - bikeWidth / 2).clamp(
              0.0,
              w - bikeWidth,
            );
            const barTop = 48.0;
            const rewardLabelTop = 22.0;
            const thresholdTop = 58.0;
            const totalHeight = 76.0;
            return SizedBox(
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: barTop,
                    width: w,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: trackColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: barTop,
                    width: (w * value).clamp(0.0, w),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor.withValues(alpha: 0.95),
                            progressColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  if (maxThreshold > 0 || current > 0)
                    Positioned(
                      left: bikeLeft,
                      top: barTop + 2 - bikeHeight / 2,
                      child: BikeMarker(
                        height: bikeHeight,
                        color: progressColor,
                      ),
                    ),
                  ...stops.expand((stop) {
                    final ratio = stop.threshold / maxThreshold;
                    final center = (w * ratio).clamp(0.0, w);
                    final dotLeft = (center - dotSize / 2).clamp(
                      0.0,
                      w - dotSize,
                    );
                    final tickLeft = (center - 10).clamp(0.0, w - 20);
                    final isTrailing = stop.isLast && !multiTier;
                    final rewardText = formatKwd(stop.rewardKwd);
                    return <Widget>[
                      if (isTrailing)
                        Positioned(
                          right: 0,
                          top: rewardLabelTop,
                          child: Text(
                            rewardText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.tomatoOrange,
                              letterSpacing: -0.2,
                            ),
                          ),
                        )
                      else if (multiTier)
                        Positioned(
                          left: 0,
                          top: rewardLabelTop,
                          width: w,
                          child: IgnorePointer(
                            child: Align(
                              alignment: Alignment((center / w) * 2 - 1, -1),
                              child: Text(
                                rewardText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.tomatoOrange,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: dotLeft,
                        top: barTop - 2,
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: const BoxDecoration(
                            color: Color(0xFF141414),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: tickLeft,
                        top: thresholdTop,
                        child: Text(
                          stop.threshold.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF141414),
                          ),
                        ),
                      ),
                    ];
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TrackStop {
  const _TrackStop({
    required this.threshold,
    required this.rewardKwd,
    required this.isLast,
  });

  final int threshold;
  final double rewardKwd;
  final bool isLast;
}

class _MultiplierChip extends StatelessWidget {
  const _MultiplierChip({
    required this.label,
    required this.active,
    required this.completed,
  });

  final String label;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final base = completed
        ? AppColors.verifiedGreen
        : (active ? AppColors.tomatoOrange : AppColors.blueberry);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: base.withValues(alpha: active || completed ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: base.withValues(alpha: active || completed ? 0.5 : 0.25),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.bolt_rounded : Icons.bolt_outlined,
            size: 12,
            color: base,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: base,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.verifiedGreen.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: AppColors.verifiedGreen,
          ),
          const SizedBox(width: 3),
          Text(
            l10n.completed,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.verifiedGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / loading states
// ---------------------------------------------------------------------------

class _QuestEmpty extends StatelessWidget {
  const _QuestEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _QuestShell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1DBFF), width: 0.7),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.tomatoOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🎁', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.noActiveQuestsRightNow,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF141414),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.tapToSeeAllOffers,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.blueberry),
          ],
        ),
      ),
    );
  }
}

class _QuestSkeleton extends StatelessWidget {
  const _QuestSkeleton();

  @override
  Widget build(BuildContext context) {
    return _QuestShell(
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
