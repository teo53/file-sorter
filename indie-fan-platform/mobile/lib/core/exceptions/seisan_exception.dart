/// Seisan 관련 커스텀 예외
///
/// 에러 코드:
/// - NOT_FOUND: 요청을 찾을 수 없음
/// - INVALID_AMOUNT: 유효하지 않은 금액
/// - ALREADY_RESPONDED: 이미 응답된 요청
/// - TEXT_LIMIT_EXCEEDED: 글자 수 초과
/// - NETWORK_ERROR: 네트워크 오류
class SeisanException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  const SeisanException(
    this.message, {
    required this.code,
    this.originalError,
  });

  /// 요청을 찾을 수 없음
  factory SeisanException.notFound([String? id]) {
    return SeisanException(
      id != null ? '정산 요청을 찾을 수 없습니다 (ID: $id)' : '정산 요청을 찾을 수 없습니다',
      code: 'NOT_FOUND',
    );
  }

  /// 유효하지 않은 금액
  factory SeisanException.invalidAmount(int amount) {
    return SeisanException(
      '유효하지 않은 금액입니다: $amount원',
      code: 'INVALID_AMOUNT',
    );
  }

  /// 이미 응답된 요청
  factory SeisanException.alreadyResponded() {
    return const SeisanException(
      '이미 응답된 정산 요청입니다',
      code: 'ALREADY_RESPONDED',
    );
  }

  /// 글자 수 초과
  factory SeisanException.textLimitExceeded(int limit, int actual) {
    return SeisanException(
      '글자 수 제한을 초과했습니다 (제한: $limit자, 현재: $actual자)',
      code: 'TEXT_LIMIT_EXCEEDED',
    );
  }

  /// 네트워크 오류
  factory SeisanException.networkError([dynamic error]) {
    return SeisanException(
      '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
      code: 'NETWORK_ERROR',
      originalError: error,
    );
  }

  @override
  String toString() => 'SeisanException[$code]: $message';

  /// 사용자에게 보여줄 메시지
  String get userMessage => message;
}
