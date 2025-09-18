import 'package:aipet_frontend/shared/design/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    group('Point Colors', () {
      test('should have correct point colors', () {
        // Assert
        expect(AppColors.pointGreen, equals(const Color(0xFF899F6A)));
        expect(AppColors.pointBlue, equals(const Color(0xFF7391C7)));
        expect(AppColors.pointPink, equals(const Color(0xFFD19C97)));
        expect(AppColors.pointBrown, equals(const Color(0xFFA47764)));
        expect(AppColors.pointGray, equals(const Color(0xFFA89A8F)));
        expect(AppColors.pointOlive, equals(const Color(0xFF9A8B4E)));
        expect(AppColors.pointOffWhite, equals(const Color(0xFFF0E9E0)));
        expect(AppColors.pointDark, equals(const Color(0xFF44433C)));
        expect(AppColors.pointCream, equals(const Color(0xFFF7F0E8)));
        expect(AppColors.pureWhite, equals(const Color(0xFFFFFFFF)));
      });

      test('should have valid color values', () {
        // Assert
        expect(AppColors.pointGreen.value, isA<int>());
        expect(AppColors.pointBlue.value, isA<int>());
        expect(AppColors.pointPink.value, isA<int>());
        expect(AppColors.pointBrown.value, isA<int>());
        expect(AppColors.pointGray.value, isA<int>());
        expect(AppColors.pointOlive.value, isA<int>());
        expect(AppColors.pointOffWhite.value, isA<int>());
        expect(AppColors.pointDark.value, isA<int>());
        expect(AppColors.pointCream.value, isA<int>());
        expect(AppColors.pureWhite.value, isA<int>());
      });

      test('should have different color values', () {
        // Assert
        expect(AppColors.pointGreen, isNot(equals(AppColors.pointBlue)));
        expect(AppColors.pointPink, isNot(equals(AppColors.pointBrown)));
        expect(AppColors.pointGray, isNot(equals(AppColors.pointOlive)));
        expect(AppColors.pointOffWhite, isNot(equals(AppColors.pointDark)));
        expect(AppColors.pointCream, isNot(equals(AppColors.pureWhite)));
      });
    });

    group('Tone and Manner Colors', () {
      test('should have correct tone colors', () {
        // Assert
        expect(AppColors.toneOffWhite, equals(const Color(0xFFF0F0E5)));
        expect(AppColors.tonePeach, equals(const Color(0xFFE4C7B8)));
        expect(AppColors.toneBeige, equals(const Color(0xFFBBAA92)));
        expect(AppColors.toneSand, equals(const Color(0xFFC39E88)));
        expect(AppColors.toneBrown, equals(const Color(0xFFA47764)));
        expect(AppColors.toneTaupe, equals(const Color(0xFFA28777)));
        expect(AppColors.toneRoseBrown, equals(const Color(0xFF8B645A)));
        expect(AppColors.toneDarkBrown, equals(const Color(0xFF56453F)));
        expect(AppColors.toneDeepOlive, equals(const Color(0xFF4A493E)));
        expect(AppColors.toneLightCream, equals(const Color(0xFFF4E9DF)));
      });

      test('should have valid tone color values', () {
        // Assert
        expect(AppColors.toneOffWhite.value, isA<int>());
        expect(AppColors.tonePeach.value, isA<int>());
        expect(AppColors.toneBeige.value, isA<int>());
        expect(AppColors.toneSand.value, isA<int>());
        expect(AppColors.toneBrown.value, isA<int>());
        expect(AppColors.toneTaupe.value, isA<int>());
        expect(AppColors.toneRoseBrown.value, isA<int>());
        expect(AppColors.toneDarkBrown.value, isA<int>());
        expect(AppColors.toneDeepOlive.value, isA<int>());
        expect(AppColors.toneLightCream.value, isA<int>());
      });

      test('should have different tone color values', () {
        // Assert
        expect(AppColors.toneOffWhite, isNot(equals(AppColors.tonePeach)));
        expect(AppColors.toneBeige, isNot(equals(AppColors.toneSand)));
        expect(AppColors.toneBrown, isNot(equals(AppColors.toneTaupe)));
        expect(AppColors.toneRoseBrown, isNot(equals(AppColors.toneDarkBrown)));
        expect(
          AppColors.toneDeepOlive,
          isNot(equals(AppColors.toneLightCream)),
        );
      });
    });

    group('Color Properties', () {
      test('should have correct alpha values', () {
        // Assert
        expect(AppColors.pureWhite.alpha, equals(255));
        expect(AppColors.pointDark.alpha, equals(255));
        expect(AppColors.toneOffWhite.alpha, equals(255));
        expect(AppColors.toneDeepOlive.alpha, equals(255));
      });

      test('should have correct red values', () {
        // Assert
        expect(AppColors.pureWhite.red, equals(255));
        expect(AppColors.pointDark.red, equals(68));
        expect(AppColors.toneOffWhite.red, equals(240));
        expect(AppColors.toneDeepOlive.red, equals(74));
      });

      test('should have correct green values', () {
        // Assert
        expect(AppColors.pureWhite.green, equals(255));
        expect(AppColors.pointDark.green, equals(67));
        expect(AppColors.toneOffWhite.green, equals(240));
        expect(AppColors.toneDeepOlive.green, equals(73));
      });

      test('should have correct blue values', () {
        // Assert
        expect(AppColors.pureWhite.blue, equals(255));
        expect(AppColors.pointDark.blue, equals(60));
        expect(AppColors.toneOffWhite.blue, equals(229));
        expect(AppColors.toneDeepOlive.blue, equals(62));
      });
    });

    group('Color Equality', () {
      test('should be equal to same color', () {
        // Arrange
        const color1 = Color(0xFF899F6A);
        const color2 = Color(0xFF899F6A);

        // Assert
        expect(color1, equals(color2));
        expect(color1.hashCode, equals(color2.hashCode));
      });

      test('should not be equal to different color', () {
        // Arrange
        const color1 = Color(0xFF899F6A);
        const color2 = Color(0xFF7391C7);

        // Assert
        expect(color1, isNot(equals(color2)));
        expect(color1.hashCode, isNot(equals(color2.hashCode)));
      });

      test('should be equal to itself', () {
        // Assert
        expect(AppColors.pointGreen, equals(AppColors.pointGreen));
        expect(AppColors.pointBlue, equals(AppColors.pointBlue));
        expect(AppColors.toneOffWhite, equals(AppColors.toneOffWhite));
        expect(AppColors.toneDeepOlive, equals(AppColors.toneDeepOlive));
      });
    });

    group('Color Operations', () {
      test('should support color operations', () {
        // Arrange
        const color1 = AppColors.pointGreen;
        const color2 = AppColors.pointBlue;

        // Act
        final mixedColor = Color.lerp(color1, color2, 0.5);

        // Assert
        expect(mixedColor, isNotNull);
        expect(mixedColor!.red, isA<int>());
        expect(mixedColor.green, isA<int>());
        expect(mixedColor.blue, isA<int>());
        expect(mixedColor.alpha, isA<int>());
      });

      test('should support color with opacity', () {
        // Arrange
        const baseColor = AppColors.pointGreen;

        // Act
        final transparentColor = baseColor.withOpacity(0.5);

        // Assert
        expect(transparentColor.alpha, equals(128)); // 255 * 0.5
        expect(transparentColor.red, equals(baseColor.red));
        expect(transparentColor.green, equals(baseColor.green));
        expect(transparentColor.blue, equals(baseColor.blue));
      });

      test('should support color with alpha', () {
        // Arrange
        const baseColor = AppColors.pointBlue;

        // Act
        final alphaColor = baseColor.withAlpha(128);

        // Assert
        expect(alphaColor.alpha, equals(128));
        expect(alphaColor.red, equals(baseColor.red));
        expect(alphaColor.green, equals(baseColor.green));
        expect(alphaColor.blue, equals(baseColor.blue));
      });
    });

    group('Color Constants', () {
      test('should have consistent color constants', () {
        // Assert
        expect(AppColors.pointGreen, isA<Color>());
        expect(AppColors.pointBlue, isA<Color>());
        expect(AppColors.pointPink, isA<Color>());
        expect(AppColors.pointBrown, isA<Color>());
        expect(AppColors.pointGray, isA<Color>());
        expect(AppColors.pointOlive, isA<Color>());
        expect(AppColors.pointOffWhite, isA<Color>());
        expect(AppColors.pointDark, isA<Color>());
        expect(AppColors.pointCream, isA<Color>());
        expect(AppColors.pureWhite, isA<Color>());
        expect(AppColors.toneOffWhite, isA<Color>());
        expect(AppColors.tonePeach, isA<Color>());
        expect(AppColors.toneBeige, isA<Color>());
        expect(AppColors.toneSand, isA<Color>());
        expect(AppColors.toneBrown, isA<Color>());
        expect(AppColors.toneTaupe, isA<Color>());
        expect(AppColors.toneRoseBrown, isA<Color>());
        expect(AppColors.toneDarkBrown, isA<Color>());
        expect(AppColors.toneDeepOlive, isA<Color>());
        expect(AppColors.toneLightCream, isA<Color>());
      });

      test('should have valid hex values', () {
        // Assert
        expect(AppColors.pointGreen.value, greaterThan(0));
        expect(AppColors.pointBlue.value, greaterThan(0));
        expect(AppColors.pointPink.value, greaterThan(0));
        expect(AppColors.pointBrown.value, greaterThan(0));
        expect(AppColors.pointGray.value, greaterThan(0));
        expect(AppColors.pointOlive.value, greaterThan(0));
        expect(AppColors.pointOffWhite.value, greaterThan(0));
        expect(AppColors.pointDark.value, greaterThan(0));
        expect(AppColors.pointCream.value, greaterThan(0));
        expect(AppColors.pureWhite.value, greaterThan(0));
        expect(AppColors.toneOffWhite.value, greaterThan(0));
        expect(AppColors.tonePeach.value, greaterThan(0));
        expect(AppColors.toneBeige.value, greaterThan(0));
        expect(AppColors.toneSand.value, greaterThan(0));
        expect(AppColors.toneBrown.value, greaterThan(0));
        expect(AppColors.toneTaupe.value, greaterThan(0));
        expect(AppColors.toneRoseBrown.value, greaterThan(0));
        expect(AppColors.toneDarkBrown.value, greaterThan(0));
        expect(AppColors.toneDeepOlive.value, greaterThan(0));
        expect(AppColors.toneLightCream.value, greaterThan(0));
      });
    });
  });
}
