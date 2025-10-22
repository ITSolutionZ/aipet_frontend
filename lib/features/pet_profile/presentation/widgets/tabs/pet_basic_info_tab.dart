import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/ui/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'helpers/helpers.dart';

part 'pet_basic_info_tab.g.dart';

/// Pet Basic Info Tab 컨트롤러
@riverpod
class PetBasicInfoTabController extends _$PetBasicInfoTabController {
  @override
  PetBasicInfoTabState build(String tabId) {
    // Dispose 시 컨트롤러 정리
    ref.onDispose(() {
      _disposeControllers();
    });
    return const PetBasicInfoTabState();
  }

  /// 펫 정보로 컨트롤러 초기화
  void initialize(PetProfileEntity pet) {
    final controllers = _createTextControllers(pet);
    final healthConditions =
        (pet.additionalInfo?['healthConditions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    state = state.copyWith(
      nameController: controllers.name,
      appearanceController: controllers.appearance,
      weightController: controllers.weight,
      microchipController: controllers.microchip,
      editingGender: pet.gender,
      editingWeight: pet.weight,
      editingHealthConditions: healthConditions,
    );
  }

  /// 텍스트 컨트롤러 생성
  ({
    TextEditingController name,
    TextEditingController appearance,
    TextEditingController weight,
    TextEditingController microchip,
  })
  _createTextControllers(PetProfileEntity pet) {
    return (
      name: TextEditingController(text: pet.name),
      appearance: TextEditingController(
        text: pet.additionalInfo?['appearance'] ?? '',
      ),
      weight: TextEditingController(text: pet.weight.toString()),
      microchip: TextEditingController(
        text: pet.additionalInfo?['microchipId'] ?? '',
      ),
    );
  }

  /// 성별 업데이트
  void updateGender(String? gender) {
    state = state.copyWith(editingGender: gender);
  }

  /// 체중 업데이트
  void updateWeight(double? weight) {
    state = state.copyWith(editingWeight: weight);
  }

  /// 선택된 이미지 경로 업데이트
  void updateSelectedImage(String? imagePath) {
    state = state.copyWith(selectedImagePath: imagePath);
  }

  /// 건강 상태 토글
  void toggleHealthCondition(String condition) {
    final current = state.editingHealthConditions ?? [];
    final updated = List<String>.from(current);

    if (updated.contains(condition)) {
      updated.remove(condition);
    } else {
      updated.add(condition);
    }

    state = state.copyWith(editingHealthConditions: updated);
  }

  /// 텍스트 컨트롤러들 정리
  void _disposeControllers() {
    state.nameController?.dispose();
    state.appearanceController?.dispose();
    state.weightController?.dispose();
    state.microchipController?.dispose();
  }
}

/// Pet Basic Info Tab 상태 클래스
class PetBasicInfoTabState {
  final TextEditingController? nameController;
  final TextEditingController? appearanceController;
  final TextEditingController? weightController;
  final TextEditingController? microchipController;
  final String? editingGender;
  final double? editingWeight;
  final String? selectedImagePath;
  final List<String>? editingHealthConditions;

  const PetBasicInfoTabState({
    this.nameController,
    this.appearanceController,
    this.weightController,
    this.microchipController,
    this.editingGender,
    this.editingWeight,
    this.selectedImagePath,
    this.editingHealthConditions,
  });

  PetBasicInfoTabState copyWith({
    TextEditingController? nameController,
    TextEditingController? appearanceController,
    TextEditingController? weightController,
    TextEditingController? microchipController,
    String? editingGender,
    double? editingWeight,
    String? selectedImagePath,
    List<String>? editingHealthConditions,
  }) {
    return PetBasicInfoTabState(
      nameController: nameController ?? this.nameController,
      appearanceController: appearanceController ?? this.appearanceController,
      weightController: weightController ?? this.weightController,
      microchipController: microchipController ?? this.microchipController,
      editingGender: editingGender ?? this.editingGender,
      editingWeight: editingWeight ?? this.editingWeight,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      editingHealthConditions:
          editingHealthConditions ?? this.editingHealthConditions,
    );
  }
}

/// Pet Basic Info Tab 위젯
class PetBasicInfoTab extends ConsumerWidget {
  final PetProfileEntity pet;
  final bool isEditMode;
  final VoidCallback onToggleEdit;

  const PetBasicInfoTab({
    super.key,
    required this.pet,
    required this.isEditMode,
    required this.onToggleEdit,
  });

