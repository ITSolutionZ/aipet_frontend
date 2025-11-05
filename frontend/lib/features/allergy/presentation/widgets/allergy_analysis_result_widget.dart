import 'package:flutter/material.dart';

import '../../domain/entities/allergy_analysis_entities.dart';
import '../../domain/entities/product_entity.dart';


/// 알레르기 분석 결과 표시 위젯
class AllergyAnalysisResultWidget extends StatelessWidget {
  final AllergyAnalysisResult analysisResult;
  final List<ProductEntity> recommendedProducts;
  final VoidCallback? onViewReport;
  final VoidCallback? onViewRecommendations;

  const AllergyAnalysisResultWidget({
    super.key,
    required this.analysisResult,
    this.recommendedProducts = const [],
    this.onViewReport,
    this.onViewRecommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '알레르기 분석 결과',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 신뢰도 표시
            _buildConfidenceSection(context),
            const SizedBox(height: 16),

            // 의심 성분
            _buildSuspectedIngredientsSection(context),
            const SizedBox(height: 16),

            // 권장사항
            _buildRecommendationsSection(context),
            const SizedBox(height: 16),

            // 추천 제품 (있는 경우)
            if (recommendedProducts.isNotEmpty) ...[
              _buildRecommendedProductsSection(context),
              const SizedBox(height: 16),
            ],

            // 액션 버튼들
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceSection(BuildContext context) {
    final confidence = analysisResult.confidence;
    final confidencePercentage = (confidence * 100).toInt();

    Color confidenceColor;
    String confidenceText;

    if (confidence >= 0.8) {
      confidenceColor = Colors.green;
      confidenceText = '높음';
    } else if (confidence >= 0.6) {
      confidenceColor = Colors.orange;
      confidenceText = '보통';
    } else {
      confidenceColor = Colors.red;
      confidenceText = '낮음';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: confidenceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: confidenceColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: confidenceColor),
          const SizedBox(width: 8),
          Text(
            '분석 신뢰도: $confidencePercentage% ($confidenceText)',
            style: TextStyle(
              color: confidenceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuspectedIngredientsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              '의심 성분',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (analysisResult.suspectedIngredients.isEmpty)
          const Text(
            '의심되는 알레르기 성분이 발견되지 않았습니다.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: analysisResult.suspectedIngredients
                .map(
                  (ingredient) => Chip(
                    label: Text(ingredient),
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              '권장사항',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...analysisResult.recommendations.map(
          (recommendation) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.blue)),
                Expanded(child: Text(recommendation)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedProductsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.recommend, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              '추천 제품 (${recommendedProducts.length}개)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedProducts.take(5).length,
            itemBuilder: (context, index) {
              final product = recommendedProducts[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '¥${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (onViewReport != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onViewReport,
              icon: const Icon(Icons.description),
              label: const Text('상세 보고서'),
            ),
          ),
        if (onViewReport != null && onViewRecommendations != null)
          const SizedBox(width: 12),
        if (onViewRecommendations != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onViewRecommendations,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('추천 제품 보기'),
            ),
          ),
      ],
    );
  }
}
