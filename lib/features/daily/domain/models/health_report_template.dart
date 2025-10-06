class ReportMeta {
  const ReportMeta({
    required this.version,
    required this.generatedAt,
    required this.locale,
  });

  final String version;
  final DateTime generatedAt;
  final String locale;

  factory ReportMeta.fromJson(Map<String, dynamic> json) {
    return ReportMeta(
      version: json['version'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      locale: json['locale'] as String,
    );
  }
}

class PetInfo {
  const PetInfo({
    required this.name,
    required this.type,
    required this.age,
    required this.weight,
    this.ownerNote,
  });

  final String name;
  final String type;
  final int age;
  final double weight;
  final String? ownerNote;

  factory PetInfo.fromJson(Map<String, dynamic> json) {
    return PetInfo(
      name: json['name'] as String,
      type: json['type'] as String,
      age: (json['age'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      ownerNote: json['ownerNote'] as String?,
    );
  }
}

class VaccineRecord {
  const VaccineRecord({
    required this.name,
    required this.date,
  });

  final String name;
  final DateTime date;

  factory VaccineRecord.fromJson(Map<String, dynamic> json) {
    return VaccineRecord(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class WeightRecord {
  const WeightRecord({
    required this.date,
    required this.value,
  });

  final DateTime date;
  final double value;

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
}

class AllergyInfo {
  const AllergyInfo({
    required this.source,
    required this.items,
  });

  final String source;
  final List<String> items;

  factory AllergyInfo.fromJson(Map<String, dynamic> json) {
    return AllergyInfo(
      source: json['source'] as String,
      items: (json['items'] as List<dynamic>).cast<String>(),
    );
  }
}

class ReportPeriod {
  const ReportPeriod({
    required this.from,
    required this.to,
  });

  final DateTime from;
  final DateTime to;

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
    );
  }
}

class ReportBody {
  const ReportBody({
    required this.period,
    required this.aiSummary,
    required this.allergy,
    required this.vaccines,
    required this.weights,
    required this.extraNotes,
  });

  final ReportPeriod period;
  final String aiSummary;
  final AllergyInfo allergy;
  final List<VaccineRecord> vaccines;
  final List<WeightRecord> weights;
  final List<String> extraNotes;

  factory ReportBody.fromJson(Map<String, dynamic> json) {
    return ReportBody(
      period: ReportPeriod.fromJson(json['period'] as Map<String, dynamic>),
      aiSummary: json['aiSummary'] as String,
      allergy: AllergyInfo.fromJson(json['allergy'] as Map<String, dynamic>),
      vaccines: (json['vaccines'] as List<dynamic>)
          .map((v) => VaccineRecord.fromJson(v as Map<String, dynamic>))
          .toList(),
      weights: (json['weights'] as List<dynamic>)
          .map((w) => WeightRecord.fromJson(w as Map<String, dynamic>))
          .toList(),
      extraNotes: (json['extraNotes'] as List<dynamic>).cast<String>(),
    );
  }
}

class HealthReportTemplate {
  const HealthReportTemplate({
    required this.meta,
    required this.pet,
    required this.report,
  });

  final ReportMeta meta;
  final PetInfo pet;
  final ReportBody report;

  factory HealthReportTemplate.fromJson(Map<String, dynamic> json) {
    return HealthReportTemplate(
      meta: ReportMeta.fromJson(json['meta'] as Map<String, dynamic>),
      pet: PetInfo.fromJson(json['pet'] as Map<String, dynamic>),
      report: ReportBody.fromJson(json['report'] as Map<String, dynamic>),
    );
  }
}