  // 상수 정의
  static const double _profileImageSize = 120.0;
  static const double _iconSize = 40.0;
  static const double _editIconSize = 16.0;
  static const double _smallIconSize = 20.0;
  static const double _borderWidth = 2.0;
  static const double _cardBorderRadius = 12.0;

  // 동물별 주요 질병 데이터
  static const Map<String, List<String>> _commonDiseases = {
    'dog': [
      '関節炎', // 관절염
      '皮膚炎', // 피부염
      '外耳炎', // 외이염
      '歯周病', // 치주병
      '心臓病', // 심장병
      '糖尿病', // 당뇨병
      '白内障', // 백내장
      '股関節形成不全', // 고관절 형성부전
    ],
    'cat': [
      '慢性腎臓病', // 만성신장병
      '甲状腺機能亢進症', // 갑상선기능항진증
      '糖尿病', // 당뇨병
      '歯周病', // 치주병
      '心臓病', // 심장병
      '膀胱炎', // 방광염
      '皮膚炎', // 피부염
      '肥満', // 비만
    ],
    'rabbit': [
      '歯の不正咬合', // 치아 부정교합
      '消化器うっ滞', // 소화기 정체
      '呼吸器感染症', // 호흡기 감염증
      '皮膚炎', // 피부염
      '肥満', // 비만
      'ストレス', // 스트레스
    ],
    'hamster': [
      '湿尾病', // 습미병
      '呼吸器感染症', // 호흡기 감염증
      '皮膚炎', // 피부염
      '糖尿病', // 당뇨병
      '腫瘍', // 종양
    ],
    'bird': [
      '呼吸器感染症', // 호흡기 감염증
      '羽毛引き抜き症', // 깃털 뽑기 증후군
      '肝臓病', // 간장병
      '肥満', // 비만
      'ストレス', // 스트레스
      '卵巣腫瘍', // 난소 종양
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabId = _generateTabId();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: _buildTabContent(context, ref, tabId),
    );
  }

  /// 탭 ID 생성
  String _generateTabId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 탭 컨텐츠 구성
  Widget _buildTabContent(BuildContext context, WidgetRef ref, String tabId) {
    return Column(
      children: [
        _buildProfileImageSection(context, ref, tabId),
        const SizedBox(height: AppSpacing.lg),
        _buildBasicInfoCards(context, ref, tabId),
        const SizedBox(height: AppSpacing.lg),
        _buildMicrochipCard(context, ref, tabId),
        const SizedBox(height: AppSpacing.lg),
        _buildDateCard(),
        const SizedBox(height: AppSpacing.lg),
        _buildHealthStatusCard(context, ref, tabId),
        const SizedBox(height: AppSpacing.lg),
        _buildBodyPartsCard(context),
        const SizedBox(height: AppSpacing.lg),
        _buildAppearanceCard(context),
        const SizedBox(height: AppSpacing.lg),
        _buildCaretakerSection(context),
        const SizedBox(height: AppSpacing.xl),
        _buildActionButtons(context, ref, tabId),
      ],
    );
  }

  /// 프로필 이미지 섹션 구성
  Widget _buildProfileImageSection(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final tabState = ref.watch(petBasicInfoTabControllerProvider(tabId));
    final displayImagePath = tabState.selectedImagePath ?? pet.imagePath;

    return Column(
      children: [
        _buildProfileImageContainer(displayImagePath),
        if (isEditMode) _buildImageChangeButton(context, ref, tabId),
        const SizedBox(height: AppSpacing.md),
        _buildPetNameWithChipCard(),
      ],
    );
  }

