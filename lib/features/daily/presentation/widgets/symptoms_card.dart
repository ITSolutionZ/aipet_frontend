import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:flutter/material.dart';

class SymptomsCard extends StatelessWidget {
  final DailyHealthRecord record;

  const SymptomsCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final symptoms = record.symptoms;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: Colors.grey[700], size: 24),
              const SizedBox(width: 8),
              Text(
                '症状',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: symptoms.isEmpty
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  symptoms.isEmpty ? '症状なし' : '${symptoms.length}個',
                  style: TextStyle(
                    color: symptoms.isEmpty
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (symptoms.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '特別な症状はありません',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...symptoms.map((symptom) => _buildSymptomItem(symptom)),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomItem(HealthSymptom symptom) {
    Color severityColor;
    String severityText;

    switch (symptom.severity) {
      case SymptomSeverity.mild:
        severityColor = Colors.yellow[600]!;
        severityText = '軽微';
        break;
      case SymptomSeverity.moderate:
        severityColor = Colors.orange[600]!;
        severityText = '普通';
        break;
      case SymptomSeverity.severe:
        severityColor = Colors.red[600]!;
        severityText = '深刻';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  symptom.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  severityText,
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (symptom.description != null &&
              symptom.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              symptom.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
