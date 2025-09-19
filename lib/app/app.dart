import 'package:flutter/material.dart';
import 'routes.dart';
import '../core/themes/app_theme.dart';

class HandWashApp extends StatelessWidget {
  const HandWashApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '손반짝',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}