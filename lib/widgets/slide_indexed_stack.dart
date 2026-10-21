import 'package:flutter/material.dart';

/// Like [IndexedStack], but slides between pages while keeping every child
/// alive. Hidden pages are offstage, so finders and semantics ignore them.
class SlideIndexedStack extends StatefulWidget {
  const SlideIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 260),
  });
  final int index;
  final List<Widget> children;
  final Duration duration;

  @override
  State<SlideIndexedStack> createState() => _SlideIndexedStackState();
}

class _SlideIndexedStackState extends State<SlideIndexedStack>
    with SingleTickerProviderStateMixin {
  static const _distance = 0.12;
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final curve = CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  );
  late int current = widget.index;
  int? previous;
  int direction = 1;

  @override
  void didUpdateWidget(covariant SlideIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == current) return;
    direction = widget.index > current ? 1 : -1;
    previous = current;
    current = widget.index;
    controller.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => previous = null);
    });
  }

  @override
  void dispose() {
    curve.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final progress = controller.isAnimating ? curve.value : 1.0;
      return Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < widget.children.length; i++)
            _Layer(
              active: i == current,
              visible: i == current || i == previous,
              opacity: i == current
                  ? 0.9 + 0.1 * progress
                  : i == previous
                  ? 1 - 0.1 * progress
                  : 0,
              dx: i == current
                  ? direction * _distance * (1 - progress)
                  : i == previous
                  ? -direction * _distance * progress
                  : 0,
              child: widget.children[i],
            ),
        ],
      );
    },
  );
}

class _Layer extends StatelessWidget {
  const _Layer({
    required this.child,
    required this.active,
    required this.visible,
    required this.opacity,
    required this.dx,
  });
  final Widget child;
  final bool active, visible;
  final double opacity, dx;

  @override
  Widget build(BuildContext context) => Offstage(
    offstage: !visible,
    child: TickerMode(
      enabled: active,
      child: IgnorePointer(
        ignoring: !active,
        child: ExcludeSemantics(
          excluding: !active,
          child: FractionalTranslation(
            translation: Offset(dx, 0),
            child: Opacity(opacity: opacity, child: child),
          ),
        ),
      ),
    ),
  );
}
