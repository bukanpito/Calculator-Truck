import 'package:flutter/material.dart';

/// Like [IndexedStack], but cross-fades between pages while keeping every
/// child alive. Hidden pages are offstage, so finders and semantics ignore
/// them.
class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 220),
  });
  final int index;
  final List<Widget> children;
  final Duration duration;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late int current = widget.index;
  int? previous;

  @override
  void didUpdateWidget(covariant FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == current) return;
    previous = current;
    current = widget.index;
    controller.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => previous = null);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _Layer(
            active: i == current,
            visible: i == current || i == previous,
            opacity: i == current
                ? (controller.isAnimating ? controller.value : 1)
                : i == previous
                ? 1 - controller.value
                : 0,
            child: widget.children[i],
          ),
      ],
    ),
  );
}

class _Layer extends StatelessWidget {
  const _Layer({
    required this.child,
    required this.active,
    required this.visible,
    required this.opacity,
  });
  final Widget child;
  final bool active, visible;
  final double opacity;

  @override
  Widget build(BuildContext context) => Offstage(
    offstage: !visible,
    child: TickerMode(
      enabled: active,
      child: IgnorePointer(
        ignoring: !active,
        child: ExcludeSemantics(
          excluding: !active,
          child: Opacity(opacity: opacity, child: child),
        ),
      ),
    ),
  );
}
