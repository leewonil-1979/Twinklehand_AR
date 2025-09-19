import 'package:flutter/material.dart';
import 'routes.dart';
import '../core/themes/app_theme.dart';

class TwinkleHandsApp extends StatelessWidget {
  const TwinkleHandsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TwinkleHands AR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}