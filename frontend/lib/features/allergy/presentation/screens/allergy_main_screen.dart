import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/pet_profile.dart';
import '../../data/data.dart';
import '../widgets/allergy_pet_selector.dart';
import 'allergy_main_screen_widgets/allergy_main_screen_widgets.dart';


/// 알레르기 메인 화면
///
/// 홈에서 이동하는 알레르기 통합 화면입니다.
/// - 상단: 알레르기 원료 분석 안내
/// - 중간: 알레르기 발생/미발생 필터 선택
/// - 하단: 선택된 제품 및 분석
class AllergyMainScreen extends ConsumerStatefulWidget {
  const AllergyMainScreen({super.key});

  @override
  ConsumerState<AllergyMainScreen> createState() => _AllergyMainScreenState();
}

class _AllergyMainScreenState extends ConsumerState<AllergyMainScreen> {
  /// 선택된 필터 (null: 전체, true: 발생, false: 미발생)
  bool? _selectedFilter;

  /// 선택된 펫
  PetProfileEntity? _selectedPet;

  /// 분석 진행 상태
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.list_alt, color: AppColors.pointDark),
          onPressed: () {
            context.push('/home/allergy/saved-analyses');
          },
        ),
        title: petsAsync.when(
          data: (pets) {
            if (pets.isEmpty) return const SizedBox.shrink();

            // 첫 로드 시 첫 번째 펫 자동 선택
            if (_selectedPet == null && pets.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedPet = pets.first;
                  });
                }
              });
            }

            return AllergyPetSelector(
              selectedPet: _selectedPet,
              pets: pets,
              onPetSelected: (pet) {
                setState(() {
                  _selectedPet = pet;
                });
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 안내 섹션
            const AllergyInfoSection(),
            const SizedBox(height: AppSpacing.md),

            // 알레르기 발생/미발생 선택 섹션
            AllergyFilterSection(
              selectedPet: _selectedPet,
              selectedFilter: _selectedFilter,
              onFilterSelected: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
              onNavigateToProductSelection: (hasAllergy) {
                if (_selectedPet != null) {
                  context.push(
                    '/home/allergy/product-selection',
                    extra: {
                      'hasAllergy': hasAllergy,
                      'petId': _selectedPet!.id,
                    },
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // 선택된 펫 정보 표시
            if (_selectedPet != null)
              AllergySelectedPetInfo(selectedPet: _selectedPet!),
            const SizedBox(height: AppSpacing.sm),

            // 선택된 제품 리스트
            if (_selectedPet != null)
              AllergySelectedProductsList(
                selectedPet: _selectedPet!,
                isAnalyzing: _isAnalyzing,
                onAnalyze: _performAnalysis,
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// 분석 실행
  Future<void> _performAnalysis() async {
    if (_selectedPet == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    // OpenAI 분석 실행
    final analysisService = ref.read(allergyAnalysisServiceProvider);
    final result = await ref
        .read(selectedAllergyProductsProvider.notifier)
        .analyzeAllergyIngredients(_selectedPet!.id, analysisService);

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    if (result.isSuccess) {
      // 분석 성공: 결과 페이지로 이동
      context.push(
        '/home/allergy/analysis-result',
        extra: {
          'analysisResult': result.data!,
          'petName': _selectedPet!.name,
          'petId': _selectedPet!.id,
        },
      );
    } else {
      // 분석 실패: 에러 메시지 표시
      SnackBarService.showError(
        context,
        result.message,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
