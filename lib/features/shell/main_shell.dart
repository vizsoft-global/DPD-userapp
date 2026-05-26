import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/offline_banner.dart';
import '../auth/rider_auth_service.dart';
import '../deliveries/delivery_proximity_preview.dart';
import '../deliveries/delivery_proximity_service.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deliveryProximityContextProvider);
      ref.read(deliveryProximityPreviewProvider.notifier).warmUp();
      // Warm profile in the background so the Profile tab opens instantly.
      ref.read(riderProfileProvider.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      _TabItem(
        label: l10n.tabHome,
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      _TabItem(
        label: l10n.tabDeliveries,
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
      ),
      _TabItem(
        label: l10n.tabEarnings,
        icon: Icons.payments_outlined,
        activeIcon: Icons.payments,
      ),
      _TabItem(
        label: l10n.tabVehicle,
        icon: Icons.two_wheeler_outlined,
        activeIcon: Icons.two_wheeler,
      ),
      _TabItem(
        label: l10n.tabProfile,
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];
    return Scaffold(
      // `navigationShell` is itself an IndexedStack of the active branches —
      // letting it render the body preserves per-tab navigation state and
      // sub-route history.
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: widget.navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (i) => widget.navigationShell.goBranch(
          i,
          initialLocation: i == widget.navigationShell.currentIndex,
        ),
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.accentOrange.withValues(alpha: 0.15),
        destinations: [
          for (var i = 0; i < tabs.length; i++)
            NavigationDestination(
              icon: Icon(tabs[i].icon, color: AppColors.textPrimary),
              selectedIcon: Icon(
                tabs[i].activeIcon,
                color: AppColors.accentOrange,
              ),
              label: tabs[i].label,
            ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
