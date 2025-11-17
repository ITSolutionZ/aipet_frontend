# App Store 리젝 해결 가이드

## 리젝 사유 및 해결 방법

### ✅ 1. Guideline 5.1.2 - App Tracking Transparency (ATT) - 해결 완료
**문제**: Device ID를 추적 목적으로 수집하지만 ATT 프레임워크를 사용하지 않음

**해결 완료**:
- ✅ `app_tracking_transparency` 패키지 추가
- ✅ `NSUserTrackingUsageDescription` 추가 (Info.plist)
- ✅ ATT 권한 요청 로직 구현
- ✅ 앱 초기화 시 ATT 권한 요청

**App Store Connect 확인 사항**:
- [ ] App Privacy > "Does your app collect data for tracking purposes?"
  - 실제로 추적하지 않는다면: **No**로 변경
  - 실제로 추적한다면: **Yes** 유지 (ATT 구현 완료)

---

### ✅ 2. Guideline 1.5.0 - Safety: Developer Information - 해결 완료
**문제**: 개발자 정보 및 지원 URL 누락

**해결 완료**:
- ✅ `NSHumanReadableCopyright` 추가 (Info.plist)
- ✅ 암호화 사용 여부 설정 (`ITSAppUsesNonExemptEncryption`)

**App Store Connect에서 확인/설정 필요**:
1. **App Information** 섹션:
   - [ ] **Support URL** (필수): `https://www.itsol.co.jp` 또는 지원 페이지 URL
   - [ ] **Marketing URL** (선택): `https://www.itsol.co.jp` 또는 마케팅 페이지 URL

2. **App Privacy** 섹션:
   - [ ] **Privacy Policy URL** (필수): `https://www.notion.so/AiPet-299e1bdea188806d83ecfcf974fc1e9a`
   - [ ] 개인정보 수집 항목 정확히 설정

3. **Version Information**:
   - [ ] **Contact Information**: `support@aipet.com`
   - [ ] **Review Information**:
     - 테스트 계정 정보 제공 (필요한 경우)
     - 테스트 방법 설명 (필요한 경우)

---

### ⚠️ 3. Guideline 2.1.0 - Performance: App Completeness - 확인 필요
**문제**: 앱 완성도 문제 (크래시, 미완성 기능 등)

**확인 사항**:
- [ ] 앱이 크래시 없이 실행되는지 확인
- [ ] 모든 주요 기능이 정상 작동하는지 확인
- [ ] 테스트 계정으로 모든 기능 테스트
- [ ] 다양한 iOS 버전에서 테스트 (iOS 15.0 이상)
- [ ] 다양한 기기에서 테스트 (iPhone, iPad)

**테스트 체크리스트**:
- [ ] 로그인/회원가입 기능
- [ ] 펫 프로필 등록/수정
- [ ] 산책 기록 기능
- [ ] 시설 검색 기능
- [ ] 알림 기능
- [ ] 설정 화면
- [ ] 앱 정보 화면

**App Store Connect에서 제공할 정보**:
- [ ] 테스트 계정 정보 (로그인이 필요한 경우)
- [ ] 특별한 테스트 방법 (복잡한 기능이 있는 경우)

---

### ⚠️ 4. Guideline 4.5.4 - Design: Apple Sites and Services - 확인 필요
**문제**: Apple 사이트 및 서비스 관련 위반

**확인 사항**:
- [ ] Apple 로고를 잘못 사용하지 않았는지 확인
- [ ] Apple 관련 잘못된 링크가 없는지 확인
- [ ] Apple 제품/서비스를 잘못 언급하지 않았는지 확인
- [ ] App Store 리뷰 가이드라인을 준수하는지 확인

**일반적인 위반 사항**:
- ❌ Apple 로고를 앱 아이콘이나 UI에 사용
- ❌ "App Store에서 다운로드" 같은 잘못된 문구 사용
- ❌ Apple 제품과의 호환성을 잘못 표시

**해결 방법**:
- [ ] 앱 내 모든 텍스트/이미지에서 Apple 관련 내용 확인
- [ ] Apple 로고 사용 여부 확인 및 제거
- [ ] Apple 관련 잘못된 링크 제거

---

## App Store Connect 설정 체크리스트

### 필수 설정 항목

#### 1. App Information
- [ ] **Support URL**: `https://www.itsol.co.jp` 또는 지원 페이지
- [ ] **Marketing URL** (선택): `https://www.itsol.co.jp`
- [ ] **Privacy Policy URL**: `https://www.notion.so/AiPet-299e1bdea188806d83ecfcf974fc1e9a`

#### 2. App Privacy
- [ ] 데이터 수집 항목 정확히 설정
- [ ] 추적 목적 데이터 수집 여부 확인
- [ ] 개인정보 보호 정책 URL 설정

#### 3. Version Information
- [ ] **Contact Information**: `support@aipet.com`
- [ ] **Review Notes**: 테스트 방법 및 특별 사항 설명
- [ ] **Test Account** (필요한 경우): 테스트 계정 정보 제공

#### 4. App Review Information
- [ ] 테스트 계정 정보 (로그인 필요 시)
- [ ] 특별한 테스트 방법 설명
- [ ] 데모 비디오 (복잡한 기능인 경우)

---

## 재제출 전 최종 체크리스트

### 코드 레벨
- [x] ATT 프레임워크 구현 완료
- [x] Info.plist에 개발자 정보 추가
- [x] 모든 권한 사용 설명 추가
- [ ] 크래시 없는지 확인
- [ ] 모든 기능 정상 작동 확인

### App Store Connect
- [ ] 지원 URL 설정
- [ ] 개인정보 보호 정책 URL 설정
- [ ] 개발자 연락처 정보 설정
- [ ] App Privacy 정보 정확히 설정
- [ ] 테스트 계정 정보 제공 (필요한 경우)

### 빌드 및 제출
- [ ] 버전 번호 업데이트 (예: 1.0.0 → 1.0.1)
- [ ] 빌드 번호 증가
- [ ] Release 빌드 생성
- [ ] TestFlight에서 테스트
- [ ] App Store Connect에 업로드
- [ ] 제출 전 모든 정보 재확인

---

## 참고 링크

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)

---

## 연락처 정보

- **회사명**: アイティーソリューションズ株式会社（ITZ）
- **연락처**: support@aipet.com
- **웹사이트**: https://www.itsol.co.jp
- **이용약관**: https://www.notion.so/AiPet-299e1bdea1888039a223dcf1779aae13
- **개인정보 보호 정책**: https://www.notion.so/AiPet-299e1bdea188806d83ecfcf974fc1e9a
