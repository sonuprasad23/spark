import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User model
class SparkUser {
  final String id;
  final String phoneNumber;
  final String? email;
  final String name;
  final int age;
  final String gender;
  final String city;
  final List<String> photos;
  final String bio;
  final List<String> interests;
  final Map<String, String> prompts;
  final bool isVerified;
  final bool isPremium;
  final String? premiumTier;
  final DateTime? premiumExpiresAt;
  final int matchesPerWeek;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SparkUser({
    required this.id,
    required this.phoneNumber,
    this.email,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    this.photos = const [],
    this.bio = '',
    this.interests = const [],
    this.prompts = const {},
    this.isVerified = false,
    this.isPremium = false,
    this.premiumTier,
    this.premiumExpiresAt,
    this.matchesPerWeek = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  SparkUser copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? name,
    int? age,
    String? gender,
    String? city,
    List<String>? photos,
    String? bio,
    List<String>? interests,
    Map<String, String>? prompts,
    bool? isVerified,
    bool? isPremium,
    String? premiumTier,
    DateTime? premiumExpiresAt,
    int? matchesPerWeek,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SparkUser(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      photos: photos ?? this.photos,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      prompts: prompts ?? this.prompts,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      premiumTier: premiumTier ?? this.premiumTier,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      matchesPerWeek: matchesPerWeek ?? this.matchesPerWeek,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'city': city,
      'photos': photos,
      'bio': bio,
      'interests': interests,
      'prompts': prompts,
      'isVerified': isVerified,
      'isPremium': isPremium,
      'premiumTier': premiumTier,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'matchesPerWeek': matchesPerWeek,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SparkUser.fromJson(Map<String, dynamic> json) {
    return SparkUser(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      city: json['city'] as String,
      photos: List<String>.from(json['photos'] ?? []),
      bio: json['bio'] as String? ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      prompts: Map<String, String>.from(json['prompts'] ?? {}),
      isVerified: json['isVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumTier: json['premiumTier'] as String?,
      premiumExpiresAt: json['premiumExpiresAt'] != null
          ? DateTime.parse(json['premiumExpiresAt'] as String)
          : null,
      matchesPerWeek: json['matchesPerWeek'] as int? ?? 5,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Sample user for testing
  static SparkUser get sample => SparkUser(
    id: 'user_123',
    phoneNumber: '+919876543210',
    name: 'Test User',
    age: 24,
    gender: 'male',
    city: 'Bangalore',
    photos: ['photo1.jpg', 'photo2.jpg'],
    bio: 'Love traveling and photography!',
    interests: ['Travel', 'Photography', 'Music', 'Food'],
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );
}
