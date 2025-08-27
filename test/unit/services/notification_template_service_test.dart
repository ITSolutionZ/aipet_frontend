import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/features/notification/domain/entities/notification_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationTemplate Tests', () {
    test('should create notification template', () {
      // Arrange
      const id = 'test_template_id';
      const name = '테스트 템플릿';
      const description = '테스트 템플릿 설명';
      const type = TemplateType.greeting;
      const notificationType = NotificationType.general;
      const titleTemplate = '안녕하세요, {{name}}님!';
      const bodyTemplate = '{{pet_name}}와 함께 좋은 하루 보내세요!';
      final variables = ['name', 'pet_name'];
      final defaultValues = {'name': '사용자', 'pet_name': '반려동물'};
      final createdAt = DateTime.now();

      // Act
      final template = NotificationTemplate(
        id: id,
        name: name,
        description: description,
        type: type,
        notificationType: notificationType,
        titleTemplate: titleTemplate,
        bodyTemplate: bodyTemplate,
        variables: variables,
        defaultValues: defaultValues,
        createdAt: createdAt,
      );

      // Assert
      expect(template.id, equals(id));
      expect(template.name, equals(name));
      expect(template.description, equals(description));
      expect(template.type, equals(type));
      expect(template.notificationType, equals(notificationType));
      expect(template.titleTemplate, equals(titleTemplate));
      expect(template.bodyTemplate, equals(bodyTemplate));
      expect(template.variables, equals(variables));
      expect(template.defaultValues, equals(defaultValues));
      expect(template.isActive, isTrue);
      expect(template.isValid(), isTrue);
    });

    test('should create notification from template', () {
      // Arrange
      final template = NotificationTemplate(
        id: 'test',
        name: '테스트',
        description: '테스트',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '안녕하세요, {{name}}님!',
        bodyTemplate: '{{pet_name}}와 함께 좋은 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자', 'pet_name': '반려동물'},
        createdAt: DateTime.now(),
      );

      final variables = {'name': '김철수', 'pet_name': '멍멍이'};

      // Act
      final notification = template.createNotification(variables: variables);

      // Assert
      expect(notification.title, equals('안녕하세요, 김철수님!'));
      expect(notification.body, equals('멍멍이와 함께 좋은 하루 보내세요!'));
      expect(notification.type, equals(NotificationType.general));
      expect(notification.priority, equals(NotificationPriority.normal));
    });

    test('should use default values when variables not provided', () {
      // Arrange
      final template = NotificationTemplate(
        id: 'test',
        name: '테스트',
        description: '테스트',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '안녕하세요, {{name}}님!',
        bodyTemplate: '{{pet_name}}와 함께 좋은 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자', 'pet_name': '반려동물'},
        createdAt: DateTime.now(),
      );

      // Act
      final notification = template.createNotification();

      // Assert
      expect(notification.title, equals('안녕하세요, 사용자님!'));
      expect(notification.body, equals('반려동물와 함께 좋은 하루 보내세요!'));
    });

    test('should handle missing variables', () {
      // Arrange
      final template = NotificationTemplate(
        id: 'test',
        name: '테스트',
        description: '테스트',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '안녕하세요, {{name}}님!',
        bodyTemplate: '{{pet_name}}와 함께 좋은 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자'},
        createdAt: DateTime.now(),
      );

      // Act
      final notification = template.createNotification();

      // Assert
      expect(notification.title, equals('안녕하세요, 사용자님!'));
      expect(notification.body, equals('와 함께 좋은 하루 보내세요!'));
    });

    test('should validate template correctly', () {
      // Arrange
      final validTemplate = NotificationTemplate(
        id: 'valid',
        name: '유효한 템플릿',
        description: '테스트',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '안녕하세요, {{name}}님!',
        bodyTemplate: '{{pet_name}}와 함께 좋은 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자', 'pet_name': '반려동물'},
        createdAt: DateTime.now(),
      );

      final invalidTemplate = NotificationTemplate(
        id: 'invalid',
        name: '유효하지 않은 템플릿',
        description: '테스트',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '안녕하세요, {{name}}님!',
        bodyTemplate: '{{pet_name}}와 함께 좋은 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자'}, // pet_name이 없음
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(validTemplate.isValid(), isTrue);
      expect(invalidTemplate.isValid(), isFalse);
    });

    test('should generate preview correctly', () {
      // Arrange
      final template = NotificationTemplate(
        id: 'test',
        name: '테스트',
        description: '테스트',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '안녕하세요, {{name}}님!',
        bodyTemplate: '{{pet_name}}와 함께 좋은 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자', 'pet_name': '반려동물'},
        createdAt: DateTime.now(),
      );

      // Act
      final preview = template.getPreview();

      // Assert
      expect(preview, equals('반려동물와 함께 좋은 하루 보내세요!'));
    });

    test('should copy template with new values', () {
      // Arrange
      final originalTemplate = NotificationTemplate(
        id: 'test',
        name: '원본 템플릿',
        description: '원본 설명',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '안녕하세요, {{name}}님!',
        bodyTemplate: '{{pet_name}}와 함께 좋은 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자', 'pet_name': '반려동물'},
        createdAt: DateTime.now(),
      );

      // Act
      final copiedTemplate = originalTemplate.copyWith(
        name: '새 템플릿',
        isActive: false,
      );

      // Assert
      expect(copiedTemplate.id, equals(originalTemplate.id));
      expect(copiedTemplate.name, equals('새 템플릿'));
      expect(copiedTemplate.description, equals(originalTemplate.description));
      expect(copiedTemplate.isActive, isFalse);
    });

    test('should convert template to and from JSON', () {
      // Arrange
      final template = NotificationTemplate(
        id: 'test_id',
        name: '테스트 템플릿',
        description: '테스트 설명',
        type: TemplateType.greeting,
        notificationType: NotificationType.general,
        titleTemplate: '안녕하세요, {{name}}님!',
        bodyTemplate: '{{pet_name}}와 함께 좋은 하루 보내세요!',
        variables: ['name', 'pet_name'],
        defaultValues: {'name': '사용자', 'pet_name': '반려동물'},
        isActive: true,
        createdAt: DateTime(2023, 1, 1, 12, 0, 0),
        lastUsed: DateTime(2023, 1, 15, 14, 30, 0),
      );

      // Act
      final json = template.toJson();
      final fromJson = NotificationTemplate.fromJson(json);

      // Assert
      expect(fromJson.id, equals(template.id));
      expect(fromJson.name, equals(template.name));
      expect(fromJson.description, equals(template.description));
      expect(fromJson.type, equals(template.type));
      expect(fromJson.notificationType, equals(template.notificationType));
      expect(fromJson.titleTemplate, equals(template.titleTemplate));
      expect(fromJson.bodyTemplate, equals(template.bodyTemplate));
      expect(fromJson.variables, equals(template.variables));
      expect(fromJson.defaultValues, equals(template.defaultValues));
      expect(fromJson.isActive, equals(template.isActive));
    });
  });

  group('NotificationTemplateFactory Tests', () {
    test('should create default templates', () {
      // Act
      final defaultTemplates = NotificationTemplateFactory.getDefaultTemplates();

      // Assert
      expect(defaultTemplates, isNotEmpty);
      expect(defaultTemplates.length, greaterThan(0));

      // 각 템플릿이 유효한지 확인
      for (final template in defaultTemplates) {
        expect(template.isValid(), isTrue);
        expect(template.id, isNotEmpty);
        expect(template.name, isNotEmpty);
        expect(template.description, isNotEmpty);
      }
    });

    test('should filter templates by type', () {
      // Arrange
      final templates = NotificationTemplateFactory.getDefaultTemplates();

      // Act
      final greetingTemplates = NotificationTemplateFactory.filterByType(
        templates,
        TemplateType.greeting,
      );

      final reminderTemplates = NotificationTemplateFactory.filterByType(
        templates,
        TemplateType.reminder,
      );

      // Assert
      expect(greetingTemplates, isNotEmpty);
      expect(reminderTemplates, isNotEmpty);

      for (final template in greetingTemplates) {
        expect(template.type, equals(TemplateType.greeting));
      }

      for (final template in reminderTemplates) {
        expect(template.type, equals(TemplateType.reminder));
      }
    });

    test('should filter templates by notification type', () {
      // Arrange
      final templates = NotificationTemplateFactory.getDefaultTemplates();

      // Act
      final generalTemplates = NotificationTemplateFactory.filterByNotificationType(
        templates,
        NotificationType.general,
      );

      final feedingTemplates = NotificationTemplateFactory.filterByNotificationType(
        templates,
        NotificationType.feeding,
      );

      // Assert
      expect(generalTemplates, isNotEmpty);
      expect(feedingTemplates, isNotEmpty);

      for (final template in generalTemplates) {
        expect(template.notificationType, equals(NotificationType.general));
      }

      for (final template in feedingTemplates) {
        expect(template.notificationType, equals(NotificationType.feeding));
      }
    });

    test('should filter active templates', () {
      // Arrange
      final templates = NotificationTemplateFactory.getDefaultTemplates();

      // Act
      final activeTemplates = NotificationTemplateFactory.filterActive(templates);

      // Assert
      expect(activeTemplates, isNotEmpty);

      for (final template in activeTemplates) {
        expect(template.isActive, isTrue);
      }
    });
  });

  group('TemplateType Tests', () {
    test('should have correct template type values', () {
      // Assert
      expect(TemplateType.greeting, isNotNull);
      expect(TemplateType.reminder, isNotNull);
      expect(TemplateType.celebration, isNotNull);
      expect(TemplateType.warning, isNotNull);
      expect(TemplateType.info, isNotNull);
      expect(TemplateType.custom, isNotNull);
    });
  });
}
