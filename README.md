# ✨ TwinkleHands AR - 반짝반짝 깨끗한 몸!

아이들이 즐겁게 씻기를 배울 수 있는 AR 기반 교육 앱입니다.

## 🌟 주요 특징

### 🎯 자동 신체 감지
- **카메라가 자동으로 신체 부위 인식**
- 손, 얼굴, 발 등을 구분 없이 자동 감지
- MediaPipe/ML Kit 기반 실시간 처리
- 아기 친화적인 부드러운 인식

### 🦠 더러운 모드
- 세균과 벌레 아이콘이 신체 주변에 표시
- 아이들이 씻어야 할 필요성을 시각적으로 인지
- 다양한 재미있는 애니메이션

### ✨ 깨끗한 모드
- 반짝이는 별과 무지개 효과
- 씻은 후의 깨끗함을 시각적으로 표현
- 긍정적 피드백으로 동기부여

### 📸 사진 촬영
- 전/후 비교 사진 저장
- 갤러리 자동 저장
- 가족과 공유 가능

## 🚀 시작하기

### 필수 요구사항
- Flutter 3.0.0 이상
- Dart 3.0.0 이상
- iOS 11.0 이상 / Android 21 이상

### 설치 방법

1. **프로젝트 클론**
```bash
git clone https://github.com/yourusername/twinkle_hands_ar.git
cd twinkle_hands_ar
```

2. **패키지 설치**
```bash
flutter pub get
```

3. **iOS 설정** (iOS만 해당)
```bash
cd ios
pod install
cd ..
```

4. **실행**
```bash
flutter run
```

## 📂 프로젝트 구조

```
lib/
├── app/                    # 앱 설정
├── core/                   # 핵심 상수, 테마
├── features/               # 기능별 모듈
│   ├── camera/            # 카메라 기능
│   ├── ar_effects/        # AR 효과
│   ├── mediapipe/         # 자동 신체 감지
│   ├── gallery/           # 갤러리 저장
│   ├── home/              # 메인 화면
│   ├── settings/          # 설정
│   └── monetization/      # 광고/결제
├── providers/             # 상태 관리
├── services/              # 전역 서비스
└── shared/                # 공유 컴포넌트
```

## 🔧 설정

### Android 권한 (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>

<!-- MainActivity에 추가 -->
<meta-data 
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_ADMOB_ID"/>
```

### iOS 권한 (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>카메라를 사용하여 AR 효과를 보여드립니다</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>촬영한 사진을 갤러리에 저장합니다</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>촬영한 사진을 앨범에 추가합니다</string>

<!-- AdMob -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_ADMOB_ID</string>
```

## 🎮 사용 방법

1. **앱 실행** - 자동으로 카메라가 켜집니다
2. **신체 감지** - 카메라에 비춘 신체 부위를 자동으로 감지합니다
3. **모드 전환** - "✨ 깨끗하게 변신!" 버튼으로 전환
4. **아이콘 선택** - 상단에서 원하는 아이콘 선택
5. **사진 촬영** - 중앙 카메라 버튼으로 촬영

## 🎨 커스터마이징

### 아이콘 변경
`lib/core/constants/app_icons.dart`에서 아이콘 수정:
```dart
static const List<String> dirtyIcons = [
  '🦠', '💩', '🪲', '🕷️', '🦟', '🪰'
];
static const List<String> cleanIcons = [
  '✨', '🌟', '💫', '🌈', '💎', '🌸'
];
```

### 색상 테마 변경
`lib/core/constants/app_colors.dart`에서 색상 수정

## 💰 수익 모델

### 광고
- 배너 광고: 하단 고정
- 전면 광고: 5회 촬영마다

### 프리미엄 기능 ($2.99)
- ✅ 광고 제거
- ✅ 모든 아이콘 잠금 해제
- ✅ 특별 효과
- ✅ 무제한 촬영

## 📱 지원 기기

- **Android**: 5.0 (API 21) 이상
- **iOS**: 11.0 이상
- **권장**: 2GB RAM 이상

## 🛠️ 기술 스택

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Navigation**: go_router
- **Camera**: camera package
- **Body Detection**: ML Kit / MediaPipe
- **Storage**: shared_preferences
- **Ads**: Google AdMob
- **IAP**: in_app_purchase

## 🐛 알려진 이슈

1. **저조도 환경**: 어두운 곳에서 감지 정확도 감소
2. **구형 기기**: 일부 오래된 기기에서 성능 저하
3. **배터리**: AR 효과로 인한 배터리 소모

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

MIT License - 자유롭게 사용하세요!

## 📞 문의

- Email: support@twinklehands.app
- Website: https://twinklehands.app
- Issues: [GitHub Issues](https://github.com/yourusername/twinkle_hands_ar/issues)

## 🙏 Special Thanks

- Flutter Team
- MediaPipe / ML Kit Team
- All Open Source Contributors
- Parents and Kids who love TwinkleHands!

---

**Made with ❤️ for children's health and happiness**

*TwinkleHands AR - Making hygiene fun!* ✨🧼🌟