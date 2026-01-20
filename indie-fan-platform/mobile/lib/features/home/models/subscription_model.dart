import '../../../features/artists/models/artist_model.dart';

enum SubscriptionStatus { active, cancelled, expired, paused }

class Subscription {
  final String id;
  final String artistId;
  final Artist? artist;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final int daysSinceStart;
  final bool autoRenew;
  final DateTime createdAt;

  Subscription({
    required this.id,
    required this.artistId,
    this.artist,
    required this.status,
    required this.startDate,
    this.endDate,
    this.daysSinceStart = 0,
    this.autoRenew = true,
    required this.createdAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      artistId: json['artistId'] as String,
      artist: json['artist'] != null
          ? Artist.fromJson(json['artist'] as Map<String, dynamic>)
          : null,
      status: _parseStatus(json['status'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      daysSinceStart: json['daysSinceStart'] as int? ?? 0,
      autoRenew: json['autoRenew'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static SubscriptionStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return SubscriptionStatus.cancelled;
      case 'EXPIRED':
        return SubscriptionStatus.expired;
      case 'PAUSED':
        return SubscriptionStatus.paused;
      default:
        return SubscriptionStatus.active;
    }
  }

  bool get isActive => status == SubscriptionStatus.active;

  String get anniversaryText {
    if (daysSinceStart >= 365) {
      final years = daysSinceStart ~/ 365;
      return '${years}주년';
    } else if (daysSinceStart >= 100) {
      return '${daysSinceStart}일';
    }
    return 'D+$daysSinceStart';
  }

  bool get hasAnniversary =>
      daysSinceStart == 100 ||
      daysSinceStart == 200 ||
      daysSinceStart == 300 ||
      daysSinceStart % 365 == 0;
}
