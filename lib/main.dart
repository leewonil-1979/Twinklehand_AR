import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const SparkleHandApp());
}

class SparkleHandApp extends StatelessWidget {
  const SparkleHandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '반짝손AR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'NotoSansKR', // 한글 폰트 지정
      ),
      home: const CameraScreen(),
    );
  }
}
