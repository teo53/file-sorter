# IndieFan - 인디 아티스트 팬소통 플랫폼

인디 아티스트(지하 아이돌, 메이드 카페 메이드, 코스어 등)와 팬들이 프라이빗 메시지로 소통할 수 있는 플랫폼입니다. 메이저 연예기획사의 '버블(bubble)'처럼 구독 기반 1:1 메시지 경험을 제공합니다.

## 프로젝트 구조

```
indie-fan-platform/
├── backend/          # NestJS 백엔드 API
│   ├── prisma/       # 데이터베이스 스키마
│   └── src/
│       ├── common/   # 공통 모듈 (Prisma, Guards, Decorators)
│       └── modules/  # 기능 모듈
│           ├── auth/           # 인증 (JWT, OAuth)
│           ├── users/          # 사용자 관리
│           ├── artists/        # 아티스트 프로필
│           ├── subscriptions/  # 구독 관리
│           ├── messages/       # 버블형 메시징
│           ├── notifications/  # 푸시 알림
│           └── payments/       # 결제/정산
├── mobile/           # Flutter 모바일 앱
│   └── lib/
│       ├── core/     # API 클라이언트, 테마, 상수
│       ├── features/ # 기능별 화면
│       ├── models/   # 데이터 모델
│       └── widgets/  # 공통 위젯
└── shared/           # 공유 타입/상수
```

## 핵심 기능

### 팬 기능
- 소셜 로그인 (카카오, 구글, 애플)
- 아티스트 탐색 및 검색
- 월 구독을 통한 아티스트 구독
- 아티스트로부터 개인화된 메시지 수신
- 메시지당 최대 3회 답장 가능
- 구독 기념일 표시

### 아티스트 기능
- 아티스트 프로필 등록
- SNS 계정 연동 (트위터, 인스타그램 등)
- 전체 구독자에게 메시지 브로드캐스트
- 팬 답장 모아보기
- 대시보드 통계 및 수익 확인
- 정산 요청

### 기술 특징
- **스켈레톤 UI**: 로딩 중 shimmer 효과로 사용자 경험 향상
- **구독 기념일**: 100일, 365일 등 마일스톤 축하
- **읽음 표시**: 카카오톡 스타일 "1" 표시
- **개인화 메시지**: `[name]` 변수로 팬 닉네임 자동 치환

## 기술 스택

### Backend
- **Framework**: NestJS (Node.js)
- **Database**: PostgreSQL + Prisma ORM
- **Authentication**: JWT + Passport
- **Payment**: Stripe
- **Push Notification**: Firebase Cloud Messaging

### Mobile
- **Framework**: Flutter (iOS & Android)
- **State Management**: Riverpod
- **Navigation**: Go Router
- **HTTP Client**: Dio

## 시작하기

### 백엔드 설정

```bash
cd backend

# 의존성 설치
npm install

# 환경 변수 설정
cp .env.example .env
# .env 파일 편집

# 데이터베이스 마이그레이션
npx prisma migrate dev

# Prisma 클라이언트 생성
npx prisma generate

# 개발 서버 실행
npm run start:dev
```

### 모바일 앱 설정

```bash
cd mobile

# 의존성 설치
flutter pub get

# 코드 생성 (Riverpod, JSON 직렬화 등)
flutter pub run build_runner build

# 개발 실행
flutter run
```

## API 문서

백엔드 실행 후 Swagger UI에서 API 문서를 확인할 수 있습니다:
```
http://localhost:3000/api/docs
```

## 주요 API 엔드포인트

### 인증
- `POST /api/auth/register` - 회원가입
- `POST /api/auth/login` - 로그인
- `POST /api/auth/social-login` - 소셜 로그인

### 아티스트
- `GET /api/artists` - 아티스트 목록
- `GET /api/artists/:id` - 아티스트 상세
- `POST /api/artists/register` - 아티스트 등록

### 구독
- `POST /api/subscriptions` - 구독하기
- `GET /api/subscriptions` - 내 구독 목록
- `DELETE /api/subscriptions/:id` - 구독 취소

### 메시지
- `GET /api/messages/chat-rooms` - 채팅방 목록
- `GET /api/messages/chat-rooms/:id` - 채팅 메시지
- `POST /api/messages/chat-rooms/:id/reply` - 팬 답장
- `POST /api/messages/broadcast` - 아티스트 메시지 발송

## 수익 모델

- 월 구독료: ₩2,000 ~ ₩10,000 (아티스트 설정)
- 플랫폼 수수료: 20%
- 아티스트 수익: 80%

## 라이선스

Private - All Rights Reserved
