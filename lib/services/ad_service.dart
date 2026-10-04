// Ad service — заглушка (можно подключить google_mobile_ads позже)
class AdService {
  static final AdService _instance = AdService._();
  AdService._();
  factory AdService() => _instance;

  Future<bool> showRewardedAd() async {
    // Симуляция просмотра рекламы
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
