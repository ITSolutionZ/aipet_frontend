import 'package:aipet_frontend/features/settings/data/data.dart';
import 'package:aipet_frontend/shared/services/postal_code_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 位置設定画面
class LocationSettingScreen extends ConsumerStatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  ConsumerState<LocationSettingScreen> createState() =>
      _LocationSettingScreenState();
}

class _LocationSettingScreenState extends ConsumerState<LocationSettingScreen> {
  final _postalCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();

  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 저장된 위치 정보 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedLocation();
    });
  }

  /// 저장된 위치 정보 불러오기
  Future<void> _loadSavedLocation() async {
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.getUserLocation();

    if (result.isSuccess && result.data != null) {
      final location = result.data!;
      setState(() {
        _postalCodeController.text = location['postalCode'] ?? '';
        _addressController.text = location['address'] ?? '';
        _detailAddressController.text = location['detailAddress'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _postalCodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  /// 郵便番号検索
  Future<void> _searchPostalCode() async {
    final postalCode = _postalCodeController.text.trim();

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final result = await PostalCodeService.searchByPostalCode(postalCode);

    if (mounted) {
      setState(() {
        _isSearching = false;
      });

      if (result.isSuccess && result.data != null) {
        _addressController.text = result.data!.fullAddress;
        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    }
  }

  /// 保存処理
  Future<void> _saveLocation() async {
    final postalCode = _postalCodeController.text.trim();
    final address = _addressController.text.trim();
    final detailAddress = _detailAddressController.text.trim();

    if (postalCode.isEmpty || address.isEmpty) {
      UiService.showError(context, '郵便番号と住所を入力してください');
      return;
    }

    // 確認ダイアログを表示
    final confirmed = await UiService.showConfirmDialog(
      context,
      title: '位置情報の確認',
      content:
          '以下の住所で保存します。\nよろしいですか？\n\n$address${detailAddress.isNotEmpty ? '\n$detailAddress' : ''}',
      confirmText: '保存',
      cancelText: 'キャンセル',
    );

    if (!confirmed) return;

    // 위치 정보 저장
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.saveUserLocation(
      postalCode: postalCode,
      address: address,
      detailAddress: detailAddress,
    );

    if (mounted) {
      if (result.isSuccess) {
        UiService.showSuccess(context, '位置情報を保存しました');
        Navigator.of(context).pop();
      } else {
        UiService.showError(context, result.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const GradientAppBar(
        title: null, // タイトルを削除
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 郵便番号入力
            Text(
              '郵便番号',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '123-4567',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        borderSide: BorderSide.none,
                      ),
                      errorText: _errorMessage,
                    ),
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchPostalCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('検索'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 住所表示・編集
            Row(
              children: [
                Text(
                  '住所',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '※ 住所を確認して修正してください',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.pointBrown,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: '住所を入力または修正してください',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 詳細住所入力
            Text(
              '詳細住所（建物名・部屋番号など）',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _detailAddressController,
              decoration: InputDecoration(
                hintText: '例: ○○マンション 101号室',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 保存ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                child: const Text(
                  '保存',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
