/// 펫 크기와 체중 관련 비즈니스 로직 서비스
class PetSizeWeightService {
  /// 체중에 따른 적절한 크기 추천
  static String? recommendSizeByWeight(double weight) {
    if (weight < 0.5 || weight > 50.0) return null;
    
    if (weight <= 5.0) return 'extra_small';
    if (weight <= 10.0) return 'small';
    if (weight <= 25.0) return 'medium';
    if (weight <= 40.0) return 'large';
    return 'extra_large';
  }

  /// 크기에 따른 일반적인 체중 범위 반환
  static Map<String, double> getWeightRangeBySize(String size) {
    switch (size) {
      case 'extra_small':
        return {'min': 1.0, 'max': 5.0, 'typical': 3.0};
      case 'small':
        return {'min': 5.0, 'max': 10.0, 'typical': 7.5};
      case 'medium':
        return {'min': 10.0, 'max': 25.0, 'typical': 17.5};
      case 'large':
        return {'min': 25.0, 'max': 40.0, 'typical': 32.5};
      case 'extra_large':
        return {'min': 40.0, 'max': 50.0, 'typical': 45.0};
      default:
        return {'min': 1.0, 'max': 50.0, 'typical': 10.0};
    }
  }

  /// 체중 유효성 검사
  static bool isValidWeight(double weight) {
    return weight >= 0.5 && weight <= 50.0;
  }

  /// 크기 유효성 검사
  static bool isValidSize(String? size) {
    const validSizes = [
      'extra_small',
      'small',
      'medium',
      'large',
      'extra_large',
    ];
    return size != null && validSizes.contains(size);
  }

  /// 크기 표시명 반환
  static String getSizeDisplayName(String size) {
    const sizeNames = {
      'extra_small': '極小型',
      'small': '小型',
      'medium': '中型',
      'large': '大型',
      'extra_large': '超大型',
    };
    return sizeNames[size] ?? size;
  }

  /// 체중-크기 일관성 체크
  static bool isWeightConsistentWithSize(double weight, String size) {
    final range = getWeightRangeBySize(size);
    return weight >= range['min']! && weight <= range['max']!;
  }

  /// 체중 기반 추천 사료량 계산 (일일 권장량, g)
  static double calculateDailyFoodAmount(double weight, {bool isNeutered = false}) {
    // 기본 공식: 체중(kg) × 70 × 0.75 (중성화된 경우 0.6)
    final multiplier = isNeutered ? 0.6 : 0.75;
    return weight * 70 * multiplier;
  }

  /// 체중 상태 평가 (저체중, 정상, 과체중)
  static String evaluateWeightStatus(double weight, String size) {
    final range = getWeightRangeBySize(size);
    final min = range['min']!;
    final max = range['max']!;
    final typical = range['typical']!;
    
    if (weight < min * 0.85) return 'underweight'; // 저체중
    if (weight > max * 1.15) return 'overweight';  // 과체중
    if (weight < typical * 0.9 || weight > typical * 1.1) return 'borderline'; // 주의
    return 'normal'; // 정상
  }

  /// 체중 상태별 메시지
  static String getWeightStatusMessage(String status) {
    switch (status) {
      case 'underweight':
        return '평균보다 체중이 적습니다. 수의사와 상담해보세요.';
      case 'overweight':
        return '평균보다 체중이 많습니다. 체중 관리가 필요할 수 있습니다.';
      case 'borderline':
        return '체중을 주의깊게 관찰해주세요.';
      case 'normal':
        return '건강한 체중 범위입니다.';
      default:
        return '';
    }
  }
}