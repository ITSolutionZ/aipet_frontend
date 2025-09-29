import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 AI Typing Indicator Animation State Provider
final aiTypingIndicatorProvider =
    StateNotifierProvider<AiTypingIndicatorController, bool>(
      (ref) => AiTypingIndicatorController(),
    );

class AiTypingIndicatorController extends StateNotifier<bool> {
  AiTypingIndicatorController() : super(false);

  void startAnimation() {
    state = true;
  }

  void stopAnimation() {
    state = false;
  }
}

/// AI 타이핑 인디케이터 위젯
class AiTypingIndicator extends ConsumerStatefulWidget {
  const AiTypingIndicator({super.key});

  @override
  ConsumerState<AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends ConsumerState<AiTypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 200)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Riverpod 상태 변경 시 애니메이션 시작/종료
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiTypingIndicatorProvider.notifier).startAnimation();
      _startAnimations();
    });
  }

  void _startAnimations() {
    // 애니메이션 시작 - 각각 다른 시간에 시작
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.pointBrown,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/logo_notinclude_text.png',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                AppRadius.medium,
              ).copyWith(bottomLeft: Radius.zero),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.pointBrown.withValues(
              alpha: _animations[index].value,
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
