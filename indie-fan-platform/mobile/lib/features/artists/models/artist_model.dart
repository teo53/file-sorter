class Artist {
  final String id;
  final String userId;
  final String stageName;
  final String? bio;
  final String? profileImage;
  final String? coverImage;
  final String category;
  final int monthlyPrice;
  final int subscriberCount;
  final String? twitterUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? tiktokUrl;
  final bool isSubscribed;
  final DateTime createdAt;

  Artist({
    required this.id,
    required this.userId,
    required this.stageName,
    this.bio,
    this.profileImage,
    this.coverImage,
    required this.category,
    required this.monthlyPrice,
    this.subscriberCount = 0,
    this.twitterUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.isSubscribed = false,
    required this.createdAt,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stageName: json['stageName'] as String,
      bio: json['bio'] as String?,
      profileImage: json['profileImage'] as String?,
      coverImage: json['coverImage'] as String?,
      category: json['category'] as String,
      monthlyPrice: json['monthlyPrice'] as int,
      subscriberCount: json['subscriberCount'] as int? ?? 0,
      twitterUrl: json['twitterUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stageName': stageName,
      'bio': bio,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'category': category,
      'monthlyPrice': monthlyPrice,
      'subscriberCount': subscriberCount,
      'twitterUrl': twitterUrl,
      'instagramUrl': instagramUrl,
      'youtubeUrl': youtubeUrl,
      'tiktokUrl': tiktokUrl,
      'isSubscribed': isSubscribed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedPrice => '${(monthlyPrice / 1000).toStringAsFixed(0)}천원/월';
  String get formattedSubscriberCount => '$subscriberCount명';
}
