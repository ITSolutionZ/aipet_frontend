import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animated_slide_widget.g.dart';

/// 슬라이드 방향
enum SlideDirection { fromLeft, fromRight, fromTop, fromBottom }

/// 🎯 Animated Slide State Provider
@riverpod
class AnimatedSlideController extends _$AnimatedSlideController {
  @override
  AnimatedSlideState build(String animationId) => const AnimatedSlideState();

  void initializeController(TickerProvider vsync, Duration duration) {
    final controller = AnimationController(duration: duration, vsync: vsync);
    state = state.copyWith(controller: controller);
  }

  void updateAnimations(SlideDirection direction, double slideDistance, Curve curve) {
    if (state.controller == null) return;

    final beginOffset = _getBeginOffset(direction, slideDistance);

    final slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: state.controller!, curve: curve));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: state.controller!, curve: curve));

    state = state.copyWith(slideAnimation: slideAnimation, fadeAnimation: fadeAnimation);
  }

  Offset _getBeginOffset(SlideDirection direction, double distance) {
    switch (direction) {
      case SlideDirection.fromLeft:
        return Offset(-distance, 0.0);
      case SlideDirection.fromRight:
        return Offset(distance, 0.0);
      case SlideDirection.fromTop:
        return Offset(0.0, -distance);
      case SlideDirection.fromBottom:
        return Offset(0.0, distance);
    }
  }

  void startAnimation(Duration delay) {
    if (state.controller == null) return;

    Future.delayed(delay, () {
      state.controller?.forward();
    });
  }

  void reverseAnimation() {
    state.controller?.reverse();
  }
}

class AnimatedSlideState {
  final AnimationController? controller;
  final Animation<Offset>? slideAnimation;
  final Animation<double>? fadeAnimation;

  const AnimatedSlideState({this.controller, this.slideAnimation, this.fadeAnimation});

  AnimatedSlideState copyWith({
    AnimationController? controller,
    Animation<Offset>? slideAnimation,
    Animation<double>? fadeAnimation,
  }) {
    return AnimatedSlideState(
      controller: controller ?? this.controller,
      slideAnimation: slideAnimation ?? this.slideAnimation,
      fadeAnimation: fadeAnimation ?? this.fadeAnimation,
    );
  }
}

/// 슬라이드 애니메이션 위젯
class AnimatedSlideWidget extends ConsumerStatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool show;
  final double slideDistance;
  final VoidCallback? onAnimationComplete;

  const AnimatedSlideWidget({
    super.key,
    required this.child,
    this.direction = SlideDirection.fromBottom,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.show = true,
    this.slideDistance = 50.0,
    this.onAnimationComplete,
  });

  @override
  ConsumerState<AnimatedSlideWidget> createState() => _AnimatedSlideWidgetState();
}

class _AnimatedSlideWidgetState extends ConsumerState<AnimatedSlideWidget>
    with SingleTickerProviderStateMixin {
  final String _animationId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();

    // Initialize Riverpod controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(animatedSlideControllerProvider(_animationId).notifier)
          .initializeController(this, widget.duration);
      ref
          .read(animatedSlideControllerProvider(_animationId).notifier)
          .updateAnimations(widget.direction, widget.slideDistance, widget.curve);

      // Add status listener
      final state = ref.read(animatedSlideControllerProvider(_animationId));
      state.slideAnimation?.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onAnimationComplete?.call();
        }
      });

      if (widget.show) {
        ref.read(animatedSlideControllerProvider(_animationId).notifier).startAnimation(widget.delay);
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedSlideWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.direction != oldWidget.direction ||
        widget.slideDistance != oldWidget.slideDistance) {
      ref
          .read(animatedSlideControllerProvider(_animationId).notifier)
          .updateAnimations(widget.direction, widget.slideDistance, widget.curve);
    }

    if (widget.show != oldWidget.show) {
      if (widget.show) {
        ref.read(animatedSlideControllerProvider(_animationId).notifier).startAnimation(widget.delay);
      } else {
        ref.read(animatedSlideControllerProvider(_animationId).notifier).reverseAnimation();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationState = ref.watch(animatedSlideControllerProvider(_animationId));

    if (animationState.controller == null ||
        animationState.slideAnimation == null ||
        animationState.fadeAnimation == null) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: animationState.controller!,
      builder: (context, child) {
        return Transform.translate(
          offset: animationState.slideAnimation!.value * widget.slideDistance,
          child: Opacity(opacity: animationState.fadeAnimation!.value, child: widget.child),
        );
      },
    );
  }
}

/// 🎯 Staggered Slide State Provider
@riverpod
class StaggeredSlideController extends _$StaggeredSlideController {
  @override
  StaggeredSlideState build(String staggeredId) => const StaggeredSlideState();

  void initializeControllers(TickerProvider vsync, int childrenCount, Duration duration) {
    final controllers = List.generate(
      childrenCount,
      (index) => AnimationController(duration: duration, vsync: vsync),
    );
    state = state.copyWith(controllers: controllers);
  }
}

class StaggeredSlideState {
  final List<AnimationController> controllers;

  const StaggeredSlideState({this.controllers = const []});

  StaggeredSlideState copyWith({List<AnimationController>? controllers}) {
    return StaggeredSlideState(controllers: controllers ?? this.controllers);
  }
}

/// 순차적 슬라이드 애니메이션 위젯
class StaggeredSlideWidget extends ConsumerStatefulWidget {
  final List<Widget> children;
  final SlideDirection direction;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final bool show;
  final double slideDistance;

  const StaggeredSlideWidget({
    super.key,
    required this.children,
    this.direction = SlideDirection.fromBottom,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
    this.show = true,
    this.slideDistance = 50.0,
  });

  @override
  ConsumerState<StaggeredSlideWidget> createState() => _StaggeredSlideWidgetState();
}

class _StaggeredSlideWidgetState extends ConsumerState<StaggeredSlideWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    if (widget.show) {
      _startStaggeredAnimation();
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    final beginOffset = _getBeginOffset();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: widget.curve));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: widget.curve));
    }).toList();
  }

  Offset _getBeginOffset() {
    final distance = widget.slideDistance;
    switch (widget.direction) {
      case SlideDirection.fromLeft:
        return Offset(-distance, 0.0);
      case SlideDirection.fromRight:
        return Offset(distance, 0.0);
      case SlideDirection.fromTop:
        return Offset(0.0, -distance);
      case SlideDirection.fromBottom:
        return Offset(0.0, distance);
    }
  }

  @override
  void didUpdateWidget(StaggeredSlideWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.children.length != oldWidget.children.length ||
        widget.direction != oldWidget.direction ||
        widget.slideDistance != oldWidget.slideDistance) {
      _disposeControllers();
      _initializeAnimations();
    }

    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _startStaggeredAnimation();
      } else {
        _reverseAnimations();
      }
    }
  }

  void _startStaggeredAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted && i < _controllers.length) {
          _controllers[i].forward();
        }
      });
    }
  }

  void _reverseAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].reverse();
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) => AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: _slideAnimations[index].value * widget.slideDistance,
              child: Opacity(opacity: _fadeAnimations[index].value, child: widget.children[index]),
            );
          },
        ),
      ),
    );
  }
}
