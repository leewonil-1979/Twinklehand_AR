import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'app/app.dart';
import 'app/injection_container.dart';
import 'providers/app_state_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/ar_effects_provider.dart';
import 'providers/mediapipe_provider.dart';
import 'services/permission_service.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 화면 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // 의존성 주입 초기화
  await configureDependencies();
  
  // 권한 요청
  await PermissionService.requestAllPermissions();
  
  // 카메라 초기화
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('카메라 초기화 실패: $e');
    cameras = [];
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => AREffectsProvider()),
        ChangeNotifierProvider(create: (_) => MediaPipeProvider()),
      ],
      child: const TwinkleHandsApp(), // 앱 이름 변경
    ),
  );
}