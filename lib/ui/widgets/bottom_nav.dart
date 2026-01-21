import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final VoidCallback? onDashboardRefresh;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    this.onDashboardRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.menu,
                label: 'Menu',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.bar_chart,
                label: 'Estatísticas',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.person,
                label: 'Conta',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        if (index == 1 && onDashboardRefresh != null) {
          onDashboardRefresh!();
        }
        onTabChanged(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withAlpha((0.6 * 255).round()),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
