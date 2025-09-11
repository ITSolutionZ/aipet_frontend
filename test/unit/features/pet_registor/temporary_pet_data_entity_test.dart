import 'package:aipet_frontend/features/pet_registor/domain/entities/temporary_pet_data_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemporaryPetDataEntity', () {
    late TemporaryPetDataEntity testData;

    setUp(() {
      testData = TemporaryPetDataEntity(
        id: 'temp1',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        birthDate: DateTime(2020, 3, 15),
        imagePath: 'test_image.jpg',
        ownerId: 'user1',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        isActive: true,
        additionalInfo: {
          'personality': ['friendly'],
        },
        currentStep: PetRegistrationStep.typeSelection,
        stepData: {'selectedType': 'dog'},
      );
    });

    test('should create temporary pet data with all fields', () {
      expect(testData.id, 'temp1');
      expect(testData.name, 'テストペット');
      expect(testData.type, 'dog');
      expect(testData.breed, '柴犬');
      expect(testData.birthDate, DateTime(2020, 3, 15));
      expect(testData.imagePath, 'test_image.jpg');
      expect(testData.ownerId, 'user1');
      expect(testData.isActive, true);
      expect(testData.currentStep, PetRegistrationStep.typeSelection);
      expect(testData.stepData, {'selectedType': 'dog'});
    });

    test('should have default values for optional fields', () {
      const minimalData = TemporaryPetDataEntity();

      expect(minimalData.id, isNull);
      expect(minimalData.name, isNull);
      expect(minimalData.type, isNull);
      expect(minimalData.breed, isNull);
      expect(minimalData.birthDate, isNull);
      expect(minimalData.imagePath, isNull);
      expect(minimalData.ownerId, isNull);
      expect(minimalData.isActive, true);
      expect(minimalData.currentStep, PetRegistrationStep.typeSelection);
      expect(minimalData.stepData, isNull);
    });

    test('should move to next step correctly', () {
      final nextStepData = testData.nextStep();

      expect(nextStepData.currentStep, PetRegistrationStep.breedSelection);
      expect(nextStepData.id, testData.id);
      expect(nextStepData.name, testData.name);
    });

    test('should move to previous step correctly', () {
      final breedSelectionData = testData.copyWith(
        currentStep: PetRegistrationStep.breedSelection,
      );
      final previousStepData = breedSelectionData.previousStep();

      expect(previousStepData.currentStep, PetRegistrationStep.typeSelection);
    });

    test('should not move beyond first step when going previous', () {
      final firstStepData = testData.copyWith(
        currentStep: PetRegistrationStep.typeSelection,
      );
      final previousStepData = firstStepData.previousStep();

      expect(previousStepData.currentStep, PetRegistrationStep.typeSelection);
    });

    test('should not move beyond last step when going next', () {
      final lastStepData = testData.copyWith(
        currentStep: PetRegistrationStep.complete,
      );
      final nextStepData = lastStepData.nextStep();

      expect(nextStepData.currentStep, PetRegistrationStep.complete);
    });

    test('should identify first and last steps correctly', () {
      final firstStepData = testData.copyWith(
        currentStep: PetRegistrationStep.typeSelection,
      );
      final lastStepData = testData.copyWith(
        currentStep: PetRegistrationStep.complete,
      );

      expect(firstStepData.isFirstStep, true);
      expect(firstStepData.isLastStep, false);
      expect(lastStepData.isFirstStep, false);
      expect(lastStepData.isLastStep, true);
    });

    test('should calculate progress correctly', () {
      final typeSelectionData = testData.copyWith(
        currentStep: PetRegistrationStep.typeSelection,
      );
      final breedSelectionData = testData.copyWith(
        currentStep: PetRegistrationStep.breedSelection,
      );
      final completeData = testData.copyWith(
        currentStep: PetRegistrationStep.complete,
      );

      expect(typeSelectionData.progress, closeTo(1 / 6, 0.01));
      expect(breedSelectionData.progress, closeTo(2 / 6, 0.01));
      expect(completeData.progress, closeTo(1.0, 0.01));
    });

    test('should return correct step titles in Japanese', () {
      final typeSelectionData = testData.copyWith(
        currentStep: PetRegistrationStep.typeSelection,
      );
      final breedSelectionData = testData.copyWith(
        currentStep: PetRegistrationStep.breedSelection,
      );
      final nameInputData = testData.copyWith(
        currentStep: PetRegistrationStep.nameInput,
      );
      final birthDateData = testData.copyWith(
        currentStep: PetRegistrationStep.birthDateInput,
      );
      final imageUploadData = testData.copyWith(
        currentStep: PetRegistrationStep.imageUpload,
      );
      final completeData = testData.copyWith(
        currentStep: PetRegistrationStep.complete,
      );

      expect(typeSelectionData.stepTitle, '펫 종류 선택');
      expect(breedSelectionData.stepTitle, '품종 선택');
      expect(nameInputData.stepTitle, '이름 입력');
      expect(birthDateData.stepTitle, '생년월일 입력');
      expect(imageUploadData.stepTitle, '사진 업로드');
      expect(completeData.stepTitle, '등록 완료');
    });

    test('should return correct step descriptions in Japanese', () {
      final typeSelectionData = testData.copyWith(
        currentStep: PetRegistrationStep.typeSelection,
      );
      final completeData = testData.copyWith(
        currentStep: PetRegistrationStep.complete,
      );

      expect(typeSelectionData.stepDescription, '펫의 종류를 선택해주세요');
      expect(completeData.stepDescription, '펫 등록이 완료되었습니다!');
    });

    test('should copy with new values correctly', () {
      final updatedData = testData.copyWith(
        name: '新しい名前',
        currentStep: PetRegistrationStep.nameInput,
        stepData: {'newData': 'value'},
      );

      expect(updatedData.id, testData.id);
      expect(updatedData.name, '新しい名前');
      expect(updatedData.currentStep, PetRegistrationStep.nameInput);
      expect(updatedData.stepData, {'newData': 'value'});
      expect(updatedData.type, testData.type);
    });

    test('should implement equality correctly', () {
      final sameData = testData.copyWith();
      final differentData = testData.copyWith(id: 'temp2');

      expect(testData, equals(sameData));
      expect(testData, isNot(equals(differentData)));
    });

    test('should generate correct hash code', () {
      final sameData = testData.copyWith();
      final differentData = testData.copyWith(id: 'temp2');

      expect(testData.hashCode, equals(sameData.hashCode));
      expect(testData.hashCode, isNot(equals(differentData.hashCode)));
    });

    test('should return correct string representation', () {
      final stringRep = testData.toString();

      expect(stringRep, contains('TemporaryPetDataEntity'));
      expect(stringRep, contains('id: temp1'));
      expect(stringRep, contains('name: テストペット'));
      expect(stringRep, contains('type: dog'));
      expect(
        stringRep,
        contains('currentStep: PetRegistrationStep.typeSelection'),
      );
    });
  });
}
