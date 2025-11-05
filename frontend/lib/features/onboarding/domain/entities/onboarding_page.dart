import 'package:flutter/material.dart';

/// 온보딩 페이지 엔티티
class OnboardingPage {
  final String imagePath;
  final String title;
  final String subtitle;
  final String description;
  final Alignment imageAlignment;
  final BoxFit imageFit;
  final bool useCustomImageDisplay;

  const OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.description,
    this.imageAlignment = Alignment.center,
    this.imageFit = BoxFit.cover,
    this.useCustomImageDisplay = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingPage &&
        other.imagePath == imagePath &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.description == description &&
        other.imageAlignment == imageAlignment &&
        other.imageFit == imageFit &&
        other.useCustomImageDisplay == useCustomImageDisplay;
  }

  @override
  int get hashCode =>
      imagePath.hashCode ^
      title.hashCode ^
      subtitle.hashCode ^
      description.hashCode ^
      imageAlignment.hashCode ^
      imageFit.hashCode ^
      useCustomImageDisplay.hashCode;

  @override
  String toString() {
    return 'OnboardingPage(imagePath: $imagePath, title: $title)';
  }
}
