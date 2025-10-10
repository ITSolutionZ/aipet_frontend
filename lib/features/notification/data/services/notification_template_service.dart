import 'dart:async';

import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';

import 'helpers/notification_template_storage_helper.dart';
import 'notification_service.dart' as local;

/// 알림 템플릿 서비스
class NotificationTemplateService {
  final local.NotificationService _notificationService;
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
      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 기본 템플릿 생성
  Future<void> _createDefaultTemplates() async {
    try {
      final defaultTemplates =
          NotificationTemplateFactory.getDefaultTemplates();
      await NotificationTemplateStorageHelper.saveTemplates(defaultTemplates);
      _templatesController.add(defaultTemplates);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 템플릿 추가
  Future<void> addTemplate(NotificationTemplate template) async {
    try {
      final templates = await getTemplates();
      templates.add(template);
      await NotificationTemplateStorageHelper.saveTemplates(templates);
      _templatesController.add(templates);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 템플릿 업데이트
  Future<void> updateTemplate(NotificationTemplate template) async {
    try {
      final templates = await getTemplates();
      final index = templates.indexWhere((t) => t.id == template.id);

      if (index != -1) {
        templates[index] = template;
        await NotificationTemplateStorageHelper.saveTemplates(templates);
        _templatesController.add(templates);

        if (kDebugMode) {}
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 템플릿 삭제
  Future<void> deleteTemplate(String templateId) async {
    try {
      final templates = await getTemplates();
      templates.removeWhere((t) => t.id == templateId);
      await NotificationTemplateStorageHelper.saveTemplates(templates);
      _templatesController.add(templates);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 템플릿 활성화/비활성화
  Future<void> toggleTemplate(String templateId, bool isActive) async {
    try {
      final templates = await getTemplates();
      final index = templates.indexWhere((t) => t.id == templateId);

      if (index != -1) {
        templates[index] = templates[index].copyWith(isActive: isActive);
        await NotificationTemplateStorageHelper.saveTemplates(templates);
        _templatesController.add(templates);

        if (kDebugMode) {}
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 모든 템플릿 가져오기
  Future<List<NotificationTemplate>> getTemplates() async {
    return NotificationTemplateStorageHelper.getTemplates();
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
        if (kDebugMode) {}
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

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
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

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 템플릿 통계 가져오기
  Future<Map<String, dynamic>> getTemplateStats() async {
    try {
      final templates = await getTemplates();
      return NotificationTemplateStorageHelper.createTemplateStats(templates);
    } catch (e) {
      if (kDebugMode) {}
      return {};
    }
  }

  /// 템플릿 검색
  Future<List<NotificationTemplate>> searchTemplates(String query) async {
    try {
      final templates = await getTemplates();
      return NotificationTemplateStorageHelper.searchTemplates(
        templates,
        query,
      );
    } catch (e) {
      if (kDebugMode) {}
      return [];
    }
  }

  /// 모든 템플릿 삭제
  Future<void> clearAllTemplates() async {
    try {
      await NotificationTemplateStorageHelper.clearAllTemplates();
      _templatesController.add([]);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 리소스 정리
  void dispose() {
    _templatesController.close();
  }
}
