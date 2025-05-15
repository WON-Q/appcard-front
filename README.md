App Card Frontend

Flutter로 구현된 App Card 결제 인증 모바일 프런트엔드입니다.
Ed25519 기반 챌린지/응답 서명, 안전한 키 저장, 생체 인증, 딥링크 연동 기능을 제공합니다.

⸻

목차
	1.	주요 기능
	2.	준비 사항
	3.	시작하기
	•	레포지토리 클론
	•	의존성 설치
	•	iOS 설정
	•	실행
	4.	딥링크 연동
	5.	보안 및 키 관리
	6.	프로젝트 구조

⸻

주요 기능
	•	Ed25519 챌린지/응답 서명
	•	서버에서 랜덤 챌린지 발급
	•	로컬 개인키로 서명 후 서버로 전송
	•	서버는 공개키로 서명 검증
	•	Flutter Secure Storage에 개인키 저장
	•	각 카드별 키쌍(개인키·공개키) 안전 저장
	•	앱 실행 시 키 없으면 자동 생성·등록
	•	생체 인증
	•	Face ID / Touch ID / PIN 인증 후 서명
	•	딥링크 지원
	•	서버에서 appcard://auth?txn=<거래ID>&merchant=<가맹점명>&amount=<금액> 생성
	•	앱 기동 또는 백그라운드 중 링크 수신 시 자동 네비게이션
	•	다중 카드 지원
	•	스와이프로 카드 선택
	•	카드별 ID, 타입, 이미지, 키 관리

⸻

준비 사항
	•	Flutter SDK (≥2.18)
	•	Xcode (iOS 시뮬레이터·디바이스 테스트용)
	•	백엔드 서버(예: http://<내-개발-머신-IP>:8080)
	•	iOS 물리 디바이스 테스트 시 유효한 Apple 개발자 인증서

⸻

3. 시작하기

레포지토리 클론
```
git clone https://github.com/your-org/app_card_front.git
cd app_card_front
```

의존성 설치
```
flutter pub get
```

iOS 설정
	1.	ATS(비암호화 HTTP) 허용
    ios/Runner/Info.plist <dict> 안에 추가:
    ```
    <key>NSAppTransportSecurity</key>
    <dict>
      <key>NSAllowsArbitraryLoads</key>
      <true/>
    </dict>
    ```

	2.	딥링크 스킴 등록
    동일 파일에:
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

  3. 실행
	  •	iOS 시뮬레이터
    ```
    flutter run -d iPhone-13
    ```

	  •	물리 iOS 기기
  	1.	ios/Runner.xcworkspace 를 Xcode로 열고
  	2.	개발 팀 설정 후 빌드(⌘R), 또는:
    ```
    flutter run -d <device-id>
    ```

딥링크 연동
	1.	서버가 다음 형식으로 링크 제공:
  ```
  appcard://auth?txn=txn-20250508-0001&merchant=%28%EC%A3%BC%29%EC%9A%B0%EB%A6%AC%EC%8B%9D%EB%8B%B9&amount=20000
  ```
	2.	터미널에서 (시뮬레이터):
  ```
  xcrun simctl openurl booted "appcard://auth?txn=...&merchant=...&amount=20000"
  ```
프로젝트 구조
```
lib/
├─ main.dart            # 딥링크 초기화 및 네비게이션
├─ screens/
│   ├─ splash_screen.dart
│   ├─ payment_page.dart
│   └─ payment_success_page.dart
├─ widgets/
│   └─ payment_method_item.dart
├─ utils/
│   ├─ KeyManager.dart        # 키 생성·관리
│   └─ secure_storage_util.dart
└─ pubspec.yaml
```

보안 및 키 관리
	•	키 생성: 카드당 최초 실행 시 Ed25519 키쌍 생성
	•	개인키 저장: Flutter Secure Storage
	•	공개키 등록: 백엔드 /authentications/registerKey 호출
	•	서명/검증: 서버가 발급한 챌린지를 개인키로 서명 → 서버에서 Ed25519 공개키로 검증
