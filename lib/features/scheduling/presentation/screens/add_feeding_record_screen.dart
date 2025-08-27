import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../controllers/controllers.dart';
import '../widgets/widgets.dart';

/// 급여 기록 추가 페이지
class AddFeedingRecordScreen extends ConsumerStatefulWidget {
  const AddFeedingRecordScreen({super.key});

  @override
  ConsumerState<AddFeedingRecordScreen> createState() =>
      _AddFeedingRecordScreenState();
}

class _AddFeedingRecordScreenState
    extends ConsumerState<AddFeedingRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedMealType = '朝食';
  String _selectedPetId = '1'; // 기본 펫 ID
  Map<String, dynamic>? _selectedPetInfo;
  Map<String, dynamic>? _petSizeGuide;
  List<String> _selectedStatuses = [];
  Map<String, String> _statusValues = {};

  @override
  void initState() {
    super.initState();
    // 컨트롤러를 통해 초기 펫 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addFeedingRecordControllerProvider.notifier).loadPetInfo('1');
    });
  }

  @override
  void dispose() {
    _mealController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 펫 정보 및 사이즈 가이드 로드
  void _loadPetInfo() {
    final petSizes = MockDataService.getMockPetSizesAndFeedingAmounts();
    _selectedPetInfo = petSizes[_selectedPetId];

    if (_selectedPetInfo != null) {
      final size = _selectedPetInfo!['size'] as String;
      final sizeGuide = MockDataService.getPetSizeFeedingGuide();
      _petSizeGuide = sizeGuide[size];
    }

    // 펫 현재 상태 로드
    final currentStatus = MockDataService.getPetCurrentStatus(_selectedPetId);
    if (currentStatus != null) {
      _selectedStatuses = List<String>.from(
        currentStatus['selectedStatuses'] ?? [],
      );
      _statusValues = Map<String, String>.from(currentStatus);
      _statusValues.remove('selectedStatuses');
      _statusValues.remove('lastUpdated');
    } else {
      _selectedStatuses = [];
      _statusValues = {};
    }
  }

  /// 날짜 선택
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 시간 선택
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
  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      // 목업 데이터에 새로운 기록 추가
      _addMockFeedingRecord();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('食事記録を保存しました'),
          backgroundColor: AppColors.pointGreen,
        ),
      );

      Navigator.of(context).pop({
        'date': _selectedDate,
        'time': _selectedTime,
        'mealType': _selectedMealType,
        'meal': _mealController.text,
        'amount': '${_amountController.text}g', // g 단위 추가
        'note': _noteController.text,
      });
    }
  }

  /// 목업 데이터에 새로운 급여 기록 추가
  void _addMockFeedingRecord() {
    // MockDataService에 새로운 기록을 실제로 추가
    final newRecord = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'petId': _selectedPetId,
      'petName': _selectedPetInfo?['name'] ?? 'Max',
      'fedTime': _selectedDate,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'foodType': _mealController.text,
      'foodBrand': 'カスタム',
      'status': 'completed',
      'notes': _noteController.text,
      'createdAt': DateTime.now(),
    };

    // MockDataService에 기록 추가
    MockDataService.addMockFeedingRecord(newRecord);

    // 추가된 기록 확인
    developer.log('새로운 급여 기록이 목업 데이터에 추가되었습니다: $newRecord');
  }

  /// 펫 선택 처리
  void _onPetSelected(String petId) {
    final petSizes = MockDataService.getMockPetSizesAndFeedingAmounts();
    setState(() {
      _selectedPetId = petId;
      _selectedPetInfo = petSizes[petId];
      _loadPetInfo(); // 펫 정보 다시 로드
    });
  }

  /// 펫 상태 선택 다이얼로그 표시
  void _showPetStatusDialog(String petId, Map<String, dynamic> petInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PetStatusSelectionDialog(
          petInfo: petInfo,
          selectedStatuses: List<String>.from(_selectedStatuses),
          statusValues: Map<String, String>.from(_statusValues),
          onStatusUpdated:
              (
                List<String> selectedStatuses,
                Map<String, String> statusValues,
              ) {
                setState(() {
                  _selectedStatuses = selectedStatuses;
                  _statusValues = statusValues;

                  // MockDataService에 상태 업데이트
                  MockDataService.updatePetStatus(
                    petId,
                    selectedStatuses,
                    statusValues,
                  );
                });
              },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '食事記録追加',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveRecord,
            child: Text(
              '保存',
              style: AppFonts.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
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

              // 날짜와 시간 선택
              DateTimeSelector(
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onDateTap: _selectDate,
                onTimeTap: _selectTime,
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

              // 식사 내용 입력
              MealContentInput(
                controller: _mealController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '食事内容を入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // 양 입력
              AmountInput(
                controller: _amountController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '量を入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // 메모 입력
              MemoInput(controller: _noteController),

              const SizedBox(height: AppSpacing.lg),

              // 급여 가이드 카드
              if (_selectedPetInfo != null && _petSizeGuide != null)
                FeedingGuideCard(
                  petInfo: _selectedPetInfo!,
                  sizeGuide: _petSizeGuide!,
                ),

              const Spacer(),

              // 저장 버튼
              SaveButton(onPressed: _saveRecord),
            ],
          ),
        ),
      ),
    );
  }
}
