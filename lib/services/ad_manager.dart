// lib/services/ad_manager.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdManager {
  static const String _lastOpenAdTimeKey = 'last_app_open_ad_time';

  DateTime? _sessionStartTime;
  int _interstitialsShownThisSession = 0;

  void startNewSession() {
    _sessionStartTime = DateTime.now();
    _interstitialsShownThisSession = 0;
  }

  bool canShowInterstitial() {
    if (_sessionStartTime == null) {
      startNewSession();
    }

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);

    // Reset session metrics if past 1.5 hours (90 minutes)
    if (sessionDuration.inMinutes >= 90) {
      startNewSession();
    }

    // Limit to 3 ads max per session
    return _interstitialsShownThisSession < 3;
  }

  void recordInterstitialShown() {
    _interstitialsShownThisSession++;
  }

  /// Global helper to show an interstitial ad respecting your 1.5h frequency limit
  void showInterstitialAd() {
    if (canShowInterstitial()) {
      InterstitialAd.load(
        adUnitId: 'ca-app-pub-8052607409788601/4731032517', // Real Interstitial ID
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.show();
            recordInterstitialShown();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
            );
          },
          onAdFailedToLoad: (error) {},
        ),
      );
    }
  }

  Future<bool> canShowAppOpenAd() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeMillis = prefs.getInt(_lastOpenAdTimeKey) ?? 0;

    if (lastTimeMillis == 0) return true;

    final lastShownTime = DateTime.fromMillisecondsSinceEpoch(lastTimeMillis);
    final difference = DateTime.now().difference(lastShownTime);

    // Returns true only if 3 hours or more have elapsed
    return difference.inHours >= 3;
  }

  Future<void> recordAppOpenAdShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastOpenAdTimeKey, DateTime.now().millisecondsSinceEpoch);
  }
}

final adManager = AdManager();