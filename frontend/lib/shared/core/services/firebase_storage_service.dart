import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../domain/result.dart';
import 'firebase_token_service.dart';
import 'logger_service.dart';

/// Firebase Storage를 사용한 이미지 업로드/다운로드 서비스
///
/// 펫 프로필 이미지를 Firebase Storage에 저장하고 관리합니다.
class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 현재 사용자 ID 가져오기
  static String? get _currentUserId {
    return FirebaseTokenService.getCurrentUserId();
  }

  /// 펫 프로필 이미지 업로드
  ///
  /// [petId] 펫 ID
  /// [imagePath] 로컬 이미지 경로
  ///
  /// Returns: 업로드된 이미지의 다운로드 URL
  static Future<Result<String>> uploadPetImage(
    String petId,
    String imagePath,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      print('📤 [Storage] ペット画像アップロード開始');
      LoggerService.debug('📤 Firebase Storage: 펫 이미지 업로드 시작');
      LoggerService.debug('   Pet ID: $petId');
      LoggerService.debug('   Image Path: $imagePath');

      // 이미지 파일 존재 확인
      final file = File(imagePath);
      if (!await file.exists()) {
        print('❌ [Storage] 画像ファイルが見つかりません');
        return Result.failure('画像ファイルが見つかりません');
      }

      // Storage 경로: pets/{userId}/{petId}/profile.jpg
      final ref = _storage
          .ref()
          .child('pets')
          .child(userId)
          .child(petId)
          .child('profile.jpg');

      print('📦 [Storage] アップロード中...');
      LoggerService.debug('   Storage Path: ${ref.fullPath}');

      // 메타데이터 설정
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'petId': petId,
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // 이미지 업로드
      final uploadTask = ref.putFile(file, metadata);

      // 업로드 진행 상황 로그 (디버그 모드에서만)
      if (kDebugMode) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          LoggerService.debug('   Upload Progress: ${progress.toStringAsFixed(1)}%');
        });
      }

      // 업로드 완료 대기
      await uploadTask;

      print('✅ [Storage] アップロード完了');
      LoggerService.debug('✅ Firebase Storage: 업로드 완료');

      // 다운로드 URL 가져오기
      final downloadUrl = await ref.getDownloadURL();

      print('🔗 [Storage] ダウンロードURL取得: $downloadUrl');
      LoggerService.debug('   Download URL: $downloadUrl');

      return Result.success('画像をアップロードしました', downloadUrl);
    } on FirebaseException catch (e) {
      print('❌ [Storage] Firebase エラー: ${e.code} - ${e.message}');
      LoggerService.debug('❌ Firebase Storage Error: ${e.code} - ${e.message}');
      return Result.failure('画像のアップロードに失敗しました: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ [Storage] エラー: $e');
      LoggerService.debug('❌ Firebase Storage: 이미지 업로드 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
      return Result.failure('画像のアップロードに失敗しました: $e');
    }
  }

  /// 펫 프로필 이미지 다운로드 URL 가져오기
  ///
  /// [petId] 펫 ID
  ///
  /// Returns: 다운로드 URL
  static Future<Result<String>> getPetImageUrl(String petId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 Firebase Storage: 펫 이미지 URL 조회 (petId: $petId)');

      final ref = _storage
          .ref()
          .child('pets')
          .child(userId)
          .child(petId)
          .child('profile.jpg');

      final downloadUrl = await ref.getDownloadURL();

      LoggerService.debug('✅ Firebase Storage: URL 조회 성공');
      return Result.success('画像URLを取得しました', downloadUrl);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        LoggerService.debug('⚠️ Firebase Storage: 이미지 없음 (petId: $petId)');
        return Result.failure('画像が見つかりません');
      }

      LoggerService.debug('❌ Firebase Storage Error: ${e.code} - ${e.message}');
      return Result.failure('画像URLの取得に失敗しました: ${e.message}');
    } catch (e) {
      LoggerService.debug('❌ Firebase Storage: URL 조회 실패: $e');
      return Result.failure('画像URLの取得に失敗しました: $e');
    }
  }

  /// 펫 프로필 이미지 삭제
  ///
  /// [petId] 펫 ID
  static Future<Result<void>> deletePetImage(String petId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      print('🗑️ [Storage] ペット画像削除開始');
      LoggerService.debug('🗑️ Firebase Storage: 펫 이미지 삭제 시작 (petId: $petId)');

      final ref = _storage
          .ref()
          .child('pets')
          .child(userId)
          .child(petId)
          .child('profile.jpg');

      await ref.delete();

      print('✅ [Storage] 画像削除完了');
      LoggerService.debug('✅ Firebase Storage: 이미지 삭제 완료');

      return Result.success('画像を削除しました');
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('⚠️ [Storage] 削除する画像が見つかりません');
        LoggerService.debug('⚠️ Firebase Storage: 삭제할 이미지 없음');
        // 이미 없으므로 성공으로 간주
        return Result.success('画像は既に削除されています');
      }

      print('❌ [Storage] Firebase エラー: ${e.code}');
      LoggerService.debug('❌ Firebase Storage Error: ${e.code} - ${e.message}');
      return Result.failure('画像の削除に失敗しました: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ [Storage] エラー: $e');
      LoggerService.debug('❌ Firebase Storage: 이미지 삭제 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
      return Result.failure('画像の削除に失敗しました: $e');
    }
  }

  /// 펫 이미지가 존재하는지 확인
  ///
  /// [petId] 펫 ID
  ///
  /// Returns: true if exists
  static Future<bool> petImageExists(String petId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return false;
      }

      final ref = _storage
          .ref()
          .child('pets')
          .child(userId)
          .child(petId)
          .child('profile.jpg');

      // 메타데이터 조회로 존재 여부 확인 (다운로드보다 가볍음)
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
