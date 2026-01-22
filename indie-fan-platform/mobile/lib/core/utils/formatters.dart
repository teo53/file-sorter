/// 숫자 및 날짜 포맷 유틸리티
///
/// 사용법:
/// ```dart
/// import 'package:pipo/core/utils/formatters.dart';
///
/// final formatted = 10000.formatCurrency(); // "10,000"
/// final date = DateTime.now().formatRelative(); // "방금 전"
/// ```

/// 숫자 포맷 확장
extension NumberFormatting on int {
  /// 천 단위 콤마 포맷 (예: 10000 → "10,000")
  String formatCurrency() {
    return toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  /// 원화 포맷 (예: 10000 → "10,000원")
  String formatKRW() {
    return '${formatCurrency()}원';
  }
}

/// 날짜 포맷 확장
extension DateFormatting on DateTime {
  /// 상대적 시간 포맷 (예: "방금 전", "5분 전", "3일 전")
  String formatRelative() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${month}월 ${day}일';
    }
  }

  /// 상대적 시간 포맷 (alias for formatRelative)
  String timeAgo() => formatRelative();

  /// 전체 날짜/시간 포맷 (예: "2024.01.15 14:30")
  String formatFull() {
    return '$year.${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')} '
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// 날짜만 포맷 (예: "2024.01.15")
  String formatDate() {
    return '$year.${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')}';
  }

  /// 같은 날인지 확인
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// 오늘인지 확인
  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  /// 어제인지 확인
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// 채팅용 날짜 구분선 포맷
  String formatChatDivider() {
    if (isToday) {
      return '오늘';
    } else if (isYesterday) {
      return '어제';
    } else {
      return '${month}월 ${day}일';
    }
  }
}
