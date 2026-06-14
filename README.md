# Re:view

<p align="center">
  <b>실사용 리뷰 기반 쇼핑 신뢰도 분석 서비스</b><br/>
  상품 검색부터 리뷰 신뢰도 확인, 가격 비교, 관심 상품 관리까지 하나의 흐름으로 설계한 통합 이커머스 솔루션
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Spring_Boot-6DB33F?style=flat-square&logo=springboot&logoColor=white" alt="Spring Boot" />
  <img src="https://img.shields.io/badge/Java-007396?style=flat-square&logo=java&logoColor=white" alt="Java" />
  <img src="https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/Redis-DC382D?style=flat-square&logo=redis&logoColor=white" alt="Redis" />
  <img src="https://img.shields.io/badge/Azure-0089D6?style=flat-square&logo=microsoftazure&logoColor=white" alt="Azure" />
</p>

<br/>

<table>
  <tr>
    <td colspan="2" align="center">
      <img src="./home.png" alt="Home screen" width="92%" /><br/>
      <b>Home</b><br/>
      리뷰 기반 추천 상품과 카테고리 탐색
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="./search.png" alt="Search results screen" width="88%" /><br/>
      <b>Search Results</b><br/>
      RTI, 가격, 리뷰 조건 기반 상품 비교
    </td>
    <td align="center" width="50%">
      <img src="./product-detail.png" alt="Product detail screen" width="88%" /><br/>
      <b>Product Detail</b><br/>
      리뷰 신뢰도 요약과 판매처별 가격 정보 제공
    </td>
  </tr>
</table>

## 📢 Demo & Materials

프로젝트의 실제 구동 화면과 상세한 기술 설계 내용이 담긴 발표 자료를 확인하실 수 있습니다.

