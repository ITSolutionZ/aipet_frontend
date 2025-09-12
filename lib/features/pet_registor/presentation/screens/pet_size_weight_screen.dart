import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/providers.dart';
import '../widgets/widgets.dart';

class PetSizeWeightScreen extends ConsumerStatefulWidget {
  const PetSizeWeightScreen({super.key});

  @override
  ConsumerState<PetSizeWeightScreen> createState() =>
      _PetSizeWeightScreenState();
}

class _PetSizeWeightScreenState extends ConsumerState<PetSizeWeightScreen> {
  String? _selectedSize;
  double _weight = 22.2;
  final bool _isNeutered = false;

  // 체중 입력을 위한 컨트롤러와 포커스 노드
  TextEditingController? _weightController;
  FocusNode? _weightFocusNode;

  @override
  void initState() {
    super.initState();

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
    final registrationNotifier = ref.read(
      petRegistrationStateProvider.notifier,
    );
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

  /// 체중 표시 (화면 중앙)
  Widget _buildWeightDisplay() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          // 포커스를 주어 키보드 표시
          if (_weightController != null && _weightFocusNode != null) {
            _weightController!.text = _weight.toStringAsFixed(1);
            _weightController!.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _weightController!.text.length,
            );
            _weightFocusNode!.requestFocus();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 숨겨진 TextField (화면 밖에 위치)
              if (_weightController != null && _weightFocusNode != null)
                Positioned(
                  left: -1000,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextField(
                      controller: _weightController,
                      focusNode: _weightFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 1),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // 실시간으로 입력값 반영
                        final newWeight = double.tryParse(value.trim());
                        if (newWeight != null &&
                            newWeight >= 0.5 &&
                            newWeight <= 50.0) {
                          setState(() {
                            _weight = newWeight;
                            _updateSizeBasedOnWeight();
                          });
                          _saveToGlobalState();
                        }
                      },
                      onSubmitted: (value) {
                        _onWeightChanged();
                        _weightFocusNode?.unfocus();
                      },
                    ),
                  ),
                ),
              // 표시용 Text
              Text(
                _weight.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 체중 슬라이더 생성
  Widget _buildWeightSlider() {
    return Column(
      children: [
        // 무한 스크롤 슬라이더
        GestureDetector(
          onPanUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final width = MediaQuery.of(context).size.width - 32;

            // 슬라이더 영역 내에서의 상대적 위치 계산
            final relativeX = localPosition.dx - 16; // 패딩 오프셋
            final normalizedX = (relativeX / width).clamp(
              0.0,
              1.0,
            ); // 0.0 ~ 1.0 사이의 값으로 제한

            // 0.5kg ~ 50.0kg 범위로 변환
            final newWeight = (0.5 + normalizedX * (50.0 - 0.5)).clamp(
              0.5,
              50.0,
            );

            if ((newWeight - _weight).abs() > 0.05) {
              // 0.05kg 이상 차이날 때만 업데이트
              setState(() {
                _weight = newWeight;
                _updateSizeBasedOnWeight();
                // TextField와 동기화
                if (_weightController != null && !_weightFocusNode!.hasFocus) {
                  _weightController!.text = _weight.toStringAsFixed(1);
                }
              });
              _saveToGlobalState();
            }
          },
          child: Container(
            height: 80, // 더 넓은 터치 영역
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                // 틱 마크들 - 시안과 동일하게 균등한 높이
                ...List.generate(15, (index) {
                  // 화면 너비를 15개로 균등하게 나누어 배치
                  final screenWidth = MediaQuery.of(context).size.width - 32;
                  final position = (screenWidth / 14) * index; // 14개 간격으로 15개 틱

                  return Positioned(
                    left: position - 1, // 틱 중심 맞춤
                    top: 18,
                    child: Container(
                      width: 2,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.pointGray.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                }),

                // 슬라이더 썸 - 시안과 동일한 둥근 사각형 스타일
                Positioned(
                  top: 10,
                  left: () {
                    final screenWidth = MediaQuery.of(context).size.width - 32;
                    const thumbWidth = 40.0;
                    final normalizedPosition = (_weight - 0.5) / (50.0 - 0.5);
                    final rawLeft =
                        normalizedPosition * screenWidth - (thumbWidth / 2);

                    // 화면 경계 내에서 슬라이더가 움직이도록 제한
                    return rawLeft.clamp(0.0, screenWidth - thumbWidth);
                  }(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.pointBrown,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pointBrown.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 2,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Container(
                            width: 2,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Container(
                            width: 2,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: SoftGradientAppBar(
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
            // 스크롤 가능한 상단 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 프로그레스바
                    const PetRegistrationProgressBar(currentStep: 4),
                    const SizedBox(height: AppSpacing.lg),

                    // 제목
                    Consumer(
                      builder: (context, ref, child) {
                        final registrationState = ref.watch(
                          petRegistrationStateProvider,
                        );
                        final petName = registrationState.petName ?? 'ペット';

                        return Text(
                          '$petNameのサイズと体重は？',
                          style: AppFonts.titleLarge.copyWith(
                            color: AppColors.pointBrown,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 펫 이미지
                    PetImageDisplay(
                      imagePath: _getPetImagePath(),
                      width: 120,
                      height: 120,
                      badge: _isNeutered
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: AppSpacing.lg),

                    // 사이즈 선택 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PetSizeSelectionCard(
                          size: 'small',
                          label: 'Small',
                          weightRange: '14kg以下',
                          icon: Icons.pets,
                          isSelected: _selectedSize == 'small',
                          onTap: () {
                            setState(() {
                              _selectedSize = 'small';
                            });
                            _updateWeightBasedOnSize();
                          },
                        ),
                        PetSizeSelectionCard(
                          size: 'medium',
                          label: 'Medium',
                          weightRange: '14-25kg',
                          icon: Icons.pets,
                          isSelected: _selectedSize == 'medium',
                          onTap: () {
                            setState(() {
                              _selectedSize = 'medium';
                            });
                            _updateWeightBasedOnSize();
                          },
                        ),
                        PetSizeSelectionCard(
                          size: 'large',
                          label: 'Large',
                          weightRange: '25kg以上',
                          icon: Icons.pets,
                          isSelected: _selectedSize == 'large',
                          onTap: () {
                            setState(() {
                              _selectedSize = 'large';
                            });
                            _updateWeightBasedOnSize();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 체중 표시 (중앙)
                    _buildWeightDisplay(),
                    const SizedBox(height: AppSpacing.lg),

                    // 체중 슬라이더
                    _buildWeightSlider(),
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
                    color: AppColors.pointGray.withValues(alpha: 0.2),
                    width: 1,
                  ),
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
                              final updatedState = ref.read(
                                petRegistrationStateProvider,
                              );
                              if (updatedState.isRegistrationComplete) {
                                context.go(
                                  RouteConstants.petAnniversarySummaryRoute,
                                );
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
