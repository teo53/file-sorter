import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/seisan_model.dart';

/// 정산 상태
class SeisanState {
  final List<SeisanRequest> requests;
  final List<SeisanRequest> pendingQueue; // 아이돌용: 응답 대기 큐
  final bool isLoading;
  final String? error;

  const SeisanState({
    this.requests = const [],
    this.pendingQueue = const [],
    this.isLoading = false,
    this.error,
  });

  SeisanState copyWith({
    List<SeisanRequest>? requests,
    List<SeisanRequest>? pendingQueue,
    bool? isLoading,
    String? error,
  }) {
    return SeisanState(
      requests: requests ?? this.requests,
      pendingQueue: pendingQueue ?? this.pendingQueue,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 정산 Notifier
class SeisanNotifier extends StateNotifier<SeisanState> {
  SeisanNotifier() : super(const SeisanState());

  /// 데모 데이터 로드
  Future<void> loadSeisanRequests() async {
    state = state.copyWith(isLoading: true);

    // 데모 데이터 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      requests: _demoRequests,
      isLoading: false,
    );
  }

  /// 아이돌용: 대기 큐 로드
  Future<void> loadPendingQueue() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      pendingQueue: _demoPendingQueue,
      isLoading: false,
    );
  }

  /// 정산 요청 생성
  Future<SeisanRequest> createRequest({
    required String artistId,
    required String artistName,
    required String artistImage,
    required int amount,
    required bool hasVoiceOption,
    required String requestMessage,
  }) async {
    final tier = SeisanTier.fromAmount(amount);
    if (tier == null) {
      throw Exception('유효하지 않은 금액입니다.');
    }

    final request = SeisanRequest(
      id: 'seisan_${DateTime.now().millisecondsSinceEpoch}',
      fanId: 'fan_1',
      fanNickname: '팬덤러버',
      fanProfileImage: 'https://picsum.photos/seed/fan1/100/100',
      artistId: artistId,
      artistName: artistName,
      artistImage: artistImage,
      amount: hasVoiceOption ? amount + 10000 : amount,
      textLimit: tier.textLimit,
      hasVoiceOption: hasVoiceOption,
      requestMessage: requestMessage,
      status: SeisanStatus.pending,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      requests: [request, ...state.requests],
    );

    return request;
  }

  /// 아이돌: 정산 응답
  Future<void> respondToRequest({
    required String requestId,
    required String responseText,
    String? voiceUrl,
  }) async {
    final index = state.pendingQueue.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final request = state.pendingQueue[index];
    final updatedRequest = request.copyWith(
      status: SeisanStatus.completed,
      responseText: responseText,
      voiceUrl: voiceUrl,
      respondedAt: DateTime.now(),
    );

    // 큐에서 제거
    final newQueue = List<SeisanRequest>.from(state.pendingQueue);
    newQueue.removeAt(index);

    state = state.copyWith(pendingQueue: newQueue);
  }

  /// ID로 정산 요청 조회
  SeisanRequest? getRequestById(String id) {
    return state.requests.where((r) => r.id == id).firstOrNull ??
        state.pendingQueue.where((r) => r.id == id).firstOrNull;
  }
}

/// Provider 정의
final seisanProvider = StateNotifierProvider<SeisanNotifier, SeisanState>(
  (ref) => SeisanNotifier(),
);

/// 완료된 정산만 필터링
final completedSeisanProvider = Provider<List<SeisanRequest>>((ref) {
  final state = ref.watch(seisanProvider);
  return state.requests
      .where((r) => r.status == SeisanStatus.completed)
      .toList();
});

/// 대기 중인 정산만 필터링
final pendingSeisanProvider = Provider<List<SeisanRequest>>((ref) {
  final state = ref.watch(seisanProvider);
  return state.requests.where((r) => r.status == SeisanStatus.pending).toList();
});

// ============================================
// 데모 데이터
// ============================================

final _demoRequests = [
  SeisanRequest(
    id: 'seisan_1',
    fanId: 'fan_1',
    fanNickname: '팬덤러버',
    fanProfileImage: 'https://picsum.photos/seed/fan1/100/100',
    artistId: 'artist_1',
    artistName: '유나',
    artistImage: 'https://picsum.photos/seed/yuna/200/200',
    amount: 10000,
    textLimit: 200,
    hasVoiceOption: false,
    requestMessage: '유나님 항상 응원해요! 다음 앨범 기대하고 있어요 💕',
    status: SeisanStatus.completed,
    responseText: '정말 고마워요! ❤️ 다음 앨범 열심히 준비하고 있으니까 조금만 기다려주세요. 항상 응원해주셔서 힘이 나요!',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    respondedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  SeisanRequest(
    id: 'seisan_2',
    fanId: 'fan_1',
    fanNickname: '팬덤러버',
    fanProfileImage: 'https://picsum.photos/seed/fan1/100/100',
    artistId: 'artist_2',
    artistName: '미나',
    artistImage: 'https://picsum.photos/seed/mina/200/200',
    amount: 20000,
    textLimit: 500,
    hasVoiceOption: true,
    requestMessage: '미나님 생일 축하드려요! 특별한 답장 기다릴게요!',
    status: SeisanStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  SeisanRequest(
    id: 'seisan_3',
    fanId: 'fan_1',
    fanNickname: '팬덤러버',
    fanProfileImage: 'https://picsum.photos/seed/fan1/100/100',
    artistId: 'artist_3',
    artistName: '사쿠라',
    artistImage: 'https://picsum.photos/seed/sakura/200/200',
    amount: 5000,
    textLimit: 100,
    hasVoiceOption: false,
    requestMessage: '첫 정산이에요! 사쿠라님 팬이 됐어요!',
    status: SeisanStatus.completed,
    responseText: '환영해요! 앞으로 자주 놀러와주세요~ 💗',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    respondedAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
];

final _demoPendingQueue = [
  SeisanRequest(
    id: 'queue_1',
    fanId: 'fan_2',
    fanNickname: '별빛소녀',
    fanProfileImage: 'https://picsum.photos/seed/fan2/100/100',
    artistId: 'artist_1',
    artistName: '유나',
    artistImage: 'https://picsum.photos/seed/yuna/200/200',
    amount: 10000,
    textLimit: 200,
    hasVoiceOption: false,
    requestMessage: '유나님 콘서트 너무 좋았어요! 앵콜곡 뭐 부르셨는지 알려주실 수 있나요?',
    status: SeisanStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  SeisanRequest(
    id: 'queue_2',
    fanId: 'fan_3',
    fanNickname: '음악덕후',
    fanProfileImage: 'https://picsum.photos/seed/fan3/100/100',
    artistId: 'artist_1',
    artistName: '유나',
    artistImage: 'https://picsum.photos/seed/yuna/200/200',
    amount: 20000,
    textLimit: 500,
    hasVoiceOption: true,
    requestMessage: '오랜 팬이에요. 음성 메시지로 인사 한번만 해주세요!',
    status: SeisanStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  SeisanRequest(
    id: 'queue_3',
    fanId: 'fan_4',
    fanNickname: '응원단장',
    fanProfileImage: 'https://picsum.photos/seed/fan4/100/100',
    artistId: 'artist_1',
    artistName: '유나',
    artistImage: 'https://picsum.photos/seed/yuna/200/200',
    amount: 3000,
    textLimit: 50,
    hasVoiceOption: false,
    requestMessage: '화이팅!',
    status: SeisanStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
];
