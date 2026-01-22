/// 정산 상태
enum SeisanStatus {
  pending,   // 대기 중 (아이돌 응답 대기)
  completed, // 완료 (응답 받음)
  expired,   // 만료
  canceled,  // 취소됨
}

/// 정산 금액별 텍스트 제한
class SeisanTier {
  final int amount;
  final int textLimit;
  final String description;

  const SeisanTier({
    required this.amount,
    required this.textLimit,
    required this.description,
  });

  static const List<SeisanTier> tiers = [
    SeisanTier(
      amount: 3000,
      textLimit: 50,
      description: '짧은 인사',
    ),
    SeisanTier(
      amount: 5000,
      textLimit: 100,
      description: '간단한 메시지',
    ),
    SeisanTier(
      amount: 10000,
      textLimit: 200,
      description: '정성스러운 답장',
    ),
    SeisanTier(
      amount: 20000,
      textLimit: 500,
      description: '특별한 편지',
    ),
  ];

  static SeisanTier? fromAmount(int amount) {
    return tiers.where((t) => t.amount == amount).firstOrNull;
  }
}

/// 정산 요청 모델
class SeisanRequest {
  final String id;
  final String fanId;
  final String fanNickname;
  final String fanProfileImage;
  final String artistId;
  final String artistName;
  final String artistImage;
  final int amount;
  final int textLimit;
  final bool hasVoiceOption;
  final String requestMessage;
  final SeisanStatus status;
  final String? responseText;
  final String? voiceUrl;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const SeisanRequest({
    required this.id,
    required this.fanId,
    required this.fanNickname,
    required this.fanProfileImage,
    required this.artistId,
    required this.artistName,
    required this.artistImage,
    required this.amount,
    required this.textLimit,
    required this.hasVoiceOption,
    required this.requestMessage,
    required this.status,
    this.responseText,
    this.voiceUrl,
    required this.createdAt,
    this.respondedAt,
  });

  /// 응답이 하트 이모지를 포함하는지 확인
  bool get hasHeartEffect =>
      responseText?.contains('❤') == true ||
      responseText?.contains('💕') == true ||
      responseText?.contains('💗') == true ||
      responseText?.contains('💖') == true;

  /// 정산이 열린 적 있는지 (응답 완료됨)
  bool get isOpened => status == SeisanStatus.completed && responseText != null;

  SeisanRequest copyWith({
    String? id,
    String? fanId,
    String? fanNickname,
    String? fanProfileImage,
    String? artistId,
    String? artistName,
    String? artistImage,
    int? amount,
    int? textLimit,
    bool? hasVoiceOption,
    String? requestMessage,
    SeisanStatus? status,
    String? responseText,
    String? voiceUrl,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return SeisanRequest(
      id: id ?? this.id,
      fanId: fanId ?? this.fanId,
      fanNickname: fanNickname ?? this.fanNickname,
      fanProfileImage: fanProfileImage ?? this.fanProfileImage,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      artistImage: artistImage ?? this.artistImage,
      amount: amount ?? this.amount,
      textLimit: textLimit ?? this.textLimit,
      hasVoiceOption: hasVoiceOption ?? this.hasVoiceOption,
      requestMessage: requestMessage ?? this.requestMessage,
      status: status ?? this.status,
      responseText: responseText ?? this.responseText,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
