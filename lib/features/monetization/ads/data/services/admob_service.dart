import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdMobService {
  static const bool _testMode = kDebugMode;
  
  // Test Ad IDs (replace with real IDs in production)
  static String get bannerAdUnitId {
    if (_testMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'  // Test banner
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    // TODO: Add production ad unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-YOUR_ADMOB_ID/YOUR_BANNER_ID'
        : 'ca-app-pub-YOUR_ADMOB_ID/YOUR_BANNER_ID';
  }
  
  static String get interstitialAdUnitId {
    if (_testMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'  // Test interstitial
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    // TODO: Add production ad unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-YOUR_ADMOB_ID/YOUR_INTERSTITIAL_ID'
        : 'ca-app-pub-YOUR_ADMOB_ID/YOUR_INTERSTITIAL_ID';
  }
  
  static String get rewardedAdUnitId {
    if (_testMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'  // Test rewarded
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    // TODO: Add production ad unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-YOUR_ADMOB_ID/YOUR_REWARDED_ID'
        : 'ca-app-pub-YOUR_ADMOB_ID/YOUR_REWARDED_ID';
  }
  
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  bool _isInitialized = false;
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;
  
  bool get isInitialized => _isInitialized;
  bool get isBannerAdReady => _isBannerAdReady;
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isRewardedAdReady => _isRewardedAdReady;
  
  BannerAd? get bannerAd => _bannerAd;
  
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob initialized');
      
      // Load ads
      await loadBannerAd();
      await loadInterstitialAd();
      await loadRewardedAd();
    } catch (e) {
      debugPrint('Error initializing AdMob: $e');
      _isInitialized = false;
    }
  }
  
  Future<void> loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('Banner ad loaded');
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          _isBannerAdReady = false;
          _bannerAd = null;
        },
      ),
    );
    
    await _bannerAd?.load();
  }
  
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }
  
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('Rewarded ad loaded');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }
  
  Future<void> showInterstitialAd() async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not ready');
      await loadInterstitialAd();
    }
  }
  
  Future<void> showRewardedAd({
    required Function(int amount) onRewarded,
  }) async {
    if (_isRewardedAdReady && _rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          onRewarded(reward.amount.toInt());
        },
      );
    } else {
      debugPrint('Rewarded ad not ready');
      await loadRewardedAd();
    }
  }
  
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}