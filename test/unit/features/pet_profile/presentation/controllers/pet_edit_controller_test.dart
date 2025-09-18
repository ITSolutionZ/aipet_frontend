import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_edit_controller.dart';
import 'package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../pet_registor/domain/usecases/get_pet_by_id_usecase_test.mocks.dart';

void main() {
  group('PetEditState Tests', () {
    test('기본 상태가 올바르게 생성되어야 함', () {
      const state = PetEditState();

      expect(state.isEditMode, isFalse);
      expect(state.selectedImagePath, isNull);
      expect(state.editingValues, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith가 올바르게 동작해야 함', () {
      const initialState = PetEditState();

      final newState = initialState.copyWith(
        isEditMode: true,
        selectedImagePath: 'test/path',
        editingValues: {'name': 'Test Pet'},
        isLoading: true,
        errorMessage: 'Test error',
      );

      expect(newState.isEditMode, isTrue);
      expect(newState.selectedImagePath, equals('test/path'));
      expect(newState.editingValues, equals({'name': 'Test Pet'}));
      expect(newState.isLoading, isTrue);
      expect(newState.errorMessage, equals('Test error'));
    });
  });

  group('PetEditNotifier Tests', () {
    late ProviderContainer container;
    late MockPetRepository mockRepository;
    final testPet = PetProfileEntity(
      id: 'test-pet',
      name: 'テストペット',
      type: 'dog',
      breed: '柴犬',
      birthDate: DateTime(2021, 1, 1),
      ownerId: 'owner-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      additionalInfo: {
        'appearance': '茶色の毛',
        'gender': 'male',
        'size': 'medium',
        'weight': 12.5,
        'microchipId': '123456789',
      },
    );

    setUp(() {
      mockRepository = MockPetRepository();
      container = ProviderContainer(
        overrides: [petRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태가 올바르게 설정되어야 함', () {
      final notifier = container.read(petEditNotifierProvider.notifier);
      final state = container.read(petEditNotifierProvider);

      expect(state.isEditMode, isFalse);
      expect(state.editingValues, isEmpty);
    });

    test('startEdit이 편집 모드를 활성화하고 값들을 설정해야 함', () {
      final notifier = container.read(petEditNotifierProvider.notifier);

      notifier.startEdit(testPet);

      final state = container.read(petEditNotifierProvider);
      expect(state.isEditMode, isTrue);
      expect(state.editingValues['name'], equals('テストペット'));
      expect(state.editingValues['appearance'], equals('茶色の毛'));
      expect(state.editingValues['gender'], equals('male'));
      expect(state.editingValues['size'], equals('medium'));
      expect(state.editingValues['weight'], equals(12.5));
      expect(state.editingValues['microchipId'], equals('123456789'));
    });

    test('cancelEdit이 상태를 초기화해야 함', () {
      final notifier = container.read(petEditNotifierProvider.notifier);

      notifier.startEdit(testPet);
      notifier.cancelEdit();

      final state = container.read(petEditNotifierProvider);
      expect(state.isEditMode, isFalse);
      expect(state.editingValues, isEmpty);
      expect(state.selectedImagePath, isNull);
    });

    test('updateEditingValue가 편집 값을 업데이트해야 함', () {
      final notifier = container.read(petEditNotifierProvider.notifier);

      notifier.startEdit(testPet);
      notifier.updateEditingValue('name', '새로운 이름');

      final state = container.read(petEditNotifierProvider);
      expect(state.editingValues['name'], equals('새로운 이름'));
    });

    test('selectImage가 이미지 경로를 설정해야 함', () {
      final notifier = container.read(petEditNotifierProvider.notifier);

      notifier.selectImage('new/image/path');

      final state = container.read(petEditNotifierProvider);
      expect(state.selectedImagePath, equals('new/image/path'));
    });

    test('saveChanges가 성공적으로 펫을 업데이트해야 함', () async {
      when(mockRepository.updatePet(any)).thenAnswer((_) async => testPet);

      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);
      notifier.updateEditingValue('name', '업데이트된 이름');

      final result = await notifier.saveChanges(testPet);

      expect(result, isTrue);
      verify(mockRepository.updatePet(any)).called(1);
    });

    test('saveChanges가 실패할 때 에러 메시지를 설정해야 함', () async {
      when(mockRepository.updatePet(any)).thenThrow(Exception('Update failed'));

      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);

      final result = await notifier.saveChanges(testPet);

      expect(result, isFalse);
      final state = container.read(petEditNotifierProvider);
      expect(state.errorMessage, contains('アップデート中にエラーが発生しました'));
    });

    test('로딩 중일 때 saveChanges가 false를 반환해야 함', () async {
      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);

      // 상태를 로딩으로 수동 설정
      final currentState = container.read(petEditNotifierProvider);
      notifier.state = currentState.copyWith(isLoading: true);

      final result = await notifier.saveChanges(testPet);

      expect(result, isFalse);
    });

    test('편집 값이 비어있을 때 기본값을 사용해야 함', () async {
      when(mockRepository.updatePet(any)).thenAnswer((_) async => testPet);

      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);
      notifier.updateEditingValue('name', ''); // 빈 이름 설정

      await notifier.saveChanges(testPet);

      final captured = verify(mockRepository.updatePet(captureAny)).captured;
      final updatedPet = captured.first as PetProfileEntity;
      expect(updatedPet.name, equals(testPet.name)); // 원래 이름 유지
    });

    test('선택된 이미지가 있을 때 이미지 경로가 업데이트되어야 함', () async {
      when(mockRepository.updatePet(any)).thenAnswer((_) async => testPet);

      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);
      notifier.selectImage('new/image/path');

      await notifier.saveChanges(testPet);

      final captured = verify(mockRepository.updatePet(captureAny)).captured;
      final updatedPet = captured.first as PetProfileEntity;
      expect(updatedPet.imagePath, equals('new/image/path'));
    });

    test('숫자 타입 편집 값이 올바르게 처리되어야 함', () async {
      when(mockRepository.updatePet(any)).thenAnswer((_) async => testPet);

      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);
      notifier.updateEditingValue('weight', 15.5);

      await notifier.saveChanges(testPet);

      final captured = verify(mockRepository.updatePet(captureAny)).captured;
      final updatedPet = captured.first as PetProfileEntity;
      expect(updatedPet.additionalInfo!['weight'], equals(15.5));
    });

    test('null 값이 설정되었을 때 해당 필드가 포함되지 않아야 함', () async {
      when(mockRepository.updatePet(any)).thenAnswer((_) async => testPet);

      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);
      notifier.updateEditingValue('gender', null);

      await notifier.saveChanges(testPet);

      final captured = verify(mockRepository.updatePet(captureAny)).captured;
      final updatedPet = captured.first as PetProfileEntity;
      // gender가 null이므로 기존 값이 유지되어야 함
      expect(updatedPet.additionalInfo!['gender'], equals('male'));
    });
  });
}
