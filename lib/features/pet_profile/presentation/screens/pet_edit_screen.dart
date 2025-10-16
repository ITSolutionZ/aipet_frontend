import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/tabs/helpers/pet_info_image_helper.dart';

/// 펫 편집 화면
class PetEditScreen extends ConsumerStatefulWidget {
  final PetProfileEntity pet;

  const PetEditScreen({super.key, required this.pet});

  @override
  ConsumerState<PetEditScreen> createState() => _PetEditScreenState();
}

class _PetEditScreenState extends ConsumerState<PetEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 폼 컨트롤러들
  late final TextEditingController _nameController;
  late final TextEditingController _registrationController;

  // 선택된 값들
  String? _selectedSpecies;
  String? _selectedBreed;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _isBirthDateUnknown = false;

  // 관심사 선택
  final List<String> _selectedDiseases = [];
  final List<String> _selectedFunctionalFoods = [];

  // 프로필 이미지
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// 폼 초기화
  void _initializeForm() {
    _nameController = TextEditingController(text: widget.pet.name);
    _registrationController = TextEditingController(
      text: widget.pet.additionalInfo?['registrationNumber']?.toString() ?? '',
    );

    _selectedSpecies = widget.pet.type;
    _selectedBreed = widget.pet.breed;
    _selectedGender = widget.pet.gender;
    _selectedBirthDate = widget.pet.birthDate;
    _selectedImagePath = widget.pet.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  /// 앱바 구성
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        '반려동물 수정',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _showDeleteDialog,
          child: const Text(
            '삭제',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ],
    );
  }

  /// 본문 구성
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImageSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildNameField(),
            const SizedBox(height: AppSpacing.lg),
            _buildSpeciesBreedSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildGenderSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildBirthDateSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildRegistrationNumberField(),
            const SizedBox(height: AppSpacing.lg),
            _buildInterestsSection(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// 프로필 이미지 섹션
  Widget _buildProfileImageSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _selectedImagePath != null
                  ? PetInfoImageHelper.buildImageWidget(_selectedImagePath!)
                  : Container(
                      color: AppColors.pointGray.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.pets,
                        size: 40,
                        color: AppColors.pointGray,
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePicker,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 이름 필드
  Widget _buildNameField() {
    return _buildFormField(
      label: '반려동물 이름',
      isRequired: true,
      child: TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          hintText: '이름을 입력해주세요',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '이름을 입력해주세요';
          }
          return null;
        },
      ),
    );
  }

  /// 종/품종 섹션
  Widget _buildSpeciesBreedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField(
          label: '종 / 품종 선택',
          isRequired: true,
          child: Column(
            children: [
              _buildDropdown(
                value: _selectedSpecies,
                hint: '종을 선택해주세요',
                items: const ['개', '고양이', '기타'],
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value;
                    _selectedBreed = null; // 종이 바뀌면 품종 초기화
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDropdown(
                value: _selectedBreed,
                hint: '품종을 선택해주세요',
                items: _getBreedOptions(_selectedSpecies),
                onChanged: (value) {
                  setState(() {
                    _selectedBreed = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 성별 섹션
  Widget _buildGenderSection() {
    return _buildFormField(
      label: '성별',
      isRequired: true,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildGenderOption('수컷', 'Male')),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildGenderOption('암컷', 'Female')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildGenderOption('모름', 'Unknown')),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildGenderOption('수컷(중성화)', 'Male_Neutered')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildGenderOption('암컷(중성화)', 'Female_Spayed')),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  /// 생년월일 섹션
  Widget _buildBirthDateSection() {
    return _buildFormField(
      label: '생년월일',
      isRequired: true,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: _isBirthDateUnknown ? '나이추정불가' : _formatBirthDate(),
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: _isBirthDateUnknown ? null : _showDatePicker,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: _toggleBirthDateUnknown,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBirthDateUnknown
                    ? Colors.blue
                    : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('모름'),
            ),
          ),
        ],
      ),
    );
  }

  /// 동물 등록 번호 필드
  Widget _buildRegistrationNumberField() {
    return _buildFormField(
      label: '동물 등록 번호',
      isRequired: false,
      child: TextFormField(
        controller: _registrationController,
        decoration: const InputDecoration(
          hintText: '동물 등록 번호를 입력해주세요.',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// 관심사 섹션
  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField(
          label: '관심사 선택',
          isRequired: false,
          child: Column(
            children: [
              _buildDropdown(
                value: _selectedDiseases.isNotEmpty
                    ? '${_selectedDiseases.length}개 선택됨'
                    : null,
                hint: '(최대 3개까지 선택 가능)',
                items: const ['걱정되는 질병'],
                onChanged: (value) => _showDiseaseSelectionDialog(),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDropdown(
                value: _selectedFunctionalFoods.isNotEmpty
                    ? '${_selectedFunctionalFoods.length}개 선택됨'
                    : null,
                hint: '(최대 3개까지 선택 가능)',
                items: const ['관심있는 기능성 사료'],
                onChanged: (value) => _showFunctionalFoodSelectionDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: _toggleProfileVisibility,
            child: const Text('프로필 숨기기', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('수정 완료', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  /// 폼 필드 래퍼
  Widget _buildFormField({
    required String label,
    required bool isRequired,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }

  /// 드롭다운 위젯
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  /// 성별 옵션
  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedGender,
              onChanged: (val) {
                setState(() {
                  _selectedGender = val;
                });
              },
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 품종 옵션 가져오기
  List<String> _getBreedOptions(String? species) {
    switch (species) {
      case '개':
        return ['아이누견', '푸들', '골든 리트리버', '시바견', '치와와', '포메라니안'];
      case '고양이':
        return ['페르시안', '러시안 블루', '메인쿤', '스코티시 폴드', '샴', '터키시 앙고라'];
      default:
        return ['기타'];
    }
  }

  /// 생년월일 포맷팅
  String _formatBirthDate() {
    if (_selectedBirthDate == null) return '생년월일을 선택해주세요';
    return '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일';
  }

  /// 이미지 선택기 표시
  void _showImagePicker() {
    // TODO: 이미지 선택 로직 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이미지 선택 기능을 구현해주세요')));
  }

  /// 날짜 선택기 표시
  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedBirthDate = date;
        _isBirthDateUnknown = false;
      });
    }
  }

  /// 생년월일 모름 토글
  void _toggleBirthDateUnknown() {
    setState(() {
      _isBirthDateUnknown = !_isBirthDateUnknown;
      if (_isBirthDateUnknown) {
        _selectedBirthDate = null;
      }
    });
  }

  /// 질병 선택 다이얼로그
  void _showDiseaseSelectionDialog() {
    // TODO: 질병 선택 다이얼로그 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('질병 선택 다이얼로그를 구현해주세요')));
  }

  /// 기능성 사료 선택 다이얼로그
  void _showFunctionalFoodSelectionDialog() {
    // TODO: 기능성 사료 선택 다이얼로그 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('기능성 사료 선택 다이얼로그를 구현해주세요')));
  }

  /// 프로필 공개/비공개 토글
  void _toggleProfileVisibility() {
    // TODO: 프로필 공개/비공개 토글 로직 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('프로필 공개/비공개 기능을 구현해주세요')));
  }

  /// 삭제 다이얼로그 표시
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('펫 삭제'),
        content: const Text('정말로 이 펫을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 펫 삭제
  void _deletePet() {
    // TODO: 펫 삭제 로직 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('펫 삭제 기능을 구현해주세요')));
  }

  /// 변경사항 저장
  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO: 변경사항 저장 로직 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('변경사항이 저장되었습니다')));

    Navigator.pop(context);
  }
}
