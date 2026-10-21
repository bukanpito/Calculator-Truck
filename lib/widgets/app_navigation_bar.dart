import 'package:flutter/material.dart';

class NavItem {
  const NavItem({
    required this.id,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final String id;
  final IconData icon, selectedIcon;
  final String label;
}

/// Static bottom navigation: selection changes instantly, no animation.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });
  final int index;
  final ValueChanged<int> onChanged;
  final List<NavItem> items;

  static const _active = Color(0xFF00412E);
  static const _inactive = Color(0xFF5F6F67);
  static const _pill = Color(0xFF84A879);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 8,
    shadowColor: const Color(0x6600412E),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 66,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth / items.length;
            final pillWidth = (width - 28).clamp(52.0, 64.0);
            return Stack(
              children: [
                Positioned(
                  left: width * index + (width - pillWidth) / 2,
                  top: 4,
                  width: pillWidth,
                  height: 38,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: _pill,
                      borderRadius: BorderRadius.all(Radius.circular(19)),
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
  final NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 38,
          child: Center(
            child: Icon(
              selected ? item.selectedIcon : item.icon,
              size: 21,
              color: selected
                  ? AppNavigationBar._active
                  : AppNavigationBar._inactive,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            height: 1.2,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? AppNavigationBar._active
                : AppNavigationBar._inactive,
          ),
        ),
      ],
    ),
  );
}
