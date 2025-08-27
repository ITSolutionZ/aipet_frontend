import 'package:flutter/material.dart';

/// 슬라이드 방향
enum SlideDirection { fromLeft, fromRight, fromTop, fromBottom }

/// 슬라이드 애니메이션 위젯
class AnimatedSlideWidget extends StatefulWidget {
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
  State<AnimatedSlideWidget> createState() => _AnimatedSlideWidgetState();
}

class _AnimatedSlideWidgetState extends State<AnimatedSlideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _initializeAnimations();

    _slideAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    if (widget.show) {
      _startAnimation();
    }
  }

  void _initializeAnimations() {
    final beginOffset = _getBeginOffset();

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
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
  void didUpdateWidget(AnimatedSlideWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.direction != oldWidget.direction ||
        widget.slideDistance != oldWidget.slideDistance) {
      _initializeAnimations();
    }

    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _startAnimation();
      } else {
        _controller.reverse();
      }
    }
  }

  void _startAnimation() {
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * widget.slideDistance,
          child: Opacity(opacity: _fadeAnimation.value, child: widget.child),
        );
      },
    );
  }
}

/// 순차적 슬라이드 애니메이션 위젯
class StaggeredSlideWidget extends StatefulWidget {
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
  State<StaggeredSlideWidget> createState() => _StaggeredSlideWidgetState();
}

class _StaggeredSlideWidgetState extends State<StaggeredSlideWidget>
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
              child: Opacity(
                opacity: _fadeAnimations[index].value,
                child: widget.children[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
