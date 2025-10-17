import 'package:aipet_frontend/features/daily/data/datasources/impl/daily_health_local_datasource_impl.dart';
import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_health_controller.g.dart';

/// Daily Health Controller
///
/// **역할**: 일일 건강 기록의 상태 관리 및 비즈니스 로직 처리
/// - Riverpod을 사용한 상태 관리
/// - 건강 기록 CRUD 작업 (Create, Read, Update, Delete)
/// - 로컬 저장소와의 데이터 동기화
///
/// **사용 위치**: DailyHealthScreen에서 사용
/// **관련 파일**: DailyHealthLogic (UI 로직 및 네비게이션)
@riverpod
class DailyHealthController extends _$DailyHealthController {
  @override
  Future<void> build() async {
    // 초기화 로직
  }

  /// 건강 기록 추가
  Future<void> addHealthRecord(DailyHealthRecord record) async {
    // 로컬 저장소에 건강 기록 저장 (추후 API 연동 시 변경)
    await Future.delayed(const Duration(milliseconds: 500));

    // 로컬 데이터 처리
    debugPrint('건강 기록 추가: ${record.toJson()}');
  }

  /// 건강 기록 업데이트
  Future<void> updateHealthRecord(DailyHealthRecord record) async {
    // 로컬 저장소에 건강 기록 업데이트 (추후 API 연동 시 변경)
    await Future.delayed(const Duration(milliseconds: 500));

    // 로컬 데이터 처리
    debugPrint('건강 기록 업데이트: ${record.toJson()}');
  }

  /// 건강 기록 삭제
  Future<void> deleteHealthRecord(String recordId) async {
    // 로컬 저장소에서 건강 기록 삭제 (추후 API 연동 시 변경)
    await Future.delayed(const Duration(milliseconds: 500));

    // 로컬 데이터 처리
    debugPrint('건강 기록 삭제: $recordId');
  }
}

/// 특정 펫의 건강 기록 Provider (로컬 저장소)
@riverpod
Future<DailyHealthRecord?> dailyHealthRecord(Ref ref, String petId) async {
  // 로컬 저장소에서 오늘의 건강 기록 조회
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final localDatasource = ref.watch(dailyHealthLocalDatasourceProvider);
  final records = await localDatasource.getDailyHealthRecordsByDateRange(
    petId,
    startOfDay,
    endOfDay,
  );

  return records.isNotEmpty ? records.first : null;
}

/// 특정 펫의 건강 분석 Provider (로컬 저장소)
@riverpod
Future<HealthAnalysis?> dailyHealthAnalysis(Ref ref, String petId) async {
  // 로컬 저장소에서 건강 분석 히스토리 조회
  final localDatasource = ref.watch(dailyHealthLocalDatasourceProvider);
  final analyses = await localDatasource.getHealthAnalysisHistory(petId);

  // 가장 최근 분석 결과 반환
  return analyses.isNotEmpty ? analyses.first : null;
}