  /// 프로필 이미지 컨테이너
  Widget _buildProfileImageContainer(String? displayImagePath) {
    return Container(
      width: _profileImageSize,
      height: _profileImageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: _borderWidth,
        ),
      ),
      child: ClipOval(
        child: displayImagePath != null
            ? PetInfoImageHelper.buildImageWidget(displayImagePath)
            : _buildDefaultImagePlaceholder(),
      ),
    );
  }

  /// 기본 이미지 플레이스홀더
  Widget _buildDefaultImagePlaceholder() {
    return Container(
      color: AppColors.pointGray.withValues(alpha: 0.2),
      child: const Icon(
        Icons.pets,
        size: _iconSize,
        color: AppColors.pointGray,
      ),
    );
  }

  /// 이미지 변경 버튼
  Widget _buildImageChangeButton(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () => PetInfoImageHelper.showChangeProfileImageModal(
            context,
            ref,
            tabId,
            pet.id,
          ),
          icon: const Icon(Icons.camera_alt),
          label: const Text('写真を変更'),
        ),
      ],
    );
  }

  /// 기본 정보 카드들 구성
  Widget _buildBasicInfoCards(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final tabState = ref.watch(petBasicInfoTabControllerProvider(tabId));

    return Column(
      children: [
        _buildNameCard(context, ref, tabId, tabState),
        const SizedBox(height: AppSpacing.md),
        _buildWeightCard(context, ref, tabId, tabState),
        const SizedBox(height: AppSpacing.md),
        const SizedBox(height: AppSpacing.md),
        _buildGuardianCard(),
        const SizedBox(height: AppSpacing.md),
        _buildInstitutionCard(),
        const SizedBox(height: AppSpacing.md),
        _buildAdoptionDateCard(),
      ],
    );
  }

  /// 이름 카드
  Widget _buildNameCard(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    PetBasicInfoTabState tabState,
  ) {
    final displayName = isEditMode
        ? (tabState.nameController?.text.isNotEmpty == true
              ? tabState.nameController!.text
              : pet.name)
        : pet.name;

    return _buildEditableAttributeCard(
      context,
      ref,
      tabId,
      '名前',
      displayName,
      type: 'name',
    );
  }

  /// 체중 카드
  Widget _buildWeightCard(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    PetBasicInfoTabState tabState,
  ) {
    final displayWeight = isEditMode
        ? '${tabState.editingWeight ?? pet.weight}kg'
        : '${pet.weight}kg';

    return _buildEditableAttributeCard(
      context,
      ref,
      tabId,
      '体重',
      displayWeight,
      type: 'weight',
    );
  }

  /// 보호자 카드
  Widget _buildGuardianCard() {
    return _buildInfoOnlyCard(
      '保護者',
      pet.additionalInfo?['guardianName']?.toString() ?? '未設定',
      Icons.person_outline,
    );
  }

  /// 등록 기관 카드
  Widget _buildInstitutionCard() {
    return _buildInfoOnlyCard(
      '登録機関',
      pet.additionalInfo?['institutionName']?.toString() ?? '未設定',
      Icons.business,
    );
  }

  /// 입양일 카드
  Widget _buildAdoptionDateCard() {
    final displayDate = _formatAdoptionDate();

    return GenericInfoCard.withIcon(
      icon: Icons.home,
      iconColor: AppColors.pointGreen,
      iconBackgroundColor: AppColors.pointGreen.withValues(alpha: 0.1),
      title: '家に来た日',
      subtitle: displayDate,
    );
  }

  /// 입양일 포맷팅
  String _formatAdoptionDate() {
    final adoptionDate = pet.additionalInfo?['adoptionDate'];

    if (adoptionDate == null) return '未設定';

    try {
      final date = DateTime.parse(adoptionDate.toString());
      return '${date.year}年${date.month}月${date.day}日';
    } catch (e) {
      return '未設定';
    }
  }

  /// 읽기 전용 정보 카드
  Widget _buildInfoOnlyCard(String label, String value, IconData icon) {
    return GenericInfoCard.withIcon(
      icon: icon,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: label,
      subtitle: value,
    );
  }

  /// 펫 이름과 칩 정보 카드
  Widget _buildPetNameWithChipCard() {
    final registrationNumber = _getRegistrationNumber();
    final isRegistered = registrationNumber.isNotEmpty;

    return GenericInfoCard.withIcon(
      icon: Icons.pets,
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: pet.name,
      subtitle: '${pet.type} • ${pet.breed}',
      badge: pet.gender,
      badgeColor: _getGenderBadgeColor(),
      trailing: _buildRegistrationStatusWidget(isRegistered),
    );
  }

  /// 등록번호 가져오기
  String _getRegistrationNumber() {
    return pet.additionalInfo?['registrationNumber']?.toString() ?? '';
  }

  /// 성별 배지 색상
  Color _getGenderBadgeColor() {
    return pet.gender == 'Male' ? AppColors.pointBlue : AppColors.pointPink;
  }

  /// 등록 상태 위젯
  Widget _buildRegistrationStatusWidget(bool isRegistered) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.memory,
          size: _editIconSize,
          color: isRegistered ? AppColors.pointGreen : AppColors.pointGray,
        ),
        const SizedBox(height: 2),
        Text(
          isRegistered ? '登録済み' : '未登録',
          style: AppFonts.bodySmall.copyWith(
            color: isRegistered ? AppColors.pointGreen : AppColors.pointGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 편집 가능한 속성 카드
  Widget _buildEditableAttributeCard(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    String label,
    String value, {
    required String type,
  }) {
    return GenericInfoCard.withIcon(
      icon: PetInfoUiHelper.getAttributeIcon(type),
      iconColor: AppColors.pointBrown,
      iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
      title: label,
      subtitle: value,
      trailing: isEditMode ? _buildEditButton(context, ref, tabId, type) : null,
    );
  }

  /// 편집 버튼
  Widget _buildEditButton(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    String type,
  ) {
    return IconButton(
      icon: const Icon(Icons.edit, size: _editIconSize),
      onPressed: () => _editAttribute(context, ref, tabId, type),
    );
  }

  /// 마이크로칩 카드
  Widget _buildMicrochipCard(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final registrationNumber = _getMicrochipRegistrationNumber(ref, tabId);
    final isRegistered = registrationNumber.isNotEmpty;

    return GenericInfoCard.withIcon(
      icon: Icons.memory,
      iconColor: AppColors.pointBlue,
      iconBackgroundColor: AppColors.pointBlue.withValues(alpha: 0.1),
      title: 'マイクロチップ',
      subtitle: isRegistered ? registrationNumber : '未登録',
      badge: isRegistered ? '登録済み' : '未登録',
      badgeColor: isRegistered ? AppColors.pointGreen : AppColors.pointGray,
    );
  }

  /// 마이크로칩 등록번호 가져오기
  String _getMicrochipRegistrationNumber(WidgetRef ref, String tabId) {
    final tabState = ref.watch(petBasicInfoTabControllerProvider(tabId));

    return isEditMode
        ? (tabState.microchipController?.text ??
              pet.additionalInfo?['registrationNumber'] ??
              '')
        : pet.additionalInfo?['registrationNumber'] ?? '';
  }

  /// 생년월일 카드
  Widget _buildDateCard() {
    final birthDate = pet.birthDate;
    final formattedDate = _formatBirthDate(birthDate);

    return GenericInfoCard.withIcon(
      icon: Icons.cake,
      iconColor: AppColors.pointPink,
      iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
      title: '誕生日',
      subtitle: formattedDate,
      badge: '${pet.age}歳',
      badgeColor: AppColors.pointPink,
    );
  }

  /// 생년월일 포맷팅
  String _formatBirthDate(DateTime birthDate) {
    return '${birthDate.year}年${birthDate.month}月${birthDate.day}日';
  }

  /// 건강 상태 카드
  Widget _buildHealthStatusCard(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final tabState = ref.watch(petBasicInfoTabControllerProvider(tabId));
    final healthConditions = tabState.editingHealthConditions ?? [];
    final hasHealthConditions = healthConditions.isNotEmpty;

    // 신체 부위 개수 확인
    int bodyPartsCount = 0;
    if (pet.additionalInfo != null &&
        pet.additionalInfo!['bodyPartsToManage'] != null) {
      final String bodyPartsString = pet.additionalInfo!['bodyPartsToManage']
          .toString();
      final bodyPartsList = bodyPartsString
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      bodyPartsCount = bodyPartsList.length;
    }

    // 건강상태 결정: 3개 이상이면 "注意", 그 외는 "良好"
    final isWarning = hasHealthConditions || bodyPartsCount >= 3;
    final statusText = isWarning ? '注意' : '良好';
    final statusColor = isWarning ? AppColors.pointPink : AppColors.pointGreen;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(
                  Icons.health_and_safety,
                  color: statusColor,
                  size: _iconSize,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '健康状態',
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                ),
                child: Text(
                  statusText,
                  style: AppFonts.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isEditMode) ...[
                const SizedBox(width: AppSpacing.sm),
                _buildEditHealthStatusButton(context, ref, tabId),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 선택된 건강 조건만 칩으로 표시
          if (hasHealthConditions) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: healthConditions.map((condition) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    condition,
                    style: AppFonts.bodyMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 펫 타입에 따른 주요 질병 반환
  List<String> _getCommonDiseasesForPet() {
    final petType = pet.type.toLowerCase();
    return _commonDiseases[petType] ?? [];
  }

  /// 건강 상태 편집 버튼
  Widget _buildEditHealthStatusButton(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    return IconButton(
      icon: const Icon(Icons.edit, size: 16),
      onPressed: () => _showHealthStatusDialog(context, ref, tabId),
    );
  }

  /// 신경쓰이는 신체 부위 카드
  Widget _buildBodyPartsCard(BuildContext context) {
    // additionalInfo에서 bodyPartsToManage 가져오기
    String bodyParts = '';
    if (pet.additionalInfo != null &&
        pet.additionalInfo!['bodyPartsToManage'] != null) {
      bodyParts = pet.additionalInfo!['bodyPartsToManage'].toString();
    }

    final hasBodyParts = bodyParts.isNotEmpty;
    final bodyPartsList = bodyParts
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // 사용자가 작성한 신체부위가 없으면 표시하지 않음
    if (!hasBodyParts) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(
          color: AppColors.pointGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.pointGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.pointGreen,
                  size: _iconSize,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '気になる身体部位',
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 사용자가 작성한 신체부위 칩 표시
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: bodyPartsList.map((part) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                  border: Border.all(
                    color: AppColors.pointGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  part,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 외견 카드
  Widget _buildAppearanceCard(BuildContext context) {
    // additionalInfo에서 appearance 가져오기
    String appearance = '';
    if (pet.additionalInfo != null &&
        pet.additionalInfo!['appearance'] != null) {
      appearance = pet.additionalInfo!['appearance'].toString();
    }

    final hasAppearance = appearance.isNotEmpty;

    if (!hasAppearance) {
      // 외견 정보가 없으면 표시하지 않음
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(
          color: AppColors.pointBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.pointBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.pointBlue,
                  size: _iconSize,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '外見',
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 외견 정보 표시
          Text(
            appearance,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 건강 상태 선택 다이얼로그
  void _showHealthStatusDialog(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    showDialog(
      context: context,
      builder: (context) => _buildHealthStatusDialog(context, ref, tabId),
    );
  }

  /// 건강 상태 선택 다이얼로그 빌드
  Widget _buildHealthStatusDialog(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final tabState = ref.watch(petBasicInfoTabControllerProvider(tabId));
    final selectedConditions = tabState.editingHealthConditions ?? [];

    return AlertDialog(
      title: const Text('健康状態を選択'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHealthConditionCheckbox(
              context,
              ref,
              tabId,
              'arthritis',
              '関節炎',
              selectedConditions,
            ),
            _buildHealthConditionCheckbox(
              context,
              ref,
              tabId,
              'heart_disease',
              '心臓病',
              selectedConditions,
            ),
            _buildHealthConditionCheckbox(
              context,
              ref,
              tabId,
              'obesity',
              '肥満',
              selectedConditions,
            ),
            _buildHealthConditionCheckbox(
              context,
              ref,
              tabId,
              'pregnancy',
              '妊娠中',
              selectedConditions,
            ),
            _buildHealthConditionCheckbox(
              context,
              ref,
              tabId,
              'recovery',
              '回復中',
              selectedConditions,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('完了'),
        ),
      ],
    );
  }

  /// 건강 상태 체크박스
  Widget _buildHealthConditionCheckbox(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    String condition,
    String label,
    List<String> selectedConditions,
  ) {
    final isSelected = selectedConditions.contains(condition);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) {
        ref
            .read(petBasicInfoTabControllerProvider(tabId).notifier)
            .toggleHealthCondition(condition);
      },
      title: Text(label),
    );
  }

  /// 보호자 섹션
  Widget _buildCaretakerSection(BuildContext context) {
    final guardianInfo = _getGuardianInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCaretakerSectionTitle(),
        const SizedBox(height: AppSpacing.md),
        if (guardianInfo.name.isNotEmpty)
          _buildCaretakerCardWithSpacing(context, guardianInfo)
        else
          _buildEmptyCaretakerCard(),
      ],
    );
  }

  /// 보호자 정보 가져오기
  ({String name, String institution}) _getGuardianInfo() {
    final guardianName = pet.additionalInfo?['guardianName']?.toString() ?? '';
    final institutionName =
        pet.additionalInfo?['institutionName']?.toString() ?? '';

    return (
      name: guardianName,
      institution: institutionName.isNotEmpty ? institutionName : '未設定',
    );
  }

  /// 보호자 섹션 제목
  Widget _buildCaretakerSectionTitle() {
    return Text(
      '家族',
      style: AppFonts.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.pointDark,
      ),
    );
  }

  /// 보호자 카드와 간격
  Widget _buildCaretakerCardWithSpacing(
    BuildContext context,
    ({String name, String institution}) guardianInfo,
  ) {
    return Column(
      children: [
        _buildCaretakerCard(
          context,
          guardianInfo.name,
          guardianInfo.institution,
          isDeletable: true,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  /// 보호자 카드
  Widget _buildCaretakerCard(
    BuildContext context,
    String name,
    String email, {
    bool isDeletable = false,
  }) {
    return GenericInfoCard.withIcon(
      icon: Icons.person,
      iconColor: AppColors.pointGray,
      iconBackgroundColor: AppColors.pointGray.withValues(alpha: 0.1),
      title: name,
      subtitle: email,
      badge: '管理者',
      badgeColor: AppColors.pointBrown,
      trailing: _buildDeleteButton(context, name, isDeletable),
    );
  }

  /// 삭제 버튼
  Widget? _buildDeleteButton(
    BuildContext context,
    String name,
    bool isDeletable,
  ) {
    if (!isDeletable || !isEditMode) return null;

    return IconButton(
      icon: const Icon(Icons.delete, size: _editIconSize, color: Colors.red),
      onPressed: () => _showDeleteCaretakerDialog(context, name),
    );
  }

  /// 빈 보호자 카드
  Widget _buildEmptyCaretakerCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: _buildEmptyCardDecoration(),
      child: _buildEmptyCardContent(),
    );
  }

  /// 빈 카드 디코레이션
  BoxDecoration _buildEmptyCardDecoration() {
    return BoxDecoration(
      color: AppColors.pointGray.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      border: Border.all(
        color: AppColors.pointGray.withValues(alpha: 0.2),
        style: BorderStyle.solid,
      ),
    );
  }

  /// 빈 카드 컨텐츠
  Widget _buildEmptyCardContent() {
    return Row(
      children: [
        const Icon(
          Icons.person_add,
          color: AppColors.pointGray,
          size: _smallIconSize,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '家族情報がありません',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
      ],
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    // 편집 모드일 때만 버튼 표시
    if (!isEditMode) {
      return const SizedBox.shrink();
    }

    return ActionButtonGroup.toggle(
      isEditMode: isEditMode,
      onEdit: onToggleEdit,
      onSave: () => _handleSave(context, ref, tabId),
      onCancel: () => _handleCancel(ref, tabId),
      editLabel: '編集',
      saveLabel: '保存',
      cancelLabel: 'キャンセル',
    );
  }

  /// 저장 처리
  void _handleSave(BuildContext context, WidgetRef ref, String tabId) {
    PetInfoValidationHelper.saveChanges(context, ref, tabId, pet, onToggleEdit);
  }

  /// 취소 처리
  void _handleCancel(WidgetRef ref, String tabId) {
    PetInfoValidationHelper.cancelEdit(ref, tabId, pet, onToggleEdit);
  }

  /// 속성 편집
  void _editAttribute(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    String type,
  ) {
    final editActions = _getEditActions();
    editActions[type]?.call(context, ref, tabId);
  }

  /// 편집 액션들 맵
  Map<String, void Function(BuildContext, WidgetRef, String)>
  _getEditActions() {
    return {
      'name': PetInfoDialogHelper.showEditNameDialog,
      'gender': PetInfoDialogHelper.showEditGenderDialog,
      'weight': PetInfoDialogHelper.showEditWeightDialog,
      'appearance': PetInfoDialogHelper.showEditAppearanceDialog,
    };
  }

  /// 보호자 삭제 다이얼로그 표시
  void _showDeleteCaretakerDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteDialog(context, name),
    );
  }

  /// 삭제 다이얼로그 구성
  Widget _buildDeleteDialog(BuildContext context, String name) {
    return AlertDialog(
      title: const Text('家族情報を削除'),
      content: Text('$name の家族情報を削除しますか？'),
      actions: [
        _buildCancelButton(context),
        _buildDeleteConfirmButton(context),
      ],
    );
  }

  /// 취소 버튼
  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('キャンセル'),
    );
  }

  /// 삭제 확인 버튼
  Widget _buildDeleteConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleDeleteCaretaker(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text('削除'),
    );
  }

  /// 보호자 삭제 처리
  void _handleDeleteCaretaker(BuildContext context) {
    _deleteCaretaker(context);
    Navigator.pop(context);
  }

  /// 보호자 삭제 실행
  void _deleteCaretaker(BuildContext context) {
    // TODO: 실제 삭제 로직 구현
    // 현재는 UI에서만 제거하고, 실제 데이터 삭제는 추후 구현
    _showDeleteSuccessMessage(context);
  }

  /// 삭제 성공 메시지 표시
  void _showDeleteSuccessMessage(BuildContext context) {
    SnackBarService.showSuccess(context, '家族情報を削除しました');
  }
}
