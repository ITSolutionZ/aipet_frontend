import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/pet_registor/data/providers/pet_registration_provider.dart';
import 'package:aipet_frontend/features/pet_registor/presentation/widgets/pet_registor_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PetSizeWeightScreen extends ConsumerStatefulWidget {
  const PetSizeWeightScreen({super.key});

  @override
  ConsumerState<PetSizeWeightScreen> createState() => _PetSizeWeightScreenState();
}

class _PetSizeWeightScreenState extends ConsumerState<PetSizeWeightScreen> {
  String? _selectedSize;
  double _weight = 22.2;
  final bool _isNeutered = false;

  // 체중 입력을 위한 컨트롤러와 포커스 노드
  TextEditingController? _weightController;
  FocusNode? _weightFocusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 컨트롤러와 포커스 노드 초기화
    _weightController = TextEditingController(text: _weight.toStringAsFixed(1));
    _weightFocusNode = FocusNode();

    // 포커스 노드 리스너 추가
    _weightFocusNode?.addListener(() {
      if (_weightFocusNode != null && !_weightFocusNode!.hasFocus) {
        _onWeightChanged();
      }
    });

    // 기존 데이터 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreFromGlobalState();
    });
  }

  @override
  void dispose() {
    _weightController?.dispose();
    _weightFocusNode?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 전역 상태에서 기존 데이터 복원
  void _restoreFromGlobalState() {
    final registrationState = ref.read(petRegistrationStateProvider);

    setState(() {
      if (registrationState.petSize != null) {
        _selectedSize = registrationState.petSize;
      }
      if (registrationState.petWeight != null) {
        _weight = registrationState.petWeight!;
      }
    });
  }

  /// 전역 상태에 데이터 저장
  void _saveToGlobalState() {
    final registrationNotifier = ref.read(petRegistrationStateProvider.notifier);
    registrationNotifier.setPetSizeWeight(size: _selectedSize, weight: _weight);
  }

  /// 체중 입력이 완료되었을 때 호출
  void _onWeightChanged() {
    if (_weightController == null) return;

    final text = _weightController!.text.trim();
    if (text.isNotEmpty) {
      final newWeight = double.tryParse(text);
      if (newWeight != null && newWeight >= 0.5 && newWeight <= 50.0) {
        setState(() {
          _weight = newWeight;
          _updateSizeBasedOnWeight();
        });
        _saveToGlobalState();
      } else {
        // 유효하지 않은 값이면 원래 값으로 복원
        _weightController!.text = _weight.toStringAsFixed(1);
        // 에러 메시지 표시 (선택사항)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('0.5kg ~ 50.0kg 사이의 값을 입력해주세요'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // 빈 값이면 원래 값으로 복원
      _weightController!.text = _weight.toStringAsFixed(1);
    }
  }

  /// 체중에 따라 사이즈 자동 변경
  void _updateSizeBasedOnWeight() {
    String? newSize;
    if (_weight < 14.0) {
      newSize = 'small';
    } else if (_weight <= 25.0) {
      newSize = 'medium';
    } else {
      newSize = 'large';
    }

    if (_selectedSize != newSize) {
      setState(() {
        _selectedSize = newSize;
      });
    }
  }

  /// 사이즈 선택에 따라 체중을 해당 범위의 중간값으로 설정
  void _updateWeightBasedOnSize() {
    if (_selectedSize == null) return;

    double newWeight;
    switch (_selectedSize) {
      case 'small':
        newWeight = 7.0; // 0-14kg의 중간값
        break;
      case 'medium':
        newWeight = 20.0; // 14-25kg의 중간값
        break;
      case 'large':
        newWeight = 38.0; // 25-50kg의 중간값
        break;
      default:
        return;
    }

    setState(() {
      _weight = newWeight;
      // TextField와 동기화
      if (_weightController != null && !_weightFocusNode!.hasFocus) {
        _weightController!.text = _weight.toStringAsFixed(1);
      }
    });
    _saveToGlobalState();
  }

  /// 선택된 펫 이미지 경로 가져오기
  String _getPetImagePath() {
    final registrationState = ref.read(petRegistrationStateProvider);
    final petType = registrationState.selectedPetType;
    final breed = registrationState.currentBreed;

    if (petType == 'dog') {
      // 강아지 품종별 이미지
      switch (breed) {
        case 'shiba':
          return 'assets/images/dogs/shiba.png';
        case 'poodle':
          return 'assets/images/dogs/poodle.jpg';
        case 'pomeranian':
          return 'assets/images/dogs/pomeranian.png';
        case 'dachshund':
          return 'assets/images/dogs/dachshund.png';
        case 'chiwawa':
          return 'assets/images/dogs/chiwawa.png';
        case 'mixed':
          return 'assets/images/dogs/mixed.png';
        default:
          return 'assets/images/dogs/dogs.png';
      }
    } else if (petType == 'cat') {
      // 고양이는 기본 이미지
      return 'assets/images/cats/cat.png';
    }

    return 'assets/images/pets/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: 'ペットのサイズと体重は？',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // 이전 페이지로 이동 (이름 입력)
            context.go(RouteConstants.petNameInputRoute);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 영역 (스크롤 제거)
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 프로그레스바
                            const PetRegistrationProgressBar(currentStep: 4),
                            const SizedBox(height: AppSpacing.md),

                            // 제목
                            Consumer(
                              builder: (context, ref, child) {
                                final registrationState = ref.watch(petRegistrationStateProvider);
                                final petName = registrationState.petName ?? 'ペット';

                                return Text(
                                  '$petNameのサイズと体重は？',
                                  style: AppFonts.titleMedium.copyWith(
                                    color: AppColors.pointBrown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // 펫 이미지
                            PetImageDisplay(
                              imagePath: _getPetImagePath(),
                              width: 100,
                              height: 100,
                              badge: _isNeutered
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '去勢',
                                        style: AppFonts.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // 사이즈 선택 버튼들
                            PetSizeSelectionGroupWidget(
                              selectedSize: _selectedSize,
                              onSizeSelected: (size) {
                                setState(() {
                                  _selectedSize = size;
                                });
                                _updateWeightBasedOnSize();
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // 체중 표시 (중앙) - 크기 축소
                            WeightDisplayWidget(
                              weight: _weight,
                              weightController: _weightController,
                              weightFocusNode: _weightFocusNode,
                              onWeightChanged: (newWeight) {
                                setState(() {
                                  _weight = newWeight;
                                  _updateSizeBasedOnWeight();
                                });
                                _saveToGlobalState();
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // 체중 슬라이더 - 크기 축소
                            WeightSliderWidget(
                              weight: _weight,
                              onWeightChanged: (newWeight) {
                                setState(() {
                                  _weight = newWeight;
                                  _updateSizeBasedOnWeight();
                                  if (_weightController != null && !_weightFocusNode!.hasFocus) {
                                    _weightController!.text = _weight.toStringAsFixed(1);
                                  }
                                });
                                _saveToGlobalState();
                              },
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // 하단 고정 버튼 영역
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(
                  top: BorderSide(color: AppColors.pointGray.withValues(alpha: 0.2), width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, child) {
                    return NextButton(
                      text: '次へ',
                      isEnabled: _selectedSize != null,
                      onPressed: _selectedSize != null
                          ? () {
                              // 전역 상태에 저장
                              _saveToGlobalState();

                              // 등록이 완료된 상태라면 등록확인 페이지로
                              final updatedState = ref.read(petRegistrationStateProvider);
                              if (updatedState.isRegistrationComplete) {
                                context.go(RouteConstants.petAnniversarySummaryRoute);
                                return;
                              }

                              // 다음 단계로 이동
                              context.go(RouteConstants.petAnniversaryRoute);
                            }
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
