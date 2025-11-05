# ⚡ AIPet Backend 빠른 시작

## 1분 안에 시작하기

```bash
# 1. MySQL 데이터베이스 생성
mysql -u root -p
CREATE DATABASE aipet_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;

# 2. 의존성 설치
npm install

# 3. 환경 변수 설정 (Firebase 정보 입력 필요)
cp .env.example .env
nano .env

# 4. 서버 시작
npm run dev
```

---

## ✅ 체크리스트

시작하기 전에 확인하세요:

- [ ] Node.js 18+ 설치됨
- [ ] MySQL 8.0+ 실행 중
- [ ] Firebase 프로젝트 생성됨
- [ ] Firebase Service Account JSON 다운로드됨
- [ ] `.env` 파일에 Firebase 정보 입력됨

---

## 🔥 주요 명령어

```bash
# 개발 모드 (자동 재시작)
npm run dev

# 프로덕션 모드
npm start

# 테스트
npm test

# 데이터베이스 마이그레이션
npm run migrate

# 코드 린팅
npx eslint src/
```

---

## 🌐 엔드포인트 확인

```bash
# Health Check
curl http://localhost:3000/

# API Info
curl http://localhost:3000/api/v1
```

---

## 📱 Flutter 앱 연결

### Android 에뮬레이터

```bash
adb reverse tcp:3000 tcp:3000
```

### iOS 시뮬레이터

```bash
# localhost:3000 그대로 사용
```

---

## 📚 문서

- **README.md** - 전체 문서
- **SETUP.md** - 상세 설치 가이드
- **API_DOCS.md** - API 문서

---

## 🐛 문제 발생 시

```bash
# MySQL 연결 확인
mysql -u root -p -e "SHOW DATABASES;"

# 포트 확인
lsof -i :3000

# 로그 확인
tail -f logs/app.log
```

---

**Happy Coding!** 🚀
