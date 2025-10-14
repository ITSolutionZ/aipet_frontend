import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/settings/data/providers/settings_providers.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/reservation_provider.dart';

/// 予約状態列挙型
enum BookingStatus {
  available('◎', Colors.green, '予約可能'),
  consultation('◉', Colors.orange, '相談'),
  unavailable('×', Colors.grey, '予約不可');

  const BookingStatus(this.symbol, this.color, this.label);
  final String symbol;
  final Color color;
  final String label;
}

class FacilityBookingScreen extends ConsumerStatefulWidget {
  final String facilityName;
  final String facilityType;
  final String? facilityId;

  const FacilityBookingScreen({
    super.key,
    required this.facilityName,
    required this.facilityType,
    this.facilityId,
  });

  @override
  ConsumerState<FacilityBookingScreen> createState() =>
      _FacilityBookingScreenState();
}

class _FacilityBookingScreenState extends ConsumerState<FacilityBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPetId;
  String? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  PetProfileEntity? _selectedPet;
  bool _isPetSelectorExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _loadDefaultPet();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// ユーザープロフィール情報の読み込み
  void _loadUserProfile() {
    final userProfileAsync = ref.read(userProfileNotifierProvider);
    userProfileAsync.whenData((profile) {
      _nameController.text = profile['name'] ?? '';
      // 電話番号はデフォルト値で設定
      if (_phoneController.text.isEmpty) {
        _phoneController.text = '010-0000-0000';
      }
    });
  }

  /// デフォルトペット選択 (最初のペット)
  void _loadDefaultPet() {
    final petsAsync = ref.read(petProfilesNotifierProvider);
    petsAsync.whenData((pets) {
      if (pets.isNotEmpty && _selectedPet == null) {
        setState(() {
          _selectedPet = pets.first;
          _selectedPetId = pets.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB89B8A), // ブラウングラデーション開始
              Color(0xFFA08A7A), // ブラウングラデーション中間
              Color(0xFF967E6D), // ブラウングラデーション終了
            ],
          ),
        ),
        child: Column(
          children: [
            // 시설 정보 헤더 섹션
            _buildFacilityInfoHeader(),
            // 메인 콘텐츠
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundGray,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),

                        // 施設情報表示
                        _buildFacilityInfo(),
                        const SizedBox(height: AppSpacing.xl),

                        // 予約者情報
                        _buildSectionTitle('予約者情報'),
                        const SizedBox(height: AppSpacing.md),
                        _buildTextFormField(
                          controller: _nameController,
                          label: '予約者名',
                          hint: '予約者名を入力してください',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '予約者名を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTextFormField(
                          controller: _phoneController,
                          label: '連絡先',
                          hint: '010-0000-0000',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '連絡先を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ペット情報
                        _buildSectionTitle('ペット情報'),
                        const SizedBox(height: AppSpacing.md),
                        _buildPetSelector(),
                        const SizedBox(height: AppSpacing.xl),

                        // サービス選択
                        _buildSectionTitle('サービス選択'),
                        const SizedBox(height: AppSpacing.md),
                        _buildServiceSelector(),
                        const SizedBox(height: AppSpacing.xl),

                        // 予約日時
                        _buildSectionTitle('予約日時'),
                        const SizedBox(height: AppSpacing.md),
                        _buildDateTimeSelector(),
                        const SizedBox(height: AppSpacing.xl),

                        // 特記事項
                        _buildSectionTitle('特記事項'),
                        const SizedBox(height: AppSpacing.md),
                        _buildTextFormField(
                          controller: _notesController,
                          label: '特記事項',
                          hint: '予約時の参考事項を入力してください（任意）',
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 予約ボタン
                        _buildBookingButton(),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.pointBrown,
      foregroundColor: AppColors.pointOffWhite,
      elevation: 0,
      centerTitle: true,
      title: Text(
        '${widget.facilityType} 予約',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFacilityInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(_getFacilityIcon(), color: AppColors.pointGreen, size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.facilityName,
                        style: AppFonts.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.facilityType,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(_getFacilityIcon(), color: Colors.blue[700], size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.facilityName,
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${widget.facilityType}の予約を進めます',
                  style: AppFonts.bodySmall.copyWith(color: Colors.blue[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.titleSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              borderSide: const BorderSide(color: AppColors.pointGreen),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildPetSelector() {
    return Consumer(
      builder: (context, ref, child) {
        final petsAsync = ref.watch(petProfilesNotifierProvider);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ペット選択',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // ペット選択ヘッダー (常時表示)
              InkWell(
                onTap: () {
                  setState(() {
                    _isPetSelectorExpanded = !_isPetSelectorExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pets, color: AppColors.pointGreen),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _selectedPet != null
                              ? _selectedPet!.name
                              : 'ペットを選択してください',
                          style: AppFonts.bodyMedium.copyWith(
                            color: _selectedPet != null
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isPetSelectorExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ペットリスト (アコーディオン形式で展開)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isPetSelectorExpanded ? null : 0,
                child: _isPetSelectorExpanded
                    ? petsAsync.when(
                        data: (pets) {
                          if (pets.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.pets,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    '登録されたペットがありません',
                                    style: AppFonts.bodyMedium.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.push('/pet-registration');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.pointBrown,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('ペット登録'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            margin: const EdgeInsets.only(top: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.sm,
                              ),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: pets.map((pet) {
                                final isSelected = _selectedPet?.id == pet.id;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedPet = pet;
                                      _selectedPetId = pet.id;
                                      _isPetSelectorExpanded = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.pointBrown.withValues(
                                              alpha: 0.05,
                                            )
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.sm,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // 펫 이미지
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: AppColors.pointBrown
                                              .withValues(alpha: 0.1),
                                          backgroundImage: pet.imagePath != null
                                              ? AssetImage(pet.imagePath!)
                                              : null,
                                          child: pet.imagePath == null
                                              ? Text(
                                                  pet.typeIcon,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        // 펫 정보
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pet.name,
                                                style: AppFonts.bodyMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isSelected
                                                          ? AppColors.pointBrown
                                                          : AppColors
                                                                .textPrimary,
                                                    ),
                                              ),
                                              Text(
                                                pet.typeName,
                                                style: AppFonts.bodySmall
                                                    .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 선택 표시
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppColors.pointBrown,
                                            size: 20,
                                          )
                                        else
                                          const Icon(
                                            Icons.radio_button_unchecked,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () => Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'ペット情報の読み込み失敗',
                                style: AppFonts.bodyMedium.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                error.toString(),
                                style: AppFonts.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceSelector() {
    final services = _getServicesForFacilityType();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'サービス選択',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: _selectedService,
            decoration: InputDecoration(
              hintText: 'サービスを選択してください',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: const BorderSide(color: AppColors.pointGreen),
              ),
            ),
            items: services.map((service) {
              return DropdownMenuItem(value: service, child: Text(service));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedService = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'サービスを選択してください';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return InkWell(
      onTap: () => _showDateTimeBottomSheet(),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.pointGreen),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '예約日時',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _selectedDate != null && _selectedTimeSlot != null
                        ? '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日 $_selectedTimeSlot'
                        : _selectedDate != null
                        ? '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日'
                        : '日時を選択してください',
                    style: AppFonts.bodyMedium.copyWith(
                      color: _selectedDate != null
                          ? Colors.black87
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  bool _isHoliday(DateTime date) {
    // 공휴일 체크 (예시)
    final holidays = [
      DateTime(2024, 1, 1), // 신정
      DateTime(2024, 2, 10), // 설날
      DateTime(2024, 2, 11), // 설날
      DateTime(2024, 2, 12), // 설날
      DateTime(2024, 3, 1), // 삼일절
      DateTime(2024, 5, 5), // 어린이날
      DateTime(2024, 5, 15), // 부처님오신날
      DateTime(2024, 6, 6), // 현충일
      DateTime(2024, 8, 15), // 광복절
      DateTime(2024, 9, 17), // 추석
      DateTime(2024, 9, 18), // 추석
      DateTime(2024, 9, 19), // 추석
      DateTime(2024, 10, 3), // 개천절
      DateTime(2024, 10, 9), // 한글날
      DateTime(2024, 12, 25), // 크리스마스
    ];

    return holidays.any(
      (holiday) =>
          holiday.year == date.year &&
          holiday.month == date.month &&
          holiday.day == date.day,
    );
  }

  /// 요일 헤더 빌드

  /// 2주간 캘린더 그리드 빌드 (가로: 날짜, 세로: 시간)
  Widget _buildTwoWeekCalendar(
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    final today = DateTime.now();
    final twoWeeks = <DateTime>[];

    // 오늘부터 2주간 (14일) 날짜 생성
    for (int i = 0; i < 14; i++) {
      twoWeeks.add(DateTime(today.year, today.month, today.day + i));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          // 헤더 (요일)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.sm),
                topRight: Radius.circular(AppSpacing.sm),
              ),
            ),
            child: Row(
              children: [
                // 시간 컬럼 헤더
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      '時間',
                      style: AppFonts.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                // 날짜 헤더 (2주간)
                ...twoWeeks.map((date) {
                  final isSelected =
                      selectedDate != null &&
                      selectedDate.year == date.year &&
                      selectedDate.month == date.month &&
                      selectedDate.day == date.day;
                  final isToday =
                      date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                  final weekday = date.weekday % 7;
                  final isSunday = weekday == 0;
                  final isSaturday = weekday == 6;

                  return Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => onDateSelected(date),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.pointBrown
                              : isToday
                              ? AppColors.pointBrown.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text(
                              ['日', '月', '火', '水', '木', '金', '土'][weekday],
                              style: AppFonts.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isSunday
                                    ? Colors.red
                                    : isSaturday
                                    ? Colors.blue
                                    : AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${date.day}',
                              style: AppFonts.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? AppColors.pointBrown
                                    : AppColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // 시간대별 행들
          ...List.generate(9, (hourIndex) {
            final hour = 9 + hourIndex; // 9시부터 17시까지
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  // 시간 라벨
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: AppFonts.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 각 날짜별 시간 슬롯
                  ...twoWeeks.map((date) {
                    final isAvailable = _isTimeSlotAvailable(date, hour);
                    final isSelected =
                        selectedDate != null &&
                        selectedDate.year == date.year &&
                        selectedDate.month == date.month &&
                        selectedDate.day == date.day;

                    return Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: isAvailable ? () => onDateSelected(date) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? (isSelected
                                      ? AppColors.pointBrown.withValues(
                                          alpha: 0.2,
                                        )
                                      : Colors.white)
                                : Colors.grey[100],
                            border: Border(
                              right: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isAvailable ? '○' : '✗',
                              style: AppFonts.bodySmall.copyWith(
                                color: isAvailable
                                    ? Colors.green[600]
                                    : Colors.red[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 특정 날짜와 시간이 예약 가능한지 확인
  bool _isTimeSlotAvailable(DateTime date, int hour) {
    final status = _getBookingStatus(date);

    // 예약 불가능한 날짜
    if (status == BookingStatus.unavailable) {
      return false;
    }

    // 상담만 가능한 날짜는 특정 시간만 가능
    if (status == BookingStatus.consultation) {
      return hour >= 14 && hour < 16;
    }

    // 일반 예약 가능한 날짜
    return hour >= 9 && hour < 18;
  }

  /// 날짜별 예약 상태 확인
  BookingStatus _getBookingStatus(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    // 과거 날짜는 불가능
    if (checkDate.isBefore(today)) {
      return BookingStatus.unavailable;
    }

    // 30일 이후는 불가능
    if (checkDate.isAfter(today.add(const Duration(days: 30)))) {
      return BookingStatus.unavailable;
    }

    // 주말 제외
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return BookingStatus.unavailable;
    }

    // 공휴일 제외
    if (_isHoliday(date)) {
      return BookingStatus.unavailable;
    }

    // 특정 날짜는 상담만 가능 (예시)
    final consultationOnlyDates = [8, 15, 22]; // 매주 특정 요일
    if (consultationOnlyDates.contains(date.day)) {
      return BookingStatus.consultation;
    }

    // 특정 날짜는 예약 불가 (예시)
    final unavailableDates = [10, 17, 24]; // 매주 특정 요일
    if (unavailableDates.contains(date.day)) {
      return BookingStatus.unavailable;
    }

    // 기본적으로 예약 가능
    return BookingStatus.available;
  }

  /// 캘린더 범례 빌드

  /// 날짜 및 시간 선택 바텀시트
  void _showDateTimeBottomSheet() {
    DateTime? tempSelectedDate = _selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '予約日時選択',
                        style: AppFonts.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 날짜 섹션
                        Text(
                          '日付選択',
                          style: AppFonts.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.pointBrown,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // 2주간 캘린더
                        _buildTwoWeekCalendar(tempSelectedDate, (date) {
                          setModalState(() {
                            tempSelectedDate = date;
                          });
                        }),
                      ],
                    ),
                  ),
                ),
                // 확인 버튼
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: tempSelectedDate != null
                          ? () {
                              setState(() {
                                _selectedDate = tempSelectedDate;
                                // 시간 슬롯은 기본값으로 설정 (9:00)
                                _selectedTimeSlot = '09:00';
                              });
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        '確認',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
        child: const Text(
          '予約する',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  IconData _getFacilityIcon() {
    switch (widget.facilityType) {
      case '美容室':
      case '미용실':
        return Icons.content_cut;
      case 'カフェ':
      case '카페':
        return Icons.local_cafe;
      case 'ホテル':
      case '호텔':
        return Icons.hotel;
      case '遊び場':
      case '놀이터':
        return Icons.park;
      case '教育センター':
      case '교육센터':
        return Icons.school;
      default:
        return Icons.place;
    }
  }

  List<String> _getServicesForFacilityType() {
    switch (widget.facilityType) {
      case '病院':
      case '병원':
        return [
          '一般診療',
          '予防接種',
          '健康診断',
          '内科診療',
          '外科手術',
          '応急処置',
          '歯科診療',
          '眼科診療',
          '皮膚科診療',
          '整形外科診療',
          '産科診療',
          '去勢・避妊手術',
          'ワクチン接種',
          '血液検査',
          'X線撮影',
          '超音波検査',
        ];
      case '美容室':
      case '미용실':
        return [
          '基本美容',
          '全身美容',
          '爪のケア',
          '入浴',
          'ドライング',
          '毛のカット',
          'ネイルケア',
          '耳のクリーニング',
          'スタイリング',
          'パーマ',
          'カラーリング',
          '特別スタイル',
          '全体パッケージ',
          '部分美容',
          '涙やけケア',
          '抜け毛ケア',
          '香水処理',
          'スパトリートメント',
        ];
      case 'カフェ':
      case '카페':
        return [
          '基本利用',
          '特別メニュー',
          'イベント参加',
          'ペットフレンドリーカフェ',
          'ペットおやつ',
          'ペットおもちゃ',
          'ペットアクセサリー',
          'ペットフード',
          'ペット栄養剤',
          'ペットシャンプー',
          'ペット寝具',
          'ペット服',
          'ペットリード',
          'ペットバッグ',
          'ペットハウス',
          'ペット遊び場',
          'ペット写真撮影',
          'ペットパーティー',
        ];
      case 'ホテル':
      case '호텔':
        return [
          '1泊',
          '2泊',
          '長期宿泊',
          '特別ケア',
          '1日ペンション',
          '3日ペンション',
          '1週間ペンション',
          '長期ペンション',
          '特別管理',
          '散歩サービス',
          '入浴サービス',
          '給餌サービス',
          '医療サービス',
          '24時間管理',
          '個室',
          'グループルーム',
          '屋外遊び場',
          '室内遊び場',
          '特別活動',
        ];
      case '遊び場':
      case '놀이터':
        return [
          '基本利用',
          '特別プログラム',
          'グループ活動',
          '屋外遊び場',
          '室内遊び場',
          'プール',
          'ドッグカフェ',
          'ドッグ散歩道',
          'ドッグトレーニング場',
          'ドッグ美容室',
          'ドッグホテル',
          'ドッグ病院',
          'ドッグ用品ショップ',
          'ドッグ写真館',
          'ドッグイベント',
        ];
      case '教育センター':
      case '교육센터':
        return [
          '基本トレーニング',
          '上級トレーニング',
          '行動矯正',
          '社会化トレーニング',
          '室内トイレトレーニング',
          '散歩トレーニング',
          'お座り/伏せトレーニング',
          'ハンドシグナルトレーニング',
          '音声トレーニング',
          '分離不安トレーニング',
          '攻撃性トレーニング',
          '若犬トレーニング',
          '老犬トレーニング',
          '個別トレーニング',
          'グループトレーニング',
        ];
      default:
        return ['基本サービス', 'プレミアムサービス', 'VIPサービス', 'カスタマイズサービス', '特別サービス'];
    }
  }

  Future<void> _handleBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPetId == null || _selectedPet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ペットを選択してください'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('サービスを選択してください'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDate == null || _selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('予約日時を選択してください'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        // 예약 정보 생성
        final reservation = HospitalReservation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          hospitalId: widget.facilityId ?? 'facility_${widget.facilityName}',
          hospitalName: widget.facilityName,
          petId: _selectedPet!.id,
          petName: _selectedPet!.name,
          reserverName: _nameController.text,
          phoneNumber: _phoneController.text,
          purpose: _selectedService!,
          reservationDate: _selectedDate!,
          timeSlot: _selectedTimeSlot!,
          symptoms: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          status: ReservationStatus.pending, // 확인대기 상태로 설정
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 로컬 저장소에 예약 정보 저장
        await ref
            .read(reservationsNotifierProvider.notifier)
            .addReservation(reservation);

        // 성공 메시지 표시
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('予約完了'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.facilityName}の予約が完了しました'),
                  const SizedBox(height: 8),
                  Text('予約番号: ${reservation.id}'),
                  Text('状態: ${reservation.status.displayName}'),
                  if (reservation.symptoms != null)
                    Text('症状: ${reservation.symptoms}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.pop();
                  },
                  child: const Text('確認'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // 에러 처리
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('予約保存中にエラーが発生しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
