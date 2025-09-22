# 🎭 Mockito Integration

이 폴더는 기존 mock_data 시스템에 Mockito 지원을 추가합니다.

## 🎯 목표

1. **UI/Logic 코드 깔끔하게 유지**: Provider만 사용
2. **환경 기반 자동 전환**: Mock ↔ Real Repository
3. **한번에 삭제 가능**: 프로덕션 배포 시 mockito/ 폴더만 삭제

## 📁 구조

```
mock_data/
├── mockito/                    # Mockito 전용 (삭제 가능)
│   ├── repositories/           # Mockito Repository 구현체들
│   └── providers/              # 환경 기반 Provider 전환
├── services/                   # 기존 Mock Service들 (유지)
└── core/                       # 기존 공통 코드 (유지)
```

## 🔄 사용법

```dart
// UI/Logic 코드 (변경 없음)
final aiRepo = ref.read(aiRepositoryProvider);

// Provider에서 환경 기반 자동 전환
@riverpod
AiRepository aiRepository(Ref ref) {
  if (MockConfig.shouldUseMock) {
    return AiRepositoryMockitoImpl(); // Mockito 구현체
  }
  return AiRepositoryImpl(...);       // Real 구현체
}
```

## 🚀 프로덕션 배포

```bash
# mockito 폴더만 삭제하면 Mock 완전 제거
rm -rf lib/shared/mock_data/mockito/
```