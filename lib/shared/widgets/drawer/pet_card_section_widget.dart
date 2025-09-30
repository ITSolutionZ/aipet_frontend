import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ペットカードセクションウィジェット
/// ペット情報カードと追加ボタンを表示
class PetCardSectionWidget extends ConsumerWidget {
  const PetCardSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ペットカード表示エリア
          Text(
            '旅と概要登録をして様々な情報を確認しよう',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // ペットデータに応じて表示を切り替え
          petsAsync.when(
            data: (pets) {
              if (pets.isEmpty) {
                // ペットがいない場合は登録促進メッセージ
                return _buildEmptyPetState(context);
              } else {
                // 最初のペットを表示
                return _buildPetCard(context, pets.first);
              }
            },
            loading: () => _buildLoadingState(),
            error: (error, _) => _buildErrorState(context),
          ),

          const SizedBox(height: 16),
          // ペット追加ボタン
          _buildAddPetButton(context),
        ],
      ),
    );
  }

  /// ペットカードを構築
  Widget _buildPetCard(BuildContext context, pet) {
    // 年齢計算
    final age = _calculateAge(pet.birthDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7B68BE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.pets,
                  color: Color(0xFF7B68BE),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pet.breed ?? 'ミックス',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _buildPetInfo(pet, age),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: ペット詳細画面への遷移処理
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              child: const Text(
                'プロフィール確認',
                style: TextStyle(
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ペット情報文字列を構築
  String _buildPetInfo(pet, String age) {
    final gender = pet.gender == 'male'
        ? '男の子'
        : pet.gender == 'female'
        ? '女の子'
        : '';
    final weight = pet.weight != null ? '${pet.weight}kg' : '';

    final parts = <String>[
      if (gender.isNotEmpty) gender,
      age,
      if (weight.isNotEmpty) weight,
    ];

    return parts.join(' / ');
  }

  /// 年齢計算
  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return '';

    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;

    if (years > 0) {
      if (months > 0) {
        return '$years歳$months ヶ月';
      }
      return '$years歳';
    } else if (months > 0) {
      return '$months ヶ月';
    } else {
      final days = difference.inDays;
      return '$days日';
    }
  }

  /// 空のペット状態
  Widget _buildEmptyPetState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7B68BE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.pets, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            'まだペットが登録されていません',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// ローディング状態
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7B68BE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  /// エラー状態
  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7B68BE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'ペット情報の読み込みに失敗しました',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 14,
        ),
      ),
    );
  }

  /// ペット追加ボタン
  Widget _buildAddPetButton(BuildContext context) {
    return Semantics(
      label: 'ペット追加ボタン',
      button: true,
      hint: 'タップして新しいペットを登録します',
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          context.go(RouteConstants.petTypeSelectionRoute);
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'ペット追加',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
