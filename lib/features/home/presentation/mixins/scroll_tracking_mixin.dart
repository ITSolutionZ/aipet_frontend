import 'package:flutter/material.dart';

/// 스크롤 추적 기능을 제공하는 Mixin
mixin ScrollTrackingMixin<T extends StatefulWidget> on State<T> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  ScrollController get scrollController => _scrollController;
  double get scrollOffset => _scrollOffset;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }
}