* **🎬 [Re:view 서비스 시연 영상 보러가기](https://youtu.be/rIGmGRdqm48)**
* **📄 [FireView 프로젝트 1학기 발표 자료 (PPTX) 다운로드](./FireView%20프로젝트%201학기%20발표.pptx)

---

## 🎯 Overview

Re:view는 사용자가 온라인 쇼핑 과정에서 광고성 리뷰와 실제 구매 후기를 구분하고, 더 신뢰도 높은 상품을 선택할 수 있도록 돕는 **리뷰 신뢰도 분석(RTI) 서비스**입니다.<br/>
단순 상품 목록 나열에 그치지 않고 `검색 → 필터링 → 상품 비교 → 상세 분석 → 찜/장바구니 관리`로 이어지는 실제 유저의 구매 의사결정 흐름을 상용 제품 수준으로 구현하는 데 집중했습니다.

## 🚨 Problem

기존 이커머스 쇼핑 경험은 다음과 같은 명확한 한계를 지니고 있습니다.

- **정보의 비대칭성:** 리뷰 수와 단순 별점만으로는 실제 구매자의 '진짜 후기'를 판단하기 어려움
- **탐색 피로도:** 여러 판매처의 가격, 배송, 리뷰 정보를 한 번에 묶어서 비교하기 번거로움
- **분석의 지연:** 대량의 리뷰를 실시간으로 크롤링하고 AI로 분석할 경우 심각한 서버 병목(Bottleneck) 현상 발생

## 💡 Solution & System Architecture

이 문제를 근본적으로 해결하기 위해 Re:view는 **RTI (Re:view Trust Index)** 지표를 도입하고, 서버 부하를 방지하는 **비동기 큐(Queue) 기반 마이크로서비스 아키텍처**를 설계했습니다.

1. **프론트엔드 (Flutter):** 상품 분석 요청 후 대기 상태 UI 렌더링
2. **백엔드 (Spring Boot):** DB(`product_analysis_job`)에 분석 Job(상태: `PENDING`)을 생성하고, Redis Queue에 작업을 퍼블리싱. 프론트와는 SSE(Server-Sent Events)로 연결 유지.
3. **AI 서버 (FastAPI):** Redis Queue를 구독(Consume)하는 백그라운드 Worker가 작업을 가로채어 리뷰 크롤링 및 KoELECTRA 모델 기반 RTI 분석 수행 (상태: `RUNNING`)
4. **결과 반환:** AI 분석 완료 시 DB 상태를 `DONE`으로 변경하고, Spring이 SSE를 통해 프론트엔드로 알림 푸시(Push).

## ✨ Core Features

- **지능형 홈 대시보드:** 배너, 개인화 카테고리, 인기 키워드, 리뷰 기반 추천 상품 제공
- **강력한 검색 및 다중 필터링:** RTI 점수, 가격대, 배송, 판매처, 리뷰 수 기반 필터링
- **상품 상세 분석 & Risk Report:** 리뷰 원문 내 광고성 문구 및 위험 신호를 감지하여 대시보드 형태로 제공
- **보안 및 인증:** JWT 기반 네이버/Google OAuth2 소셜 로그인 지원
- **실시간 비동기 알림:** 긴 AI 분석 시간을 사용자가 지루하지 않게 기다릴 수 있도록 SSE 기반의 실시간 진행 상태 푸시

## 🛠 Tech Stack

| Layer | Stack | Description |
| --- | --- | --- |
| **Frontend** | `Flutter`, `Riverpod`, `GoRouter` | Web, Android, iOS 크로스 플랫폼 UI 및 도메인 기반 상태 관리 |
| **Backend** | `Spring Boot`, `Spring Data JPA`, `Spring Security` | 메인 비즈니스 API, OAuth2 인증, SSE 실시간 통신, 도메인 설계 |
| **AI / Data** | `FastAPI`, `KoELECTRA`, `PyTorch` | 리뷰 데이터 크롤링 Worker, 텍스트 분석 및 RTI 스코어링 모델 |
| **Infra & DB** | `MySQL`, `Redis`, `Azure VM`, `Docker` | RDBMS 데이터 영속성, Job Queue 처리용 Redis, CI/CD 자동 배포 |

## 📂 Project Structure

프로젝트는 프론트엔드, 백엔드, AI 모듈로 분리되어 독립적으로 배포됩니다.

### 1. Frontend (`lib/`)
```text
lib/
├── app/          # 앱 전반의 설정 (라우팅, 테마, 반응형 유틸)
├── core/         # 공통 비즈니스 로직 및 네트워크(Dio), 결과 래퍼
├── features/     # 도메인 기반 철저히 분리된 기능 모듈 (auth, cart, product_detail 등)
└── shared/       # 전역적으로 재사용되는 UI 위젯 및 확장 함수

## 2. Backend (`review-backend/`)

```text
src/main/java/com/example/fireview/
├── global/       # 시큐리티, 예외 처리, Redis/JWT/SSE 공통 설정
└── domain/       # 도메인 주도 설계(DDD) 기반 모듈 분리
    ├── ai/       # AI 서버 통신 클라이언트 및 SSE Emitter 관리
    ├── auth/     # OAuth2, JWT 발급 및 인증 로직
    ├── product/  # 상품 정보 조회 및 DB 저장
    ├── review/   # 리뷰 데이터 및 피드백 처리
    └── search/   # 네이버 쇼핑 API 연동 및 캐싱
```

## 3. AI Server (`review-ai-db/`)

```text
review-ai-db/
├── main.py                 # FastAPI 진입점 및 실시간 분석용 엔드포인트
├── worker/                 # Redis Queue를 구독하며 비동기 작업을 처리하는 백그라운드 워커
├── crawler/                # 상품 URL 기반 리뷰 데이터 수집 모듈
├── ai/                     # KoELECTRA 기반 감성 분석 및 RTI 스코어링 엔진 모듈
└── database/               # 분석 상태(Job) 및 최종 결과 저장용 DB 연동 모듈
```

## 🏗 Technical Highlights

| Area              | Decision                                         | Impact                                                     |
| ----------------- | ------------------------------------------------ | ---------------------------------------------------------- |
| 비동기 큐(Queue) 아키텍처 | Spring Boot와 FastAPI 사이에 Redis Queue 도입          | 대량의 리뷰 크롤링 및 AI 분석 시 발생하는 메인 API 서버 병목 현상과 HTTP 타임아웃 완벽 차단 |
| 실시간 알림 (SSE)      | 클라이언트-서버 간 Polling 대신 Server-Sent Events(SSE) 적용 | 불필요한 API 호출을 줄이고 AI 분석이 완료되는 즉시 프론트엔드에 상태를 Push하여 UX 극대화   |
| 도메인 기반 클린 아키텍처    | Front(Feature 분리) 및 Backend(Domain 패키지 분리) 설계    | 각 비즈니스 로직의 결합도를 낮춰 유지보수성을 극대화하고 팀원 간 병렬 개발 가능              |
| AI 모델 경량화 및 파인튜닝  | 한국어 자연어 처리에 특화된 KoELECTRA 채택                     | 허위 리뷰 및 광고성 텍스트의 미세한 뉘앙스를 빠르고 정확하게 분류 (Safe/Warn/Danger)   |
| 보안 강화 CI/CD 파이프라인 | GitHub Secrets를 활용한 .env 자동 조립 배포 스크립트 구축        | 민감한 DB 및 Redis 비밀번호 노출 없이 Azure 서버에 도커 컨테이너를 안전하게 무중단 배포   |

## 🔧 Troubleshooting

| Issue                  | Approach                                                               | Result                                                        |
| ---------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------- |
| AI 분석 타임아웃(Timeout) 에러 | 실시간 HTTP 호출(REST) 방식에서 Redis 기반 Job Queue 비동기 워커(Worker) 방식으로 구조 전면 개편 | 아무리 긴 분석 작업이라도 서버가 뻗지 않고 백그라운드에서 안전하게 처리됨                     |
| 프론트 페이지 접근 제어 충돌       | isLoggedInProvider를 감시하는 Router Refresh Notifier 구현                    | 인증된 유저와 비인증 유저 간의 페이지 Redirect 무한 루프 해결 및 흐름 안정화              |
| 찜/장바구니 상태 불일치          | 상품 ID 기반 개별 Provider 적용 및 목록 Snapshot Invalidation 기법 활용               | 검색 결과, 상품 상세, 장바구니 탭 등 여러 화면을 오가더라도 담기/취소 상태 실시간 동기화          |
| 외부 이미지 로딩 지연/실패        | 공통 네트워크 이미지 위젯 래핑 및 shimmer, errorBuilder 적용                           | 이미지 로딩 중 스켈레톤 UI를 보여주고, 링크 만료 시 기본 Placeholder 노출로 레이아웃 붕괴 방지 |

## 🧪 Testing

### Backend

* JUnit5와 Mockito를 활용한 도메인별 단위 테스트
* JWT 인증 테스트
* Redis 통신 테스트

### AI

* 크롤러 모듈 단위 테스트
* NLP 감성 분석 엔진 파이프라인 테스트
* RTI 분석 결과 검증

### Frontend

* 인증 UseCase 로직 검증
* 무한 스크롤 최적화 테스트
* Riverpod 상태 관리 테스트

## 💻 Running Locally

프로젝트는 각 환경별로 아래와 같이 실행할 수 있습니다.

### 1. Database & 인프라 (Docker Compose)

```bash
cd review-ai-db
docker-compose up -d --build
```

### 2. Backend (Spring Boot)

```bash
cd review-backend

./gradlew build
./gradlew bootRun
```

### 3. Frontend (Flutter)

```bash
flutter pub get

# API 주소 환경변수 주입 실행
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## 🧑‍💻 Contributors

| 이름  | 역할               | 담당                                                   |
| --- | ---------------- | ---------------------------------------------------- |
| 김동환 | PM & Cloud Infra | 팀장, 프로젝트 총괄 및 Azure 기반 Redis 비동기 처리 아키텍처 설계 |
| 정빈  | Frontend         | Flutter 기반 Web/App 크로스플랫폼 UI/UX 및 Riverpod 상태 관리 구현  |
| 남정현 | Backend          | Spring Boot 기반 메인 비즈니스 API 개발 및 SSE 실시간 알림 파이프라인 구축  |
| 김하연 | AI & Data        | FastAPI 기반 리뷰 크롤링 Worker 구현 및 KoELECTRA AI 분석 모델 연동  |
