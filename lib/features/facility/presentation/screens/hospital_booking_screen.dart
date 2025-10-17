import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/settings/data/providers/settings_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HospitalBookingScreen extends ConsumerStatefulWidget {
  final String hospitalId;
  final String? hospitalName;

  const HospitalBookingScreen({
    super.key,
    required this.hospitalId,
    this.hospitalName,
  });

  @override
  ConsumerState<HospitalBookingScreen> createState() =>
      _HospitalBookingScreenState();
}

class _HospitalBookingScreenState extends ConsumerState<HospitalBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _symptomsController = TextEditingController();

  String? _selectedConsultation;
  String? _selectedVisitPurpose;
  PetProfileEntity? _selectedPet;

  final List<String> _consultations = [
    '選択なし',
    '内科',
    '整形外科',
    '皮膚科',
    '眼科',
    '放射線科',
    '耳鼻咽喉科',
    '漢方診療',
    '外科',
    '産科',
    '歯科',
    '臨床病理科',
    '予防医学科',
    '泌尿器科',
  ];
  final List<String> _visitPurposes = ['初診', 'ワクチン接種', '健康診断', '歯科診療', '手術相談'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _loadSelectedPet();
    });
  }

  void _loadUserData() {
    // 유저 프로필에서 실제 데이터 불러오기
    final userProfileAsync = ref.read(userProfileProvider);
    userProfileAsync.whenData((profile) {
      setState(() {
        _nameController.text = profile['name'] ?? '';
        // 전화번호는 프로필에 없을 수 있으므로 기본값 사용
        _phoneController.text = profile['phone'] ?? '010-0000-0000';
      });
    });
  }

  void _loadSelectedPet() {
    // 현재 선택된 펫 가져오기
    final selectedPet = ref.read(selectedPetProfileProvider);
    if (selectedPet != null) {
      setState(() {
        _selectedPet = selectedPet;
      });
    } else {
      // 선택된 펫이 없으면 첫 번째 펫을 기본으로 선택
      final pets = ref.read(petProfilesProvider);
      pets.whenData((petList) {
        if (petList.isNotEmpty) {
          setState(() {
            _selectedPet = petList.first;
          });
          // 전역 상태도 업데이트
          ref
              .read(selectedPetProfileProvider.notifier)
              .selectPet(petList.first);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.pointBrown,
        elevation: 0,
        title: Text(
          widget.hospitalName ?? '病院予約',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pointBrown),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.pointBrown),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 병원 정보 표시
              _buildHospitalInfo(),
              const SizedBox(height: AppSpacing.xl),

              // 예약동물 섹션
              _buildPetSection(),
              const SizedBox(height: AppSpacing.xl),

              // 진료과목 섹션
              _buildConsultationSection(),
              const SizedBox(height: AppSpacing.xl),

              // 방문목적 섹션
              _buildVisitPurposeSection(),
              const SizedBox(height: AppSpacing.xl),

              // 예약메모 섹션
              _buildMemoSection(),
              const SizedBox(height: AppSpacing.xl),

              // 예약 버튼
              _buildBookingButton(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.hospitalName ?? '119동물병원(대구)',
          style: AppFonts.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.textPrimary,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                '대구 달성군 다사읍 달구벌대로 893 (다사읍 매곡리 대실요양병원)',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPetSection() {
    return Consumer(
      builder: (context, ref, child) {
        final petsAsync = ref.watch(petProfilesProvider);

        return petsAsync.when(
          data: (pets) {
            if (pets.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.pets, color: Colors.orange[600], size: 40),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '登録されたペットがありません',
                      style: AppFonts.titleSmall.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'まずペットを登録してください',
                      style: AppFonts.bodySmall.copyWith(
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(color: AppColors.toneLightGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '予約ペット',
                            style: AppFonts.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (_selectedPet != null)
                            Text(
                              '選択済み: ${_selectedPet!.name}',
                              style: AppFonts.bodySmall.copyWith(
                                color: AppColors.pointBrown,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      const Icon(
                        Icons.keyboard_arrow_up,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // 펫 라디오 버튼
                  ...pets.map((pet) => _buildPetRadioButton(pet)),
                  const SizedBox(height: AppSpacing.sm),
                  // 안내 메시지
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '※ インペットに登録されたプロフィールが表示されます',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '※ 1つの項目のみ選択可能です',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              'ペット情報を読み込めません: $error',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetRadioButton(PetProfileEntity pet) {
    final isSelected = _selectedPet?.id == pet.id;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.pointBrown.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: isSelected ? AppColors.pointBrown : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: Row(
        children: [
          Radio<PetProfileEntity>(
            value: pet,
            groupValue: _selectedPet,
            onChanged: (PetProfileEntity? value) {
              setState(() {
                _selectedPet = value;
              });
              if (value != null) {
                ref.read(selectedPetProfileProvider.notifier).selectPet(value);
              }
            },
            activeColor: AppColors.pointBrown,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: AppFonts.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.pointBrown
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  pet.typeName,
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.pointBrown.withValues(alpha: 0.7)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.pointBrown,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                '選択済み',
                style: AppFonts.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConsultationSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.toneLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '診療科目',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 2열 그리드 라디오 버튼
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: _consultations.length,
            itemBuilder: (context, index) {
              final consultation = _consultations[index];
              final isSelected = _selectedConsultation == consultation;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedConsultation = consultation;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.pointBrown.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.pointBrown
                          : AppColors.toneLightGray,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: consultation,
                        groupValue: _selectedConsultation,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedConsultation = value;
                          });
                        },
                        activeColor: AppColors.pointBrown,
                      ),
                      Expanded(
                        child: Text(
                          consultation,
                          style: AppFonts.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.pointBrown
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisitPurposeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.toneLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '来院目的',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 방문목적 라디오 버튼 리스트
          ..._visitPurposes.map(
            (purpose) => _buildVisitPurposeRadioButton(purpose),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitPurposeRadioButton(String purpose) {
    final isSelected = _selectedVisitPurpose == purpose;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Radio<String>(
            value: purpose,
            groupValue: _selectedVisitPurpose,
            onChanged: (String? value) {
              setState(() {
                _selectedVisitPurpose = value;
              });
            },
            activeColor: AppColors.pointBrown,
          ),
          Expanded(
            child: Text(
              purpose,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.toneLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '予約メモ（任意）',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _symptomsController,
            maxLines: 4,
            maxLength: 100,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '予約関連のメモを入力してください',
              hintStyle: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.backgroundGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                borderSide: const BorderSide(
                  color: AppColors.toneLightGray,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                borderSide: const BorderSide(
                  color: AppColors.toneLightGray,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                borderSide: const BorderSide(
                  color: AppColors.pointBrown,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              counterStyle: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      child: ElevatedButton(
        onPressed: null, // 비활성화 상태
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.toneLightGray,
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          elevation: 0,
        ),
        child: Text(
          '次へ',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
