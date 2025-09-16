import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aipet_frontend/features/pet_profile/presentation/widgets/pet_profile_card.dart';
import 'package:aipet_frontend/shared/shared.dart';

void main() {
  group('PetProfileCard Widget Tests', () {
    testWidgets('기본 정보가 올바르게 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PetProfileCard(
              label: '테스트 라벨',
              value: '테스트 값',
            ),
          ),
        ),
      );

      expect(find.text('테스트 라벨'), findsOneWidget);
      expect(find.text('테스트 값'), findsOneWidget);
    });

    testWidgets('아이콘이 설정되면 아이콘이 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PetProfileCard(
              label: '테스트 라벨',
              value: '테스트 값',
              icon: Icons.pets,
              iconColor: AppColors.pointBlue,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('onTap이 설정되면 탭 이벤트가 동작해야 함', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetProfileCard(
              label: '테스트 라벨',
              value: '테스트 값',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PetProfileCard));
      expect(tapped, isTrue);
    });

    testWidgets('trailing 위젯이 설정되면 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PetProfileCard(
              label: '테스트 라벨',
              value: '테스트 값',
              trailing: Icon(Icons.arrow_forward),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });
  });

  group('EditableAttributeCard Widget Tests', () {
    testWidgets('편집 모드가 아닐 때 값만 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditableAttributeCard(
              label: '성별',
              value: 'オス',
              isEditMode: false,
            ),
          ),
        ),
      );

      expect(find.text('성별'), findsOneWidget);
      expect(find.text('オス'), findsOneWidget);
    });

    testWidgets('편집 모드일 때 편집 위젯이 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditableAttributeCard(
              label: '성별',
              value: 'オス',
              isEditMode: true,
              editWidget: Text('편집 위젯'),
            ),
          ),
        ),
      );

      expect(find.text('성별'), findsOneWidget);
      expect(find.text('편집 위젯'), findsOneWidget);
      expect(find.text('オス'), findsNothing);
    });
  });

  group('DateInfoCard Widget Tests', () {
    testWidgets('날짜 정보가 올바르게 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DateInfoCard(
              icon: Icons.cake,
              label: '誕生日',
              date: '2021年1月1日',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cake), findsOneWidget);
      expect(find.text('誕生日'), findsOneWidget);
      expect(find.text('2021年1月1日'), findsOneWidget);
    });

    testWidgets('추가 정보가 있으면 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DateInfoCard(
              icon: Icons.cake,
              label: '誕生日',
              date: '2021年1月1日',
              additionalInfo: '3歳',
            ),
          ),
        ),
      );

      expect(find.text('3歳'), findsOneWidget);
    });
  });

  group('PetProfileHeader Widget Tests', () {
    testWidgets('기본 펫 정보가 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PetProfileHeader(
              name: 'テストペット',
              typeAndBreed: '犬 | 柴犬',
            ),
          ),
        ),
      );

      expect(find.text('テストペット'), findsOneWidget);
      expect(find.text('犬 | 柴犬'), findsOneWidget);
    });

    testWidgets('이미지가 없을 때 기본 아이콘이 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PetProfileHeader(
              name: 'テストペット',
              typeAndBreed: '犬 | 柴犬',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('편집 모드일 때 카메라 버튼이 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetProfileHeader(
              name: 'テストペット',
              typeAndBreed: '犬 | 柴犬',
              isEditMode: true,
              onImageTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('편집 모드가 아닐 때 편집 아이콘이 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PetProfileHeader(
              name: 'テストペット',
              typeAndBreed: '犬 | 柴犬',
              isEditMode: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('커스텀 이름 위젯이 제공되면 사용되어야 함', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PetProfileHeader(
              name: 'テストペット',
              typeAndBreed: '犬 | 柴犬',
              nameWidget: Text('커스텀 이름 위젯'),
            ),
          ),
        ),
      );

      expect(find.text('커스텀 이름 위젯'), findsOneWidget);
      expect(find.text('テストペット'), findsNothing);
    });

    testWidgets('이미지 탭 이벤트가 동작해야 함', (tester) async {
      bool imageTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetProfileHeader(
              name: 'テストペット',
              typeAndBreed: '犬 | 柴犬',
              isEditMode: true,
              onImageTap: () => imageTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.camera_alt));
      expect(imageTapped, isTrue);
    });
  });
}