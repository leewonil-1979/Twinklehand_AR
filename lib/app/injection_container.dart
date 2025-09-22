import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../services/audio_service.dart';
import '../features/camera/data/services/camera_service.dart';
import '../services/mediapipe_service.dart';
import '../features/ar_effects/data/services/effects_service.dart';
import '../features/gallery/data/services/gallery_service.dart';
import '../features/monetization/ads/data/services/admob_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Services
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt()),
  );
  
  getIt.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(),
  );
  
  getIt.registerLazySingleton<AudioService>(
    () => AudioService(),
  );
  
  // Feature services
  getIt.registerLazySingleton<CameraService>(
    () => CameraService(),
  );
  
  getIt.registerLazySingleton<MediaPipeService>(
    () => MediaPipeService(),
  );
  
  getIt.registerLazySingleton<EffectsService>(
    () => EffectsService(),
  );
  
  getIt.registerLazySingleton<GalleryService>(
    () => GalleryService(),
  );
  
  getIt.registerLazySingleton<AdMobService>(
    () => AdMobService(),
  );
  
  // Initialize services
  await getIt<AnalyticsService>().initialize();
  await getIt<AudioService>().initialize();
}