import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/pet_registor/data/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PetSectionWidget extends ConsumerWidget {
  const PetSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pet 헤더
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Pet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // 펫 목록
        Consumer(
          builder: (context, ref, child) {
            final petsAsync = ref.watch(petsNotifierProvider);

            return petsAsync.when(
              data: (pets) {
                final children = <Widget>[];

                // 최대 3개까지만 표시
                final displayPets = pets.take(3).toList();

                for (int i = 0; i < displayPets.length; i++) {
                  final pet = displayPets[i];
                  children.add(
                    _buildPetAvatar(
                      pet.name,
                      pet.imagePath ?? 'assets/images/pets/default.png',
                    ),
                  );
                  if (i < displayPets.length - 1) {
                    children.add(const const const SizedBox(width: 12));
                  }
                }

                // 펫 추가 버튼 (3개 미만일 때만)
                if (pets.length < 3) {
                  if (children.isNotEmpty) {
                    children.add(const const const SizedBox(width: 12));
                  }
                  children.add(_buildAddPetButton(context));
                }

                return Padding(
                  padding: const const const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: children),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Padding(
                padding: const const const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [_buildAddPetButton(context)]),
              ),
            );
          },
        ),
        const const const SizedBox(height: 16),
        // 구분선
        Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.2),
          margin: const const const EdgeInsets.symmetric(horizontal: 16),
        ),
        const const const SizedBox(height: 16),
        // 대시보드 메뉴
        ListTile(
          leading: const Icon(Icons.list, color: Colors.white, size: 20),
          title: const Text(
            'ダッシュボード',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () {
            Navigator.of(context).pop(); // 드로어 닫기
            context.go(AppRouter.homeRoute); // 홈 페이지로 이동
          },
        ),
      ],
    );
  }

  Widget _buildPetAvatar(String name, String imagePath) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.pets, color: Colors.grey, size: 24),
                );
              },
            ),
          ),
        ),
        const const const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 드로워를 먼저 닫기
        Navigator.of(context).pop();
        // 펫 등록 페이지로 이동
        context.go(RouteConstants.petTypeSelectionRoute);
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
              color: Colors.transparent,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const const const SizedBox(height: 4),
          const Text(
            'ペット追加',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
