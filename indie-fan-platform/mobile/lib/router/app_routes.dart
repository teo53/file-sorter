/// 라우트 이름 상수
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String artists = '/artists';
  static const String artistDetail = '/artists/:id';
  static const String messages = '/messages';
  static const String chat = '/messages/:id';
  static const String profile = '/profile';

  // Seisan 관련 라우트
  static const String seisan = '/seisan';
  static const String seisanDetail = '/seisan/:id';
  static const String seisanRequest = '/seisan/request';
  static const String seisanRequestWithArtist = '/seisan/request/:artistId';
  static const String seisanOpen = '/seisan/:id/open';
  static const String seisanQueue = '/seisan/queue';
  static const String seisanRespond = '/seisan/respond/:id';
}
