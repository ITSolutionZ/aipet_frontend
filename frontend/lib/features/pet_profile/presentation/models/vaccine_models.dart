import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 日本犬ワクチン種類定義
enum VaccineType {
  // コアワクチン (5種 - 必須)
  distemper('ジステンパー', 'コアワクチン'),
  parvovirus('パルボウイルス', 'コアワクチン'),
  hepatitis('伝染性肝炎', 'コアワクチン'),
  adenovirus('アデノウイルス2型', 'コアワクチン'),
  parainfluenza('パラインフルエンザ', 'コアワクチン'),

  // 法定義務
  rabies('狂犬病', '法定接種'),

  // 追加ワクチン (6-10種 - 選択)
  coronavirus('コロナウイルス', '追加ワクチン'),
  leptospira('レプトスピラ', '追加ワクチン'),
  lyme('ライム病', '追加ワクチン'),
  bordetella('ケンネルコフ', '追加ワクチン'),

  // 寄生虫予防
  heartworm('フィラリア予防', '予防薬'),
  fleaTick('ノミ・ダニ予防', '予防薬'),

  // その他追加ワクチン
  influenza('犬インフルエンザ', '追加ワクチン'),
  hepatitisB('犬B型肝炎', '追加ワクチン'),
  giardia('ジアルジア症', '追加ワクチン'),
  tetanus('破傷風', '追加ワクチン'),
  other('その他', '追加ワクチン');

  const VaccineType(this.label, this.category);
  final String label;
  final String category;
}

/// ワクチン接種状態
enum VaccinationStatus {
  completed('完了', AppColors.pointGreen),
  inProgress('接種中', AppColors.pointBlue),
  overdue('期限切れ', AppColors.pointPink),
  notStarted('未接種', AppColors.pointGray);

  const VaccinationStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// ワクチン接種記録データモデル
class VaccinationRecord {
  final VaccineType type;
  final DateTime? lastDate;
  final DateTime? nextDate;
  final VaccinationStatus status;
  final String? memo;

  VaccinationRecord({
    required this.type,
    this.lastDate,
    this.nextDate,
    required this.status,
    this.memo,
  });

  VaccinationRecord copyWith({
    VaccineType? type,
    DateTime? lastDate,
    DateTime? nextDate,
    VaccinationStatus? status,
    String? memo,
  }) {
    return VaccinationRecord(
      type: type ?? this.type,
      lastDate: lastDate ?? this.lastDate,
      nextDate: nextDate ?? this.nextDate,
      status: status ?? this.status,
      memo: memo ?? this.memo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.label,
      'lastDate': lastDate?.toIso8601String(),
      'nextDate': nextDate?.toIso8601String(),
      'status': status.label,
      'memo': memo,
    };
  }

  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    return VaccinationRecord(
      type: VaccineType.values.firstWhere(
        (t) => t.label == map['type'],
        orElse: () => VaccineType.distemper,
      ),
      lastDate:
          map['lastDate'] != null ? DateTime.parse(map['lastDate']) : null,
      nextDate:
          map['nextDate'] != null ? DateTime.parse(map['nextDate']) : null,
      status: VaccinationStatus.values.firstWhere(
        (s) => s.label == map['status'],
        orElse: () => VaccinationStatus.notStarted,
      ),
      memo: map['memo'],
    );
  }
}
