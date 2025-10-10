import 'dart:developer' as developer;

import 'package:aipet_frontend/features/scheduling/data/services/feeding_local_storage_service.dart';
import 'package:aipet_frontend/features/scheduling/presentation/widgets/scheduling_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 급여 스케줄 편집 페이지
class FeedingScheduleEditScreen extends ConsumerStatefulWidget {
  final String mealType; // 朝食, 昼食, 夕食
  final String currentTime;
  final String currentAmount;
  final String petId; // 펫 ID 추가

  const FeedingScheduleEditScreen({
    super.key,
    required this.mealType,
    required this.currentTime,
    required this.currentAmount,
    this.petId = '1', // 기본값으로 '1' 설정
  });

  @override
  ConsumerState<FeedingScheduleEditScreen> createState() =>
      _FeedingScheduleEditScreenState();
}

class _FeedingScheduleEditScreenState
    extends ConsumerState<FeedingScheduleEditScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _amountController;
  late String _selectedMealType;
  late String _selectedPetId;
  late Map<String, dynamic>? _selectedPetInfo;
  late Map<String, dynamic>? _petSizeGuide;
  late List<String> _selectedStatuses;
  late Map<String, String> _statusValues;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedMealType = widget.mealType;
    _selectedPetId = widget.petId;

    // 현재 시간 파싱 (예: "08:00" → TimeOfDay(8, 0))
    final timeParts = widget.currentTime.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    // g 단위 제거하고 숫자만 저장
    final amountText = widget.currentAmount.replaceAll('g', '');
    _amountController = TextEditingController(text: amountText);

    // 펫 정보 및 사이즈 가이드 로드
    _loadPetInfo();
  }

  /// 펫 정보 및 사이즈 가이드 로드
  Future<void> _loadPetInfo() async {
    final petSizes = FeedingLocalStorageService.getPetSizeFeedingInfo();
    _selectedPetInfo = petSizes[_selectedPetId];

    if (_selectedPetInfo != null) {
      final size = _selectedPetInfo!['size'] as String;
      final sizeGuide = FeedingLocalStorageService.getPetSizeFeedingGuide();
      _petSizeGuide = sizeGuide[size];
    }

    // 펫 현재 상태 로드
    final currentStatus = await FeedingLocalStorageService.getPetStatus(
      _selectedPetId,
    );
    setState(() {
      _selectedStatuses = List<String>.from(
        currentStatus['selectedStatuses'] ?? [],
      );
      _statusValues = Map<String, String>.from(currentStatus);
      _statusValues.remove('selectedStatuses');
      _statusValues.remove('lastUpdated');
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 펫 선택 처리
  void _onPetSelected(String petId) {
    final petSizes = FeedingLocalStorageService.getPetSizeFeedingInfo();
    setState(() {
      _selectedPetId = petId;
      _selectedPetInfo = petSizes[petId];
    });
    _loadPetInfo();
  }

  /// 펫 상태 선택 다이얼로그 표시
  void _showPetStatusDialog(String petId, Map<String, dynamic> petInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final statusOptions = FeedingLocalStorageService.getPetStatusOptions();
        return PetStatusSelectionDialog(
          petInfo: petInfo,
          selectedStatuses: List<String>.from(_selectedStatuses),
          statusValues: Map<String, String>.from(_statusValues),
          statusOptions: statusOptions
              .map(
                (option) => {
                  'id': option,
                  'title': option,
                  'description': '',
                  'icon': Icons.pets,
                  'options': [option],
                },
              )
              .toList(),
          onStatusUpdated:
              (
                List<String> selectedStatuses,
                Map<String, String> statusValues,
              ) async {
                setState(() {
                  _selectedStatuses = selectedStatuses;
                  _statusValues = statusValues;
                });

                // 로컬 저장소에 상태 업데이트
                await FeedingLocalStorageService.updatePetStatus(
                  petId,
                  statusValues,
                );
              },
        );
      },
    );
  }

  /// 시간 선택 다이얼로그 표시
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pointBrown,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// 저장 처리
  Future<void> _saveSchedule() async {
    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final amount = '${_amountController.text}g';

    // 로컬 저장소 업데이트
    await _updateLocalData(_selectedMealType, timeString, amount);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_selectedMealTypeのスケジュールを保存しました'),
          backgroundColor: AppColors.pointGreen,
        ),
      );

      context.pop({
        'mealType': _selectedMealType,
        'time': timeString,
        'amount': amount,
      });
    }
  }

  /// 로컬 저장소 데이터 업데이트
  Future<void> _updateLocalData(
    String mealType,
    String time,
    String amount,
  ) async {
    await FeedingLocalStorageService.updateFeedingSchedule(
      mealType,
      time,
      amount,
    );
    developer.log('로컬 저장소 업데이트: $mealType - $time - $amount');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: '$_selectedMealTypeスケジュール編集',
        actions: [
          TextButton(
            onPressed: _saveSchedule,
            child: Text(
              '保存',
              style: AppFonts.bodyMedium.copyWith(
                color: const Color(0xFF5B4034),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 펫 선택 그리드
                    PetSelectionGrid(
                      selectedPetId: _selectedPetId,
                      selectedStatuses: _selectedStatuses,
                      onPetSelected: _onPetSelected,
                      onPetStatusDialog: _showPetStatusDialog,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 식사 타입 선택
                    MealTypeDropdown(
                      selectedMealType: _selectedMealType,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMealType = newValue;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 시간 설정
                    TimeSelector(
                      title: '時間設定',
                      selectedTime: _selectedTime,
                      onTimeTap: _selectTime,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 양 설정
                    AmountInput(controller: _amountController),

                    const SizedBox(height: AppSpacing.lg),

                    // 급여 가이드 카드
                    if (_selectedPetInfo != null && _petSizeGuide != null)
                      FeedingGuideCard(
                        petInfo: _selectedPetInfo!,
                        sizeGuide: _petSizeGuide!,
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    ActionButton.primary(
                      text: '保存',
                      onPressed: _saveSchedule,
                      isEnabled: true,
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
