import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';

class VaccineScreen extends ConsumerStatefulWidget {
  final String petId;

  const VaccineScreen({super.key, required this.petId});

  @override
  ConsumerState<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends ConsumerState<VaccineScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 임시 백신 데이터
  final Map<String, List<Map<String, dynamic>>> _vaccineData = {
    '2023': [
      {
        'name': 'Nobivac Parvo-C',
        'date': '11.03.2023',
        'doctor': 'dr. Martha Roth',
        'lot': 'A583D01',
        'expiryDate': '07-2026',
        'vaccinationDate': '18.05.2023',
        'validUntil': '18.09.2025',
        'notes': 'No bad reactions',
      },
    ],
    '2022': [
      {
        'name': 'Nobivac Parvo-C',
        'date': '13.03.2022',
        'doctor': 'dr. Martha Roth',
        'lot': 'B492E02',
        'expiryDate': '06-2025',
        'vaccinationDate': '13.03.2022',
        'validUntil': '13.07.2024',
        'notes': 'Normal reaction',
      },
      {
        'name': 'Rabisin',
        'date': '20.08.2022',
        'doctor': 'dr. Martha Roth',
        'lot': 'C301F03',
        'expiryDate': '08-2025',
        'vaccinationDate': '20.08.2022',
        'validUntil': '20.12.2024',
        'notes': 'No adverse effects',
      },
      {
        'name': 'Nobivac KV',
        'date': '08.06.2022',
        'doctor': 'dr. Martha Roth',
        'lot': 'D210G04',
        'expiryDate': '05-2025',
        'vaccinationDate': '08.06.2022',
        'validUntil': '08.10.2024',
        'notes': 'Good response',
      },
    ],
    '2021': [
      {
        'name': 'Nobivac Parvo-C',
        'date': '13.03.2021',
        'doctor': 'dr. Martha Roth',
        'lot': 'E129H05',
        'expiryDate': '03-2024',
        'vaccinationDate': '13.03.2021',
        'validUntil': '13.07.2023',
        'notes': 'Initial vaccination',
      },
      {
        'name': 'Rabisin',
        'date': '15.09.2021',
        'doctor': 'dr. Martha Roth',
        'lot': 'F038I06',
        'expiryDate': '09-2024',
        'vaccinationDate': '15.09.2021',
        'validUntil': '15.01.2024',
        'notes': 'Booster shot',
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Pet Profile',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Vaccines',
              style: AppFonts.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // 펫 선택 드롭다운
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.pets,
                    size: 16,
                    color: AppColors.pointBrown,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Maxi',
                  style: AppFonts.bodyMedium.copyWith(color: Colors.white),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터 영역
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // 검색 바
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by vaccine type',
                        hintStyle: AppFonts.bodyMedium.copyWith(
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.pointBrown,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // 필터 버튼
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.pointBlue,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // 백신 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _vaccineData.length,
              itemBuilder: (context, index) {
                final year = _vaccineData.keys.elementAt(index);
                final vaccines = _vaccineData[year]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 연도 제목
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        year,
                        style: AppFonts.titleMedium.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // 해당 연도의 백신들
                    ...vaccines.map((vaccine) => _buildVaccineCard(vaccine)),

                    const SizedBox(height: AppSpacing.md),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 백신 추가
        },
        backgroundColor: AppColors.pointBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVaccineCard(Map<String, dynamic> vaccine) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          _showVaccineDetailModal(vaccine);
        },
        title: Text(
          vaccine['name'],
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: AppSpacing.xs),
            Text(
              vaccine['date'],
              style: AppFonts.bodyMedium.copyWith(color: Colors.grey),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              vaccine['doctor'],
              style: AppFonts.bodyMedium.copyWith(color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showVaccineDetailModal(Map<String, dynamic> vaccine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 백신 이름
                    Text(
                      vaccine['name'],
                      style: AppFonts.titleLarge.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 상세 정보
                    _buildDetailSection('Details', [
                      _buildDetailRow('Lot', vaccine['lot']),
                      _buildDetailRow('Expiry Date', vaccine['expiryDate']),
                    ]),

                    const SizedBox(height: AppSpacing.lg),

                    // 날짜 정보
                    _buildDetailSection('Date', [
                      _buildDetailRow(
                        'Vaccination date',
                        vaccine['vaccinationDate'],
                      ),
                      _buildDetailRow('Valid until', vaccine['validUntil']),
                    ]),

                    const SizedBox(height: AppSpacing.lg),

                    // 수의사 정보
                    Text(
                      'Veterinarian',
                      style: AppFonts.titleMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildVeterinarianCard(),

                    const SizedBox(height: AppSpacing.lg),

                    // 노트
                    Text(
                      'Notes',
                      style: AppFonts.titleMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      vaccine['notes'],
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 완료 버튼
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVeterinarianCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.pointBlue,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Martha Roth',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Veterinary Specialist',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // 서명 (임시로 아이콘 사용)
          const Icon(Icons.edit, color: AppColors.pointBlue, size: 24),
        ],
      ),
    );
  }
}
