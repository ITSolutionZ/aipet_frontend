import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../shared/shared.dart';
import '../services/health_data_collection_service.dart';
import '../services/health_report_openai_service.dart';
import '../services/health_report_pdf_service.dart';



part 'health_report_provider.g.dart';

/// Health Report OpenAI Service Provider
@riverpod
HealthReportOpenAIService healthReportOpenAIService(Ref ref) {
  return HealthReportOpenAIService();
}

/// Health Report PDF Service Provider
@riverpod
HealthReportPdfService healthReportPdfService(Ref ref) {
  return HealthReportPdfService();
}

/// Health Data Collection Service Provider
@riverpod
HealthDataCollectionService healthDataCollectionService(Ref ref) {
  return HealthDataCollectionService();
}

/// AI 건강 리포트 생성 Provider
@riverpod
Future<String> generateHealthReport(Ref ref, PetProfileEntity pet) async {
  final collectionService = ref.read(healthDataCollectionServiceProvider);
  final aiService = ref.read(healthReportOpenAIServiceProvider);

  // 건강 데이터 수집
  final healthData = await collectionService.collectMonthlyHealthData(pet);

  // 데이터 검증
  if (!collectionService.hasSufficientData(healthData)) {
    throw Exception('健康データが不足しています');
  }

  // AI 리포트 생성
  final petInfo = healthData['petInfo'] as Map<String, dynamic>;
  final health = healthData['healthData'] as Map<String, dynamic>;
  final vaccines = healthData['vaccineData'] as List<Map<String, dynamic>>;
  final weightHistory =
      healthData['weightHistory'] as List<Map<String, dynamic>>;
  final allergies = healthData['allergyInfo'] as Map<String, dynamic>?;

  final result = await aiService.generateMonthlyHealthReport(
    petName: petInfo['name'] as String,
    petType: petInfo['type'] as String,
    petAge: petInfo['age'] as int,
    petWeight: petInfo['weight'] as double,
    healthData: health,
    vaccineData: vaccines,
    weightHistory: weightHistory,
    allergyInfo: allergies,
  );

  if (!result.isSuccess) {
    throw Exception(result.message);
  }

  return result.dataOrNull ?? '';
}

/// PDF 건강 리포트 생성 및 저장 Provider
@riverpod
Future<File> generateHealthReportPdf(Ref ref, PetProfileEntity pet) async {
  try {
    final collectionService = ref.read(healthDataCollectionServiceProvider);
    final pdfService = ref.read(healthReportPdfServiceProvider);

    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('📄 [PROVIDER] PDF 리포트 생성 시작: ${pet.name}');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');

    // 건강 데이터 수집
    final healthData = await collectionService.collectMonthlyHealthData(pet);

    // JSON 데이터 콘솔 출력
    final jsonString = collectionService.convertToJson(healthData);
    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('📊 [PROVIDER] 수집된 건강 데이터 (JSON):');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug(jsonString);
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');

    // AI 리포트 생성
    final aiReport = await ref.read(generateHealthReportProvider(pet).future);

    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('🤖 [PROVIDER] AI 리포트:');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug(aiReport);
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');

    // PDF 생성
    final pdfFile = await pdfService.generateHealthReportPdf(
      petName: pet.name,
      petType: pet.type,
      petAge: pet.age,
      petWeight: pet.weight,
      aiReport: aiReport,
      vaccineData: healthData['vaccineData'] ?? [],
      weightHistory: healthData['weightHistory'] ?? [],
      allergyInfo: healthData['allergyInfo'],
    );

    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('✅ [PROVIDER] PDF 리포트 생성 완료!');
    LoggerService.debug('📁 경로: ${pdfFile.path}');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');
    return pdfFile;
  } catch (e, stackTrace) {
    LoggerService.debug('❌ PDF 리포트 생성 실패: $e');
    LoggerService.debug('Stack trace: $stackTrace');
    rethrow;
  }
}

/// 리포트 생성 가능 여부 확인 Provider
@riverpod
Future<bool> canGenerateReport(Ref ref, PetProfileEntity pet) async {
  final collectionService = ref.read(healthDataCollectionServiceProvider);
  return collectionService.canGenerateReport(pet);
}

/// 건강 데이터를 JSON 파일로 생성하는 Provider
@riverpod
Future<File> generateHealthDataJson(Ref ref, PetProfileEntity pet) async {
  final collectionService = ref.read(healthDataCollectionServiceProvider);

  // 건강 데이터 수집
  final healthData = await collectionService.collectMonthlyHealthData(pet);

  // JSON 파일 생성
  final jsonFile = await collectionService.saveHealthDataAsJson(
    pet,
    healthData,
  );

  return jsonFile;
}

/// AI 건강 리포트 PNG 이미지 생성 Provider
@riverpod
Future<File> generateHealthReportPng(Ref ref, PetProfileEntity pet) async {
  try {
    final collectionService = ref.read(healthDataCollectionServiceProvider);
    final pdfService = ref.read(healthReportPdfServiceProvider);

    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('🖼️ [PROVIDER] PNG 리포트 생성 시작: ${pet.name}');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');

    // 건강 데이터 수집
    final healthData = await collectionService.collectMonthlyHealthData(pet);

    // JSON 데이터 콘솔 출력
    final jsonString = collectionService.convertToJson(healthData);
    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('📊 [PROVIDER] 수집된 건강 데이터 (JSON):');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug(jsonString);
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');

    // AI 리포트 생성
    final aiReport = await ref.read(generateHealthReportProvider(pet).future);

    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('🤖 [PROVIDER] AI 리포트:');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug(aiReport);
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');

    // PNG 생성
    final pngFile = await pdfService.generateHealthReportPng(
      petName: pet.name,
      petType: pet.type,
      petAge: pet.age,
      petWeight: pet.weight,
      aiReport: aiReport,
      vaccineData: healthData['vaccineData'] ?? [],
      weightHistory: healthData['weightHistory'] ?? [],
      allergyInfo: healthData['allergyInfo'],
    );

    LoggerService.debug('');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('✅ [PROVIDER] PNG 리포트 생성 완료!');
    LoggerService.debug('📁 경로: ${pngFile.path}');
    LoggerService.debug('═══════════════════════════════════════════════');
    LoggerService.debug('');
    return pngFile;
  } catch (e, stackTrace) {
    LoggerService.debug('❌ PNG 리포트 생성 실패: $e');
    LoggerService.debug('Stack trace: $stackTrace');
    rethrow;
  }
}
