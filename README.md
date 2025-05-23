🚀 App Card Frontend

Flutter로 구현된 App Card 결제 인증 모바일 프런트엔드입니다.
Ed25519 기반 챌린지/응답 서명, 안전한 키 저장, 생체 인증, 딥링크 연동 기능을 제공합니다.

⸻

📑 목차
	1.	✨ 주요 기능
	2.	⚙️ 준비 사항
	3.	🚀 시작하기
	•	레포지토리 클론
	•	의존성 설치
	•	iOS 설정
	•	실행
	4.	🔗 딥링크 연동
	5.	🔒 보안 및 키 관리
	6.	📂 프로젝트 구조

⸻

✨ 주요 기능
	•	Ed25519 챌린지/응답 서명
	•	서버에서 랜덤 챌린지 발급
	•	로컬 개인키로 서명 후 서버 전송
	•	서버는 공개키로 서명 검증
	•	Flutter Secure Storage
	•	카드별 키쌍(개인키·공개키) 안전 저장
	•	앱 실행 시 키 없으면 자동 생성·서버 등록
	•	생체 인증
	•	Face ID / Touch ID / PIN 인증 후 서명
	•	딥링크 지원
	•	appcard://auth?txn=<거래ID>&merchant=<가맹점명>&amount=<금액>
	•	앱 실행 또는 백그라운드 중 링크 수신 시 자동 네비게이션
	•	다중 카드 지원
	•	스와이프로 카드 선택
	•	카드별 ID, 타입, 이미지, 키 관리

⸻

⚙️ 준비 사항
	•	Flutter SDK (≥2.18)
	•	Xcode (iOS 시뮬레이터·디바이스 테스트용)
	•	백엔드 서버 (예: http://<내-개발-머신-IP>:8080)
	•	iOS 물리 디바이스 테스트 시 유효한 Apple 개발자 인증서

⸻

🚀 시작하기

1. 레포지토리 클론
   ```
   git clone https://github.com/your-org/app_card_front.git
   cd app_card_front
   ```
3. 의존성 설치
   ```
   flutter pub get
   ```
5. ios 설정
   ```
   <key>NSAppTransportSecurity</key>
   <dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
  </dict>
   ```
7. 딥링크 스킴 등록
   	```
	<key>CFBundleURLTypes</key>
	<array>
	  <dict>
	    <key>CFBundleURLName</key>
	    <string>com.wonQ.appcard</string>
	    <key>CFBundleURLSchemes</key>
	    <array>
	      <string>appcard</string>
	    </array>
	  </dict>
	</array>
	```
9. 실행
   ```
	flutter run -d iPhone-13
   ```
