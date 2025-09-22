import 'package:aipet_frontend/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingPage', () {
    test('should create page with required parameters', () {
      // Act
      const page = OnboardingPage(
        imagePath: 'assets/images/test.png',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
      );

      // Assert
      expect(page.imagePath, equals('assets/images/test.png'));
      expect(page.title, equals('Test Title'));
      expect(page.subtitle, equals('Test Subtitle'));
      expect(page.description, equals('Test Description'));
      expect(page.imageAlignment, equals(Alignment.center));
      expect(page.imageFit, equals(BoxFit.cover));
      expect(page.useCustomImageDisplay, isFalse);
    });

    test('should create page with all parameters', () {
      // Act
      const page = OnboardingPage(
        imagePath: 'assets/images/test.png',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
        imageAlignment: Alignment.topLeft,
        imageFit: BoxFit.contain,
        useCustomImageDisplay: true,
      );

      // Assert
      expect(page.imagePath, equals('assets/images/test.png'));
      expect(page.title, equals('Test Title'));
      expect(page.subtitle, equals('Test Subtitle'));
      expect(page.description, equals('Test Description'));
      expect(page.imageAlignment, equals(Alignment.topLeft));
      expect(page.imageFit, equals(BoxFit.contain));
      expect(page.useCustomImageDisplay, isTrue);
    });

    test('should handle different image alignments', () {
      // Test various alignments
      const alignments = [
        Alignment.topLeft,
        Alignment.topCenter,
        Alignment.topRight,
        Alignment.centerLeft,
        Alignment.center,
        Alignment.centerRight,
        Alignment.bottomLeft,
        Alignment.bottomCenter,
        Alignment.bottomRight,
      ];

      for (final alignment in alignments) {
        // Act
        final page = OnboardingPage(
          imagePath: 'test.png',
          title: 'Test',
          subtitle: 'Test',
          description: 'Test',
          imageAlignment: alignment,
        );

        // Assert
        expect(page.imageAlignment, equals(alignment));
      }
    });

    test('should handle different image fits', () {
      // Test various BoxFit values
      const fits = [
        BoxFit.contain,
        BoxFit.cover,
        BoxFit.fill,
        BoxFit.fitHeight,
        BoxFit.fitWidth,
        BoxFit.none,
        BoxFit.scaleDown,
      ];

      for (final fit in fits) {
        // Act
        final page = OnboardingPage(
          imagePath: 'test.png',
          title: 'Test',
          subtitle: 'Test',
          description: 'Test',
          imageFit: fit,
        );

        // Assert
        expect(page.imageFit, equals(fit));
      }
    });

    test('equality should work correctly', () {
      // Arrange
      const page1 = OnboardingPage(
        imagePath: 'assets/images/test.png',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
        imageAlignment: Alignment.center,
        imageFit: BoxFit.cover,
        useCustomImageDisplay: false,
      );
      const page2 = OnboardingPage(
        imagePath: 'assets/images/test.png',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
        imageAlignment: Alignment.center,
        imageFit: BoxFit.cover,
        useCustomImageDisplay: false,
      );
      const page3 = OnboardingPage(
        imagePath: 'assets/images/different.png',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
        imageAlignment: Alignment.center,
        imageFit: BoxFit.cover,
        useCustomImageDisplay: false,
      );

      // Assert
      expect(page1, equals(page2));
      expect(page1, isNot(equals(page3)));
      expect(page1.hashCode, equals(page2.hashCode));
      expect(page1.hashCode, isNot(equals(page3.hashCode)));
    });

    test('should handle different field differences in equality', () {
      // Arrange
      const basePage = OnboardingPage(
        imagePath: 'assets/images/test.png',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
        imageAlignment: Alignment.center,
        imageFit: BoxFit.cover,
        useCustomImageDisplay: false,
      );

      // Test different imagePath
      final differentImagePath = basePage.copyWith(imagePath: 'different.png');
      expect(basePage, isNot(equals(differentImagePath)));

      // Test different title
      final differentTitle = basePage.copyWith(title: 'Different Title');
      expect(basePage, isNot(equals(differentTitle)));

      // Test different subtitle
      final differentSubtitle = basePage.copyWith(
        subtitle: 'Different Subtitle',
      );
      expect(basePage, isNot(equals(differentSubtitle)));

      // Test different description
      final differentDescription = basePage.copyWith(
        description: 'Different Description',
      );
      expect(basePage, isNot(equals(differentDescription)));

      // Test different imageAlignment
      final differentAlignment = basePage.copyWith(
        imageAlignment: Alignment.topLeft,
      );
      expect(basePage, isNot(equals(differentAlignment)));

      // Test different imageFit
      final differentFit = basePage.copyWith(imageFit: BoxFit.contain);
      expect(basePage, isNot(equals(differentFit)));

      // Test different useCustomImageDisplay
      final differentCustomDisplay = basePage.copyWith(
        useCustomImageDisplay: true,
      );
      expect(basePage, isNot(equals(differentCustomDisplay)));
    });

    test('toString should include imagePath and title', () {
      // Arrange
      const page = OnboardingPage(
        imagePath: 'assets/images/test.png',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
      );

      // Act
      final string = page.toString();

      // Assert
      expect(string, contains('OnboardingPage'));
      expect(string, contains('assets/images/test.png'));
      expect(string, contains('Test Title'));
    });

    test('should handle empty strings', () {
      // Act
      const page = OnboardingPage(
        imagePath: '',
        title: '',
        subtitle: '',
        description: '',
      );

      // Assert
      expect(page.imagePath, equals(''));
      expect(page.title, equals(''));
      expect(page.subtitle, equals(''));
      expect(page.description, equals(''));
    });

    test('should handle long strings', () {
      // Arrange
      const longString =
          'This is a very long string that might be used for testing purposes to ensure that the OnboardingPage entity can handle long text content without any issues.';

      // Act
      const page = OnboardingPage(
        imagePath: longString,
        title: longString,
        subtitle: longString,
        description: longString,
      );

      // Assert
      expect(page.imagePath, equals(longString));
      expect(page.title, equals(longString));
      expect(page.subtitle, equals(longString));
      expect(page.description, equals(longString));
    });

    test('should handle special characters', () {
      // Arrange
      const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

      // Act
      const page = OnboardingPage(
        imagePath: specialChars,
        title: specialChars,
        subtitle: specialChars,
        description: specialChars,
      );

      // Assert
      expect(page.imagePath, equals(specialChars));
      expect(page.title, equals(specialChars));
      expect(page.subtitle, equals(specialChars));
      expect(page.description, equals(specialChars));
    });

    test('should handle unicode characters', () {
      // Arrange
      const unicodeString = 'こんにちは世界！🎉🚀';

      // Act
      const page = OnboardingPage(
        imagePath: unicodeString,
        title: unicodeString,
        subtitle: unicodeString,
        description: unicodeString,
      );

      // Assert
      expect(page.imagePath, equals(unicodeString));
      expect(page.title, equals(unicodeString));
      expect(page.subtitle, equals(unicodeString));
      expect(page.description, equals(unicodeString));
    });
  });
}

// Extension to add copyWith method for testing
extension OnboardingPageCopyWith on OnboardingPage {
  OnboardingPage copyWith({
    String? imagePath,
    String? title,
    String? subtitle,
    String? description,
    Alignment? imageAlignment,
    BoxFit? imageFit,
    bool? useCustomImageDisplay,
  }) {
    return OnboardingPage(
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageAlignment: imageAlignment ?? this.imageAlignment,
      imageFit: imageFit ?? this.imageFit,
      useCustomImageDisplay:
          useCustomImageDisplay ?? this.useCustomImageDisplay,
    );
  }
}
