# Weather API 연동 가이드

## OpenWeatherMap One Call API 설정

### 1. API 키 설정

`.env` 파일에 OpenWeatherMap API 키를 설정하세요:

```env
OPENWEATHERMAP_API_KEY=your_actual_api_key_here
```

앱 실행 시 환경 변수를 전달하려면:

```bash
# 개발 시
flutter run --dart-define=OPENWEATHERMAP_API_KEY=your_api_key

# 또는 .env 파일 사용 (추천)
# .env 파일에 OPENWEATHERMAP_API_KEY 설정 후 일반 실행
flutter run
```

환경 변수는 `weather_providers.dart`에서 자동으로 로드됩니다:

```dart
const apiKey = String.fromEnvironment(
  'OPENWEATHERMAP_API_KEY',
  defaultValue: 'fallback_key',
);
```

### 2. 사용법

홈 화면에서 날씨 정보를 표시하려면:

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(currentWeatherProvider());

    return weather.when(
      data: (weatherData) => WeatherCardWidget(weather: weatherData),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 3. 지원되는 기능

#### 날씨 아이콘 매핑

OpenWeatherMap의 날씨 ID와 아이콘 코드를 사용하여 Meteocons SVG 아이콘을 자동으로 선택합니다:

- **맑음**: clear-day, clear-night
- **구름**: partly-cloudy-day/night, cloudy, overcast
- **비**: drizzle, rain, partly-cloudy-day/night-rain
- **눈**: snow, partly-cloudy-day/night-snow, sleet
- **천둥번개**: thunderstorms, thunderstorms-day/night-rain
- **안개/연무**: fog, haze-day/night, dust-day/night

#### 상세 날씨 정보

- 온도, 체감온도
- 습도, 기압
- 풍속, 풍향
- UV 지수
- 시정 거리
- WBGT 계산 (열사병 위험도)

### 4. API 응답 예시

```json
{
  "current": {
    "temp": 19.5,
    "feels_like": 19.2,
    "humidity": 65,
    "wind_speed": 4.1,
    "uvi": 4.8,
    "visibility": 10000,
    "pressure": 1013.25,
    "weather": [
      {
        "id": 800,
        "main": "Clear",
        "description": "맑음",
        "icon": "01d"
      }
    ]
  }
}
```

### 5. 에러 처리

API 호출 실패 시 자동으로 Mock 데이터를 반환하여 앱이 중단되지 않도록 합니다.

### 6. 캐싱 및 최적화

- Riverpod의 자동 캐싱 기능 활용
- 불필요한 API 호출 방지
- 백그라운드 새로고침 지원

### 7. 추후 개선사항

- [ ] 위치 기반 자동 날씨 조회
- [ ] 다국어 지원 확장
- [ ] 시간별/일별 예보 추가
- [ ] 오프라인 모드 지원
- [ ] 푸시 알림 연동 (날씨 경고)