import 'package:flutter/material.dart';

class SmoothNavItem {
  const SmoothNavItem({
    required this.id,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final String id;
  final IconData icon, selectedIcon;
  final String label;
}

/// Bottom navigation with a sliding pill. Page changes stay instant; only
/// this bar animates.
class SmoothNavigationBar extends StatelessWidget {
  const SmoothNavigationBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });
  final int index;
  final ValueChanged<int> onChanged;
  final List<SmoothNavItem> items;

  static const _active = Color(0xFF00412E);
  static const _inactive = Color(0xFF5F6F67);
  static const _pill = Color(0xFF96BF8A);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 8,
    shadowColor: const Color(0x6600412E),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth / items.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: width * index + 16,
                  top: 6,
                  width: width - 32,
                  height: 30,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: _pill,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final (i, item) in items.indexed)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == index,
                          label: item.label,
                          child: InkWell(
                            key: ValueKey('nav_${item.id}'),
                            onTap: () => onChanged(i),
                            child: _Item(item: item, selected: i == index),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.selected});
  final SmoothNavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: selected ? 1 : 0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, t, _) => Icon(
            selected ? item.selectedIcon : item.icon,
            size: 21 + t * 2,
            color: Color.lerp(
              SmoothNavigationBar._inactive,
              SmoothNavigationBar._active,
              t,
            ),
          ),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          style: TextStyle(
            fontSize: 11,
            height: 1.2,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? SmoothNavigationBar._active
                : SmoothNavigationBar._inactive,
          ),
          child: Text(item.label),
        ),
      ],
    ),
  );
}
