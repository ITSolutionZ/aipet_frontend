import 'package:aipet_frontend/features/pet_registor/presentation/constants/pet_registration_texts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetRegistrationTexts', () {
    test('should have all required screen titles', () {
      expect(PetRegistrationTexts.petTypeSelection, isNotEmpty);
      expect(PetRegistrationTexts.whoDoYouLiveWith, isNotEmpty);
      expect(PetRegistrationTexts.whatKindOfPet, isNotEmpty);
      expect(PetRegistrationTexts.enterName, isNotEmpty);
      expect(PetRegistrationTexts.petAnniversary, isNotEmpty);
      expect(PetRegistrationTexts.petAnniversarySummary, isNotEmpty);
      expect(PetRegistrationTexts.petSizeWeight, isNotEmpty);
      expect(PetRegistrationTexts.registrationComplete, isNotEmpty);
    });

    test('should have all required button texts', () {
      expect(PetRegistrationTexts.next, isNotEmpty);
      expect(PetRegistrationTexts.back, isNotEmpty);
      expect(PetRegistrationTexts.complete, isNotEmpty);
      expect(PetRegistrationTexts.cancel, isNotEmpty);
      expect(PetRegistrationTexts.save, isNotEmpty);
    });

    test('should have all required input field texts', () {
      expect(PetRegistrationTexts.nameHint, isNotEmpty);
      expect(PetRegistrationTexts.nameRequired, isNotEmpty);
      expect(PetRegistrationTexts.nameMinLength, isNotEmpty);
      expect(PetRegistrationTexts.nameMaxLength, isNotEmpty);
    });

    test('should have all required pet type texts', () {
      expect(PetRegistrationTexts.dog, isNotEmpty);
      expect(PetRegistrationTexts.cat, isNotEmpty);
      expect(PetRegistrationTexts.bird, isNotEmpty);
      expect(PetRegistrationTexts.hamster, isNotEmpty);
      expect(PetRegistrationTexts.rabbit, isNotEmpty);
      expect(PetRegistrationTexts.turtle, isNotEmpty);
    });

    test('should have all required error messages', () {
      expect(PetRegistrationTexts.networkError, isNotEmpty);
      expect(PetRegistrationTexts.unknownError, isNotEmpty);
      expect(PetRegistrationTexts.petNotFound, isNotEmpty);
      expect(PetRegistrationTexts.registrationFailed, isNotEmpty);
    });

    test('should have all required success messages', () {
      expect(PetRegistrationTexts.registrationSuccess, isNotEmpty);
      expect(PetRegistrationTexts.updateSuccess, isNotEmpty);
      expect(PetRegistrationTexts.deleteSuccess, isNotEmpty);
    });

    test('should have all required loading states', () {
      expect(PetRegistrationTexts.loading, isNotEmpty);
      expect(PetRegistrationTexts.saving, isNotEmpty);
      expect(PetRegistrationTexts.processing, isNotEmpty);
    });

    test('should contain Japanese characters', () {
      // 일본어 텍스트가 포함되어 있는지 확인
      expect(PetRegistrationTexts.petTypeSelection, contains('ペット'));
      expect(PetRegistrationTexts.whoDoYouLiveWith, contains('誰'));
      expect(PetRegistrationTexts.whatKindOfPet, contains('子'));
      expect(PetRegistrationTexts.enterName, contains('名前'));
      expect(PetRegistrationTexts.next, contains('次'));
    });
  });
}
