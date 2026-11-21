// lib/widgets/app_open_ad_wrapper.dart
import 'package:material_ui/material_ui.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_manager.dart';

class AppOpenAdWrapper extends StatefulWidget {
  final Widget child;
  const AppOpenAdWrapper({super.key, required this.child});

  @override
  State<AppOpenAdWrapper> createState() => _AppOpenAdWrapperState();
}

class _AppOpenAdWrapperState extends State<AppOpenAdWrapper> with WidgetsBindingObserver {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndShowAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkAndShowAd() async {
    bool canShow = await adManager.canShowAppOpenAd();
    if (canShow && !_isShowingAd) {
      _loadAndShowAppOpen();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndShowAd();
    }
  }

  void _loadAndShowAppOpen() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-8052607409788601/8739715237', // Real App Open ID
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _showAd();
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  void _showAd() {
    if (_appOpenAd == null) return;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _appOpenAd?.dispose();
        _appOpenAd = null;
        adManager.recordAppOpenAdShown(); // Resets the 3-hour clock
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        _appOpenAd?.dispose();
        _appOpenAd = null;
      },
    );
    _appOpenAd!.show();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}