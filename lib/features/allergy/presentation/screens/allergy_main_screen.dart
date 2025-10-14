import 'package:aipet_frontend/features/allergy/data/providers/allergy_providers.dart';
import 'package:aipet_frontend/features/allergy/data/providers/allergy_service_providers.dart';
import 'package:aipet_frontend/features/allergy/presentation/screens/allergy_analysis_result_screen.dart';
import 'package:aipet_frontend/features/allergy/presentation/screens/allergy_main_screen_widgets/allergy_main_screen_widgets.dart';
import 'package:aipet_frontend/features/allergy/presentation/screens/allergy_product_selection_screen.dart';
import 'package:aipet_frontend/features/allergy/presentation/widgets/allergy_pet_selector.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final petsAsync = ref.watch(petProfilesNotifierProvider);

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
          error: (_, __) => const SizedBox.shrink(),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllergyProductSelectionScreen(
                        hasAllergy: hasAllergy,
                        petId: _selectedPet!.id,
                      ),
                    ),
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
            if (_selectedPet != null) ...[
              // 디버깅용 로그
              Builder(
                builder: (context) {
                  final selectedProductsMap = ref.read(
                    selectedAllergyProductsProvider,
                  );
                  debugPrint('🔍 AllergyMainScreen Debug:');
                  debugPrint('  - Selected Pet ID: ${_selectedPet!.id}');
                  debugPrint('  - Selected Pet Name: ${_selectedPet!.name}');
                  debugPrint(
                    '  - Provider State Keys: ${selectedProductsMap.keys}',
                  );
                  debugPrint(
                    '  - Pet Data: ${selectedProductsMap[_selectedPet!.id]}',
                  );
                  return const SizedBox.shrink();
                },
              ),
              AllergySelectedProductsList(
                selectedPet: _selectedPet!,
                isAnalyzing: _isAnalyzing,
                onAnalyze: _performAnalysis,
              ),
            ],
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

    try {
      // OpenAI 분석 실행
      final analysisService = ref.read(allergyAnalysisServiceProvider);
      final result = await ref
          .read(selectedAllergyProductsProvider.notifier)
          .analyzeAllergyIngredients(_selectedPet!.id, analysisService);

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        // 분석 결과 페이지로 이동
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllergyAnalysisResultScreen(
              analysisResult: result,
              petName: _selectedPet!.name,
              petId: _selectedPet!.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分析エラー: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
