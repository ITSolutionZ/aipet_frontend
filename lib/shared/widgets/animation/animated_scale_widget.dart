import 'package:flutter/material.dart';

/// 스케일 애니메이션 위젯
class AnimatedScaleWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool show;
  final double beginScale;
  final double endScale;
  final Alignment alignment;
  final VoidCallback? onAnimationComplete;

  const AnimatedScaleWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.elasticOut,
    this.show = true,
    this.beginScale = 0.0,
    this.endScale = 1.0,
    this.alignment = Alignment.center,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedScaleWidget> createState() => _AnimatedScaleWidgetState();
}

class _AnimatedScaleWidgetState extends State<AnimatedScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _initializeAnimations();

    _scaleAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    if (widget.show) {
      _startAnimation();
    }
  }

  void _initializeAnimations() {
    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didUpdateWidget(AnimatedScaleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.beginScale != oldWidget.beginScale ||
        widget.endScale != oldWidget.endScale) {
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: widget.alignment,
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 순차적 스케일 애니메이션 위젯
class StaggeredScaleWidget extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final bool show;
  final double beginScale;
  final double endScale;
  final Alignment alignment;

  const StaggeredScaleWidget({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = Curves.elasticOut,
    this.show = true,
    this.beginScale = 0.0,
    this.endScale = 1.0,
    this.alignment = Alignment.center,
  });

  @override
  State<StaggeredScaleWidget> createState() => _StaggeredScaleWidgetState();
}

class _StaggeredScaleWidgetState extends State<StaggeredScaleWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
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

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: widget.beginScale,
        end: widget.endScale,
      ).animate(CurvedAnimation(parent: controller, curve: widget.curve));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: widget.curve));
    }).toList();
  }

  @override
  void didUpdateWidget(StaggeredScaleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.children.length != oldWidget.children.length ||
        widget.beginScale != oldWidget.beginScale ||
        widget.endScale != oldWidget.endScale) {
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
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              alignment: widget.alignment,
              child: Opacity(
                opacity: _fadeAnimations[index].value.clamp(0.0, 1.0),
                child: widget.children[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 버튼 스케일 애니메이션 위젯
class AnimatedButtonWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final Curve curve;
  final double pressedScale;
  final bool enabled;

  const AnimatedButtonWidget({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeInOut,
    this.pressedScale = 0.95,
    this.enabled = true,
  });

  @override
  State<AnimatedButtonWidget> createState() => _AnimatedButtonWidgetState();
}

class _AnimatedButtonWidgetState extends State<AnimatedButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.5,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
