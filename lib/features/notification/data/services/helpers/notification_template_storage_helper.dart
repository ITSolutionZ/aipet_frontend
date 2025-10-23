import 'dart:convert';

import '../../../domain/domain.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

/// 알림 템플릿 저장소 헬퍼
class NotificationTemplateStorageHelper {
  static const String templatesKey = 'notification_templates';

  /// 템플릿 저장
  static Future<void> saveTemplates(
    List<NotificationTemplate> templates,
  ) async {
    try {
      final templatesJson = jsonEncode(
        templates.map((t) => t.toJson()).toList(),
      );
      await SecureStorageService.setString(templatesKey, templatesJson);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('템플릿 저장 실패: $e');
      }
    }
  }

  /// 템플릿 조회
  static Future<List<NotificationTemplate>> getTemplates() async {
    try {
      final templatesJson = await SecureStorageService.getString(templatesKey);
      if (templatesJson != null) {
        final List<dynamic> templatesList = jsonDecode(templatesJson);
        return templatesList
            .map((json) => NotificationTemplate.fromJson(json))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('템플릿 조회 실패: $e');
      }
    }
    return [];
  }

  /// 모든 템플릿 삭제
  static Future<void> clearAllTemplates() async {
    try {
      await SecureStorageService.remove(templatesKey);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('템플릿 삭제 실패: $e');
      }
    }
  }

  /// 템플릿 검색
  static List<NotificationTemplate> searchTemplates(
    List<NotificationTemplate> templates,
    String query,
  ) {
    final lowercaseQuery = query.toLowerCase();

    return templates.where((template) {
      return template.name.toLowerCase().contains(lowercaseQuery) ||
          template.description.toLowerCase().contains(lowercaseQuery) ||
          template.bodyTemplate.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// 템플릿 통계 생성
  static Map<String, dynamic> createTemplateStats(
    List<NotificationTemplate> templates,
  ) {
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
  }
}
