import 'package:aipet_frontend/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:aipet_frontend/features/onboarding/domain/onboarding_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingData', () {
    test('should have correct number of pages', () {
      // Assert
      expect(OnboardingData.pages, hasLength(4));
    });

    test('should have valid page data', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      for (int i = 0; i < pages.length; i++) {
        final page = pages[i];
        expect(page.imagePath, isNotEmpty);
        expect(page.title, isNotEmpty);
        expect(page.subtitle, isNotEmpty);
        expect(page.description, isNotEmpty);
        expect(page.imageAlignment, isA<Alignment>());
        expect(page.imageFit, isA<BoxFit>());
        expect(page.useCustomImageDisplay, isA<bool>());
      }
    });

    test('should have correct first page data', () {
      // Act
      final firstPage = OnboardingData.pages[0];

      // Assert
      expect(
        firstPage.imagePath,
        equals('assets/images/onboarding/onboarding1.png'),
      );
      expect(firstPage.title, equals('Welcome'));
      expect(firstPage.subtitle, equals('毎日の記録、愛に繋ぐ'));
      expect(firstPage.description, equals('記録から残る愛の痕跡'));
      expect(firstPage.imageAlignment, equals(Alignment.bottomCenter));
      expect(firstPage.imageFit, equals(BoxFit.cover));
      expect(firstPage.useCustomImageDisplay, isTrue);
    });

    test('should have correct second page data', () {
      // Act
      final secondPage = OnboardingData.pages[1];

      // Assert
      expect(
        secondPage.imagePath,
        equals('assets/images/onboarding/onboarding2.png'),
      );
      expect(secondPage.title, equals('Together'));
      expect(secondPage.subtitle, equals('笑顔溢れる散歩時間\n一緒なら楽しい思い出'));
      expect(secondPage.description, equals('朝も夜もいつでも楽しい\nあなたと一緒なら空も綺麗'));
      expect(secondPage.imageAlignment, equals(Alignment.topCenter));
      expect(secondPage.imageFit, equals(BoxFit.cover));
      expect(secondPage.useCustomImageDisplay, isTrue);
    });

    test('should have correct third page data', () {
      // Act
      final thirdPage = OnboardingData.pages[2];

      // Assert
      expect(
        thirdPage.imagePath,
        equals('assets/images/onboarding/onboarding3.png'),
      );
      expect(thirdPage.title, equals('Intelligent'));
      expect(thirdPage.subtitle, equals('賢い体調管理の始まり'));
      expect(thirdPage.description, equals('状況によるアドバイスで\n賢い健康管理'));
      expect(thirdPage.imageAlignment, equals(Alignment.center));
      expect(thirdPage.imageFit, equals(BoxFit.cover));
      expect(thirdPage.useCustomImageDisplay, isTrue);
    });

    test('should have correct fourth page data', () {
      // Act
      final fourthPage = OnboardingData.pages[3];

      // Assert
      expect(
        fourthPage.imagePath,
        equals('assets/images/onboarding/onboarding4.png'),
      );
      expect(fourthPage.title, equals('Reservations'));
      expect(fourthPage.subtitle, equals('アプリ一つで簡単に\nトリミングから病院まで'));
      expect(fourthPage.description, equals('幅広い予約完了\nアプリだけで登録なしで素早く'));
      expect(fourthPage.imageAlignment, equals(Alignment.center));
      expect(fourthPage.imageFit, equals(BoxFit.cover));
      expect(fourthPage.useCustomImageDisplay, isTrue);
    });

    test('should have unique titles', () {
      // Act
      const pages = OnboardingData.pages;
      final titles = pages.map((page) => page.title).toList();

      // Assert
      expect(
        titles.toSet(),
        hasLength(titles.length),
      ); // All titles should be unique
    });

    test('should have unique image paths', () {
      // Act
      const pages = OnboardingData.pages;
      final imagePaths = pages.map((page) => page.imagePath).toList();

      // Assert
      expect(
        imagePaths.toSet(),
        hasLength(imagePaths.length),
      ); // All image paths should be unique
    });

    test('should have valid image paths format', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      for (final page in pages) {
        expect(page.imagePath, startsWith('assets/images/onboarding/'));
        expect(page.imagePath, endsWith('.png'));
      }
    });

    test('should have valid alignment values', () {
      // Act
      const pages = OnboardingData.pages;
      final alignments = pages.map((page) => page.imageAlignment).toList();

      // Assert
      final validAlignments = [
        Alignment.bottomCenter,
        Alignment.topCenter,
        Alignment.center,
      ];

      for (final alignment in alignments) {
        expect(validAlignments, contains(alignment));
      }
    });

    test('should have valid BoxFit values', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      for (final page in pages) {
        expect(page.imageFit, equals(BoxFit.cover));
      }
    });

    test('should have useCustomImageDisplay set to true for all pages', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      for (final page in pages) {
        expect(page.useCustomImageDisplay, isTrue);
      }
    });

    test('should have non-empty text content', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      for (final page in pages) {
        expect(page.title.trim(), isNotEmpty);
        expect(page.subtitle.trim(), isNotEmpty);
        expect(page.description.trim(), isNotEmpty);
      }
    });

    test('should have Japanese text content', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      for (final page in pages) {
        // Check if text contains Japanese characters (Hiragana, Katakana, or Kanji)
        final hasJapanese = RegExp(
          r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]',
        ).hasMatch(page.subtitle + page.description);
        expect(hasJapanese, isTrue);
      }
    });

    test('should have consistent data structure', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      for (final page in pages) {
        // All pages should have the same structure
        expect(page.imagePath, isA<String>());
        expect(page.title, isA<String>());
        expect(page.subtitle, isA<String>());
        expect(page.description, isA<String>());
        expect(page.imageAlignment, isA<Alignment>());
        expect(page.imageFit, isA<BoxFit>());
        expect(page.useCustomImageDisplay, isA<bool>());
      }
    });

    test('should be immutable', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      expect(pages, isA<List<OnboardingPage>>());
      // The list should be const, so it's immutable
      expect(pages, isA<List>());
    });

    test('should have proper line breaks in text', () {
      // Act
      const pages = OnboardingData.pages;

      // Assert
      // Check that pages with multi-line text have proper line breaks
      final secondPage = pages[1];
      expect(secondPage.subtitle, contains('\n'));
      expect(secondPage.description, contains('\n'));

      final thirdPage = pages[2];
      expect(thirdPage.description, contains('\n'));

      final fourthPage = pages[3];
      expect(fourthPage.subtitle, contains('\n'));
      expect(fourthPage.description, contains('\n'));
    });
  });
}
