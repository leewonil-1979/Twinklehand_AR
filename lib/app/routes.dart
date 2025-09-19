import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/main_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/monetization/purchases/presentation/screens/premium_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
  ],
);