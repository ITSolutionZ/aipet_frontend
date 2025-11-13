import 'dart:async';

import 'package:flutter/material.dart';

/// 자동 슬라이드 배너 카루셀 위젯
class AutoBannerCarousel extends StatefulWidget {
  final List<String> bannerImages;
  final Duration autoSlideInterval;
  final Duration animationDuration;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final void Function(int index)? onTap;

  const AutoBannerCarousel({
    super.key,
    required this.bannerImages,
    this.autoSlideInterval = const Duration(seconds: 4),
    this.animationDuration = const Duration(milliseconds: 300),
    this.height,
    this.borderRadius = 12.0,
    this.fit = BoxFit.cover,
    this.onTap,
  });

  @override
  State<AutoBannerCarousel> createState() => _AutoBannerCarouselState();
}

class _AutoBannerCarouselState extends State<AutoBannerCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentIndex = 0;
  late int _totalItems;

  @override
  void initState() {
    super.initState();
    _totalItems = widget.bannerImages.length;
    // 무한 루프를 위해 중간부터 시작
    final initialPage = _totalItems > 1 ? _totalItems * 1000 : 0;
    _pageController = PageController(initialPage: initialPage);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    if (_totalItems <= 1) return;

    _autoSlideTimer = Timer.periodic(widget.autoSlideInterval, (timer) {
      if (!mounted || !_pageController.hasClients) return;

      final currentPage = _pageController.page?.round() ?? 0;
      _pageController.animateToPage(
        currentPage + 1,
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  void _resumeAutoSlide() {
    _stopAutoSlide();
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bannerImages.isEmpty) {
      return const SizedBox.shrink();
    }

    // 이미지 크기에 맞는 높이 계산
    final screenWidth = MediaQuery.of(context).size.width;

    return Listener(
      onPointerDown: (_) => _stopAutoSlide(),
      onPointerUp: (_) => _resumeAutoSlide(),
      onPointerCancel: (_) => _resumeAutoSlide(),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              // 배너 이미지들
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index % _totalItems;
                  });
                },
                itemCount: _totalItems > 1
                    ? null
                    : _totalItems, // 무한 루프를 위해 null 사용
                itemBuilder: (context, index) {
                  final actualIndex = index % _totalItems;
                  return GestureDetector(
                    onTap: () => widget.onTap?.call(actualIndex),
                    child: _buildOptimizedImage(actualIndex, screenWidth),
                  );
                },
              ),

              // 인디케이터 (배너가 2개 이상일 때만 표시)
              if (_totalItems > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _totalItems,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentIndex == index ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 최적화된 이미지 빌드
  Widget _buildOptimizedImage(int actualIndex, double screenWidth) {
    return Image.asset(
      widget.bannerImages[actualIndex],
      width: double.infinity,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: (screenWidth * 2).round(), // 해상도 향상
      cacheHeight: widget.height != null ? (widget.height! * 2).round() : null,
      filterQuality: FilterQuality.medium, // 품질 향상
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: widget.height,
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Image Load Failed\nIndex: $actualIndex',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null) {
          return Container(
            width: double.infinity,
            height: widget.height,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return child;
      },
    );
  }
}
