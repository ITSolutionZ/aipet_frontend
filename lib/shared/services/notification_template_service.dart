import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/notification/domain/entities/notification_model.dart';
import '../../features/notification/domain/entities/notification_template.dart';
import 'notification_service.dart';
import 'secure_storage_service.dart';

/// 알림 템플릿 서비스
class NotificationTemplateService {
  static const String _templatesKey = 'notification_templates';

  final NotificationService _notificationService;
  bool _isInitialized = false;

  // 템플릿 스트림
  final StreamController<List<NotificationTemplate>> _templatesController =
      StreamController<List<NotificationTemplate>>.broadcast();

  Stream<List<NotificationTemplate>> get templatesStream =>
      _templatesController.stream;

  NotificationTemplateService(this._notificationService);

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 기본 템플릿이 없으면 생성
      final templates = await getTemplates();
      if (templates.isEmpty) {
        await _createDefaultTemplates();
      }

      _isInitialized = true;
      if (kDebugMode) {
        print('알림 템플릿 서비스 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('알림 템플릿 서비스 초기화 실패: $e');
      }
    }
  }

  /// 기본 템플릿 생성
  Future<void> _createDefaultTemplates() async {
    try {
      final defaultTemplates =
          NotificationTemplateFactory.getDefaultTemplates();
      await _saveTemplates(defaultTemplates);
      _templatesController.add(defaultTemplates);

      if (kDebugMode) {
        print('기본 템플릿 생성 완료: ${defaultTemplates.length}개');
      }
    } catch (e) {
      if (kDebugMode) {
        print('기본 템플릿 생성 실패: $e');
      }
    }
  }

  /// 템플릿 추가
  Future<void> addTemplate(NotificationTemplate template) async {
    try {
      final templates = await getTemplates();
      templates.add(template);
      await _saveTemplates(templates);
      _templatesController.add(templates);

      if (kDebugMode) {
        print('템플릿 추가됨: ${template.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 추가 실패: $e');
      }
    }
  }

  /// 템플릿 업데이트
  Future<void> updateTemplate(NotificationTemplate template) async {
    try {
      final templates = await getTemplates();
      final index = templates.indexWhere((t) => t.id == template.id);

      if (index != -1) {
        templates[index] = template;
        await _saveTemplates(templates);
        _templatesController.add(templates);

        if (kDebugMode) {
          print('템플릿 업데이트됨: ${template.name}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 업데이트 실패: $e');
      }
    }
  }

  /// 템플릿 삭제
  Future<void> deleteTemplate(String templateId) async {
    try {
      final templates = await getTemplates();
      templates.removeWhere((t) => t.id == templateId);
      await _saveTemplates(templates);
      _templatesController.add(templates);

      if (kDebugMode) {
        print('템플릿 삭제됨: $templateId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 삭제 실패: $e');
      }
    }
  }

  /// 템플릿 활성화/비활성화
  Future<void> toggleTemplate(String templateId, bool isActive) async {
    try {
      final templates = await getTemplates();
      final index = templates.indexWhere((t) => t.id == templateId);

      if (index != -1) {
        templates[index] = templates[index].copyWith(isActive: isActive);
        await _saveTemplates(templates);
        _templatesController.add(templates);

        if (kDebugMode) {
          print('템플릿 상태 변경됨: $templateId, 활성화: $isActive');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 상태 변경 실패: $e');
      }
    }
  }

  /// 모든 템플릿 가져오기
  Future<List<NotificationTemplate>> getTemplates() async {
    try {
      final templatesJson = await SecureStorageService.getStringUnencrypted(
        _templatesKey,
      );
      if (templatesJson != null) {
        final List<dynamic> templatesList = jsonDecode(templatesJson);
        return templatesList
            .map((json) => NotificationTemplate.fromJson(json))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 로드 실패: $e');
      }
    }
    return [];
  }

  /// 활성화된 템플릿만 가져오기
  Future<List<NotificationTemplate>> getActiveTemplates() async {
    final templates = await getTemplates();
    return NotificationTemplateFactory.filterActive(templates);
  }

  /// 특정 타입의 템플릿 가져오기
  Future<List<NotificationTemplate>> getTemplatesByType(
    TemplateType type,
  ) async {
    final templates = await getTemplates();
    return NotificationTemplateFactory.filterByType(templates, type);
  }

  /// 특정 알림 타입의 템플릿 가져오기
  Future<List<NotificationTemplate>> getTemplatesByNotificationType(
    NotificationType type,
  ) async {
    final templates = await getTemplates();
    return NotificationTemplateFactory.filterByNotificationType(
      templates,
      type,
    );
  }

  /// 템플릿으로 알림 생성 및 발송
  Future<void> sendNotificationFromTemplate(
    String templateId, {
    Map<String, String>? variables,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
  }) async {
    try {
      final templates = await getTemplates();
      final template = templates.firstWhere((t) => t.id == templateId);

      if (!template.isActive) {
        if (kDebugMode) {
          print('비활성화된 템플릿: $templateId');
        }
        return;
      }

      // 알림 생성
      final notification = template.createNotification(
        variables: variables,
        priority: priority,
        data: data,
      );

      // 알림 발송
      await _notificationService.createNotification(
        title: notification.title,
        body: notification.body,
        type: notification.type,
        priority: notification.priority,
        data: notification.data,
      );

      // 마지막 사용 시간 업데이트
      final updatedTemplate = template.copyWith(lastUsed: DateTime.now());
      await updateTemplate(updatedTemplate);

      if (kDebugMode) {
        print('템플릿으로 알림 발송됨: ${template.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 알림 발송 실패: $e');
      }
    }
  }

  /// 템플릿 미리보기 생성
  String getTemplatePreview(
    String templateId, {
    Map<String, String>? variables,
  }) {
    try {
      // 메모리에서 템플릿 찾기 (실제로는 getTemplates() 호출 필요)
      final defaultTemplates =
          NotificationTemplateFactory.getDefaultTemplates();
      final template = defaultTemplates.firstWhere((t) => t.id == templateId);

      return template.getPreview();
    } catch (e) {
      return '미리보기를 생성할 수 없습니다.';
    }
  }

  /// 템플릿 검증
  bool validateTemplate(NotificationTemplate template) {
    return template.isValid();
  }

  /// 템플릿 복제
  Future<void> duplicateTemplate(String templateId) async {
    try {
      final templates = await getTemplates();
      final originalTemplate = templates.firstWhere((t) => t.id == templateId);

      final duplicatedTemplate = originalTemplate.copyWith(
        id: '${originalTemplate.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
        name: '${originalTemplate.name} (복사본)',
        createdAt: DateTime.now(),
        lastUsed: null,
      );

      await addTemplate(duplicatedTemplate);

      if (kDebugMode) {
        print('템플릿 복제됨: ${originalTemplate.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 복제 실패: $e');
      }
    }
  }

  /// 템플릿 통계 가져오기
  Future<Map<String, dynamic>> getTemplateStats() async {
    try {
      final templates = await getTemplates();
      final activeTemplates = templates.where((t) => t.isActive).length;
      final totalTemplates = templates.length;

      final typeStats = <String, int>{};
      for (final template in templates) {
        final typeName = template.type.name;
        typeStats[typeName] = (typeStats[typeName] ?? 0) + 1;
      }

      final notificationTypeStats = <String, int>{};
      for (final template in templates) {
        final typeName = template.notificationType.name;
        notificationTypeStats[typeName] =
            (notificationTypeStats[typeName] ?? 0) + 1;
      }

      return {
        'total': totalTemplates,
        'active': activeTemplates,
        'inactive': totalTemplates - activeTemplates,
        'byType': typeStats,
        'byNotificationType': notificationTypeStats,
      };
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 통계 가져오기 실패: $e');
      }
      return {};
    }
  }

  /// 템플릿 검색
  Future<List<NotificationTemplate>> searchTemplates(String query) async {
    try {
      final templates = await getTemplates();
      final lowercaseQuery = query.toLowerCase();

      return templates.where((template) {
        return template.name.toLowerCase().contains(lowercaseQuery) ||
            template.description.toLowerCase().contains(lowercaseQuery) ||
            template.bodyTemplate.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 검색 실패: $e');
      }
      return [];
    }
  }

  /// 모든 템플릿 삭제
  Future<void> clearAllTemplates() async {
    try {
      await SecureStorageService.remove(_templatesKey);
      _templatesController.add([]);

      if (kDebugMode) {
        print('모든 템플릿 삭제됨');
      }
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 삭제 실패: $e');
      }
    }
  }

  /// 템플릿 저장
  Future<void> _saveTemplates(List<NotificationTemplate> templates) async {
    try {
      final templatesJson = jsonEncode(
        templates.map((t) => t.toJson()).toList(),
      );
      await SecureStorageService.setStringUnencrypted(
        _templatesKey,
        templatesJson,
      );
    } catch (e) {
      if (kDebugMode) {
        print('템플릿 저장 실패: $e');
      }
    }
  }

  /// 리소스 정리
  void dispose() {
    _templatesController.close();
  }
}
