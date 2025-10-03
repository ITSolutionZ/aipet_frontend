import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:flutter/material.dart';

class TemperatureDisplayCard extends StatelessWidget {
  final DailyHealthRecord record;

  const TemperatureDisplayCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final temperature = record.temperature;
    final isHigh = temperature > 39.2;
    final isLow = temperature < 37.5;

    Color temperatureColor;
    String temperatureStatus;

    if (isHigh) {
      temperatureColor = Colors.red;
      temperatureStatus = '高い';
    } else if (isLow) {
      temperatureColor = Colors.blue;
      temperatureStatus = '低い';
    } else {
      temperatureColor = Colors.green;
      temperatureStatus = '正常';
    }

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
              Icon(Icons.thermostat, color: temperatureColor, size: 24),
              const SizedBox(width: 8),
              Text(
                '体温',
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
                  color: temperatureColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  temperatureStatus,
                  style: TextStyle(
                    color: temperatureColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                temperature.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: temperatureColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  '°C',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: temperatureColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '正常体温: 37.5°C - 39.2°C',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
