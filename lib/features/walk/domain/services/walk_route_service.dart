import '../entities/walk_location_entity.dart';

/// 산책 경로 서비스 인터페이스
abstract class WalkRouteService {
  /// 경로의 총 거리 계산 (미터 단위)
  double calculateTotalDistance(List<WalkLocation> route);

  /// 경로의 총 시간 계산
  Duration calculateTotalDuration(List<WalkLocation> route);

  /// 경로의 평균 속도 계산 (m/s)
  double calculateAverageSpeed(List<WalkLocation> route);

  /// Google Maps Polyline 인코딩
  String encodePolyline(List<WalkLocation> route);

  /// Google Maps Polyline 디코딩
  List<WalkLocation> decodePolyline(String encodedPolyline);

  /// 경로 최적화 (노이즈 제거, 중복점 제거)
  List<WalkLocation> optimizeRoute(List<WalkLocation> route);

  /// 경로 스무딩 (부드러운 곡선으로 변환)
  List<WalkLocation> smoothRoute(List<WalkLocation> route);
}
