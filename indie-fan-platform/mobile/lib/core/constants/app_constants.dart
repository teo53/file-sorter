class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'IndieFan';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Message
  static const int maxReplyCount = 3;
  static const int maxReplyLength = 100;

  // Subscription
  static const int minSubscriptionPrice = 2000;
  static const int maxSubscriptionPrice = 10000;

  // Animation
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_complete';
}

class ArtistCategory {
  static const String idol = 'IDOL';
  static const String maid = 'MAID';
  static const String cosplayer = 'COSPLAYER';
  static const String streamer = 'STREAMER';
  static const String other = 'OTHER';

  static String toDisplayName(String category) {
    switch (category) {
      case idol:
        return '아이돌';
      case maid:
        return '메이드';
      case cosplayer:
        return '코스어';
      case streamer:
        return '스트리머';
      case other:
        return '기타';
      default:
        return category;
    }
  }
}
