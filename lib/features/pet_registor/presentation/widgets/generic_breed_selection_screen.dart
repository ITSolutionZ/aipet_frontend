import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/providers.dart';
import 'widgets.dart';

/// 제네릭 품종 선택 화면
/// DRY 원칙을 위해 강아지/고양이 품종 선택을 통합한 재사용 가능한 위젯
class GenericBreedSelectionScreen<T> extends ConsumerStatefulWidget {
  final String petType; // 'dog' or 'cat'
  final String title; // 화면 제목
  final List<Map<String, dynamic>> breedData; // 품종 데이터
  final String routeAfterSelection; // 선택 후 이동할 경로
  final String previousRoute; // 이전 경로

  const GenericBreedSelectionScreen({
    super.key,
    required this.petType,
    required this.title,
    required this.breedData,
    required this.routeAfterSelection,
    required this.previousRoute,
  });

  @override
  ConsumerState<GenericBreedSelectionScreen<T>> createState() =>
      _GenericBreedSelectionScreenState<T>();
}

class _GenericBreedSelectionScreenState<T>
    extends ConsumerState<GenericBreedSelectionScreen<T>> {
  String? _selectedBreed;
  String? _customBreed;
  final TextEditingController _customController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _restoreFromGlobalState();
  }

  @override
  void dispose() {
    _customController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 전역 상태에서 기존 데이터 복원
  void _restoreFromGlobalState() {
    final registrationState = ref.read(petRegistrationStateProvider);

    setState(() {
      if (widget.petType == 'dog') {
        _selectedBreed = registrationState.selectedDogBreed;
        _customBreed = registrationState.customBreed;
      } else if (widget.petType == 'cat') {
        _selectedBreed = registrationState.selectedCatBreed;
        _customBreed = registrationState.customBreed;
      }

      if (_customBreed != null) {
        _customController.text = _customBreed!;
      }
    });

    // 커스텀 품종 선택시 자동 포커스
    if (_selectedBreed == 'custom') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  /// 전역 상태에 데이터 저장
  void _saveToGlobalState() {
    final registrationNotifier = ref.read(
      petRegistrationStateProvider.notifier,
    );

    if (widget.petType == 'dog') {
      registrationNotifier.selectDogBreed(_selectedBreed ?? '');
    } else if (widget.petType == 'cat') {
      registrationNotifier.selectCatBreed(_selectedBreed ?? '');
    }

    if (_selectedBreed == 'custom' && _customBreed != null) {
      registrationNotifier.setCustomBreed(_customBreed!);
    }
  }

  /// 품종 선택 처리
  void _onBreedSelected(String breed) {
    setState(() {
      _selectedBreed = breed;
      if (breed != 'custom') {
        _customBreed = null;
        _customController.clear();
      }
    });
    _saveToGlobalState();
  }

  /// 커스텀 품종 입력 처리
  void _onCustomBreedChanged(String value) {
    setState(() {
      _customBreed = value.isNotEmpty ? value : null;
    });
    _saveToGlobalState();
  }

  /// 다음 단계로 이동 가능한지 확인
  bool _canProceed() {
    if (_selectedBreed == null) return false;
    if (_selectedBreed == 'custom') {
      return _customBreed != null && _customBreed!.trim().isNotEmpty;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: SoftGradientAppBar(
        title: widget.title,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go(widget.previousRoute);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 프로그레스바
                    const PetRegistrationProgressBar(currentStep: 2),
                    const SizedBox(height: AppSpacing.xl),

                    // 품종 선택 그리드
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                          ),
                      itemCount: widget.breedData.length,
                      itemBuilder: (context, index) {
                        final breed = widget.breedData[index];
                        return _buildBreedCard(
                          breedKey: breed['key'] as String,
                          name: breed['name'] as String,
                          imagePath: breed['image'] as String,
                          isSelected: _selectedBreed == breed['key'],
                          onTap: () => _onBreedSelected(breed['key'] as String),
                        );
                      },
                    ),

                    // 커스텀 품종 입력
                    if (_selectedBreed == 'custom') ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          border: Border.all(
                            color: AppColors.pointGray.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _customController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: '品種を入力してください',
                            border: InputBorder.none,
                          ),
                          onChanged: _onCustomBreedChanged,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 하단 고정 버튼 영역
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: NextButton(
                  text: '次へ',
                  isEnabled: _canProceed(),
                  onPressed: _canProceed()
                      ? () {
                          _saveToGlobalState();
                          context.go(widget.routeAfterSelection);
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 품종 카드 생성
  Widget _buildBreedCard({
    required String breedKey,
    required String name,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected
                ? AppColors.pointPink
                : AppColors.pointGray.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pointPink.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 품종 이름 (상단)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                name,
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 강아지 이미지 (하단)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.pointGray.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.pets,
                          size: 40,
                          color: AppColors.pointPink,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
