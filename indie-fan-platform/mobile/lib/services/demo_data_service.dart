import '../features/artists/models/artist_model.dart';
import '../features/auth/models/user_model.dart';
import '../features/home/models/subscription_model.dart';
import '../features/messages/models/message_model.dart';

/// 데모용 목업 데이터 서비스
class DemoDataService {
  DemoDataService._();

  static final User demoUser = User(
    id: 'user-001',
    email: 'demo@pipo.app',
    nickname: '팬이름',
    profileImage: null, // 기본 아이콘 사용
    role: UserRole.fan,
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
  );

  static final List<Artist> demoArtists = [
    Artist(
      id: 'artist-001',
      userId: 'user-artist-001',
      stageName: '하늘별',
      bio: '안녕하세요! 지하아이돌 하늘별이에요 ✨ 매일 여러분과 소통하고 싶어요!',
      profileImage: 'https://picsum.photos/seed/artist001/400/400',
      coverImage: 'https://picsum.photos/seed/cover001/800/400',
      category: 'IDOL',
      monthlyPrice: 4900,
      subscriberCount: 1247,
      twitterUrl: 'https://twitter.com/hanulbyul',
      instagramUrl: 'https://instagram.com/hanulbyul',
      isSubscribed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Artist(
      id: 'artist-002',
      userId: 'user-artist-002',
      stageName: '미쿠링',
      bio: '메이드카페에서 일하는 미쿠링입니다! 주인님들 기다릴게요~',
      profileImage: 'https://picsum.photos/seed/artist002/400/400',
      coverImage: 'https://picsum.photos/seed/cover002/800/400',
      category: 'MAID',
      monthlyPrice: 3900,
      subscriberCount: 892,
      twitterUrl: 'https://twitter.com/mikuring',
      isSubscribed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 280)),
    ),
    Artist(
      id: 'artist-003',
      userId: 'user-artist-003',
      stageName: '레이나코스',
      bio: '코스프레이어 레이나입니다! 다양한 캐릭터로 찾아갈게요 💕',
      profileImage: 'https://picsum.photos/seed/artist003/400/400',
      coverImage: 'https://picsum.photos/seed/cover003/800/400',
      category: 'COSPLAYER',
      monthlyPrice: 5900,
      subscriberCount: 2156,
      instagramUrl: 'https://instagram.com/reinacos',
      youtubeUrl: 'https://youtube.com/@reinacos',
      isSubscribed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    Artist(
      id: 'artist-004',
      userId: 'user-artist-004',
      stageName: '밤비TV',
      bio: '게임 스트리머 밤비입니다! 같이 게임해요 🎮',
      profileImage: 'https://picsum.photos/seed/artist004/400/400',
      coverImage: 'https://picsum.photos/seed/cover004/800/400',
      category: 'STREAMER',
      monthlyPrice: 2900,
      subscriberCount: 3421,
      youtubeUrl: 'https://youtube.com/@bambitv',
      tiktokUrl: 'https://tiktok.com/@bambitv',
      isSubscribed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    Artist(
      id: 'artist-005',
      userId: 'user-artist-005',
      stageName: '소라',
      bio: '신인 아이돌 소라예요! 함께 성장해나가요 🌸',
      profileImage: 'https://picsum.photos/seed/artist005/400/400',
      coverImage: 'https://picsum.photos/seed/cover005/800/400',
      category: 'IDOL',
      monthlyPrice: 3900,
      subscriberCount: 456,
      twitterUrl: 'https://twitter.com/sora_idol',
      instagramUrl: 'https://instagram.com/sora_idol',
      isSubscribed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Artist(
      id: 'artist-006',
      userId: 'user-artist-006',
      stageName: '유키메이드',
      bio: '오늘도 주인님을 위해 열심히 할게요! 메이드 유키입니다 ♡',
      profileImage: 'https://picsum.photos/seed/artist006/400/400',
      coverImage: 'https://picsum.photos/seed/cover006/800/400',
      category: 'MAID',
      monthlyPrice: 4500,
      subscriberCount: 678,
      twitterUrl: 'https://twitter.com/yukimaid',
      isSubscribed: false,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  static List<Artist> get subscribedArtists =>
      demoArtists.where((a) => a.isSubscribed).toList();

  static final List<Subscription> demoSubscriptions = [
    Subscription(
      id: 'sub-001',
      artistId: 'artist-001',
      artist: demoArtists[0],
      status: SubscriptionStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 127)),
      daysSinceStart: 127,
      autoRenew: true,
      createdAt: DateTime.now().subtract(const Duration(days: 127)),
    ),
    Subscription(
      id: 'sub-002',
      artistId: 'artist-002',
      artist: demoArtists[1],
      status: SubscriptionStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 45)),
      daysSinceStart: 45,
      autoRenew: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Subscription(
      id: 'sub-003',
      artistId: 'artist-005',
      artist: demoArtists[4],
      status: SubscriptionStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 12)),
      daysSinceStart: 12,
      autoRenew: true,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  static final List<ChatRoom> demoChatRooms = [
    ChatRoom(
      id: 'chat-001',
      artistId: 'artist-001',
      artistName: '하늘별',
      artistImage: 'https://picsum.photos/seed/artist001/400/400',
      lastMessage: '오늘 연습 끝나고 뭐 먹을지 고민중이에요~',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 23)),
      unreadCount: 2,
      replyCount: 1,
      maxReplies: 3,
    ),
    ChatRoom(
      id: 'chat-002',
      artistId: 'artist-002',
      artistName: '미쿠링',
      artistImage: 'https://picsum.photos/seed/artist002/400/400',
      lastMessage: '주인님~ 오늘 카페 오실 건가요?',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      replyCount: 2,
      maxReplies: 3,
    ),
    ChatRoom(
      id: 'chat-003',
      artistId: 'artist-005',
      artistName: '소라',
      artistImage: 'https://picsum.photos/seed/artist005/400/400',
      lastMessage: '새 앨범 작업중이에요! 기대해주세요 💕',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 1,
      replyCount: 0,
      maxReplies: 3,
    ),
  ];

  static List<Message> getChatMessages(String chatRoomId) {
    switch (chatRoomId) {
      case 'chat-001':
        return _hanulbyulMessages;
      case 'chat-002':
        return _mikuringMessages;
      case 'chat-003':
        return _soraMessages;
      default:
        return [];
    }
  }

  static final List<Message> _hanulbyulMessages = [
    Message(
      id: 'msg-001',
      chatRoomId: 'chat-001',
      content: '팬이름님 안녕하세요! 오늘 하루는 어떠셨어요? 저는 오늘 안무 연습하느라 바빴어요~',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Message(
      id: 'msg-002',
      chatRoomId: 'chat-001',
      content: '저도 좋은 하루 보냈어요! 연습 힘들지 않으세요?',
      type: MessageType.text,
      senderType: SenderType.fan,
      replyToId: 'msg-001',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    ),
    Message(
      id: 'msg-003',
      chatRoomId: 'chat-001',
      content: '힘들긴 하지만 팬분들 생각하면 힘이 나요! 고마워요 💕',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
    ),
    Message(
      id: 'msg-004',
      chatRoomId: 'chat-001',
      content: 'https://picsum.photos/seed/practice001/400/300',
      type: MessageType.image,
      senderType: SenderType.artist,
      mediaUrl: 'https://picsum.photos/seed/practice001/400/300',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Message(
      id: 'msg-005',
      chatRoomId: 'chat-001',
      content: '오늘 연습 끝나고 뭐 먹을지 고민중이에요~',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 23)),
    ),
    Message(
      id: 'msg-006',
      chatRoomId: 'chat-001',
      content: '치킨 어때요? 저도 지금 치킨 먹고 싶어요 ㅎㅎ',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  static final List<Message> _mikuringMessages = [
    Message(
      id: 'msg-101',
      chatRoomId: 'chat-002',
      content: '주인님~ 좋은 아침이에요! 오늘도 힘내세요 ☀️',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Message(
      id: 'msg-102',
      chatRoomId: 'chat-002',
      content: '좋은 아침이에요~ 오늘도 화이팅!',
      type: MessageType.text,
      senderType: SenderType.fan,
      replyToId: 'msg-101',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 7, minutes: 30)),
    ),
    Message(
      id: 'msg-103',
      chatRoomId: 'chat-002',
      content: '오후에 시프트 시작해요! 오늘 특별 메뉴는 딸기 파르페예요 🍓',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Message(
      id: 'msg-104',
      chatRoomId: 'chat-002',
      content: '딸기 파르페 맛있겠다!',
      type: MessageType.text,
      senderType: SenderType.fan,
      replyToId: 'msg-103',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
    ),
    Message(
      id: 'msg-105',
      chatRoomId: 'chat-002',
      content: '주인님~ 오늘 카페 오실 건가요?',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  static final List<Message> _soraMessages = [
    Message(
      id: 'msg-201',
      chatRoomId: 'chat-003',
      content: '팬이름님, 구독해주셔서 정말 감사해요! 앞으로 잘 부탁드려요 🌸',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Message(
      id: 'msg-202',
      chatRoomId: 'chat-003',
      content: '요즘 보컬 트레이닝 열심히 하고 있어요! 다음 무대에서 더 좋은 모습 보여드릴게요',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Message(
      id: 'msg-203',
      chatRoomId: 'chat-003',
      content: '새 앨범 작업중이에요! 기대해주세요 💕',
      type: MessageType.text,
      senderType: SenderType.artist,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
}
