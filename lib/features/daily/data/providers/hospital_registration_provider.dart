import 'dart:convert';

import 'package:aipet_frontend/shared/core/services/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hospital_registration_provider.g.dart';

/// 등록된 병원 정보 모델
class RegisteredHospital {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final DateTime registeredAt;

  RegisteredHospital({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'phoneNumber': phoneNumber,
    'registeredAt': registeredAt.toIso8601String(),
  };

  factory RegisteredHospital.fromJson(Map<String, dynamic> json) =>
      RegisteredHospital(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        phoneNumber: json['phoneNumber'] as String,
        registeredAt: DateTime.parse(json['registeredAt'] as String),
      );
}

/// 등록된 동물병원 관리 프로바이더
@riverpod
class RegisteredHospitalsNotifier extends _$RegisteredHospitalsNotifier {
  @override
  Future<List<RegisteredHospital>> build() async {
    try {
      final hospitalsJsonString = await SecureStorageService.getString(
        'registered_hospitals',
      );

      if (hospitalsJsonString != null) {
        final List<dynamic> hospitalsJson =
            jsonDecode(hospitalsJsonString) as List<dynamic>;
        final hospitalsList = hospitalsJson
            .map(
              (json) =>
                  RegisteredHospital.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        return hospitalsList;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 병원 등록
  Future<void> addHospital(RegisteredHospital hospital) async {
    final currentHospitals = await future;
    final updatedHospitals = [...currentHospitals, hospital];

    await _saveToStorage(updatedHospitals);
    state = AsyncValue.data(updatedHospitals);
  }

  /// 병원 제거
  Future<void> removeHospital(String hospitalId) async {
    final currentHospitals = await future;
    final updatedHospitals = currentHospitals
        .where((hospital) => hospital.id != hospitalId)
        .toList();

    await _saveToStorage(updatedHospitals);
    state = AsyncValue.data(updatedHospitals);
  }

  /// 병원 존재 여부 확인
  bool isHospitalRegistered(String hospitalId) {
    return state.maybeWhen(
      data: (hospitals) => hospitals.any((h) => h.id == hospitalId),
      orElse: () => false,
    );
  }

  /// 스토리지에 저장
  Future<void> _saveToStorage(List<RegisteredHospital> hospitals) async {
    try {
      final hospitalsJson = hospitals.map((h) => h.toJson()).toList();
      final hospitalsJsonString = jsonEncode(hospitalsJson);
      await SecureStorageService.setString(
        'registered_hospitals',
        hospitalsJsonString,
      );
    } catch (e) {
      // 에러 로깅
      if (kDebugMode) {
        LoggerService.debug('병원 정보 저장 실패: $e');
      }
    }
  }
}

/// 등록된 병원 여부 확인 프로바이더
@riverpod
bool hasRegisteredHospital(Ref ref) {
  final hospitals = ref.watch(registeredHospitalsProvider);
  return hospitals.maybeWhen(
    data: (hospitalList) => hospitalList.isNotEmpty,
    orElse: () => false,
  );
}
