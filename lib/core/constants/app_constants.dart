/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SPARK';
  static const String appTagline = 'Dating that means more';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String profilesCollection = 'profiles';
  static const String questionnairesCollection = 'questionnaires';
  static const String matchesCollection = 'matches';
  static const String connectionRoomsCollection = 'connection_rooms';
  static const String reportsCollection = 'reports';
  static const String reputationScoresCollection = 'reputation_scores';
  static const String subscriptionsCollection = 'subscriptions';
  
  // Realtime DB Paths
  static const String messagesPath = 'messages';
  static const String typingPath = 'typing';
  static const String presencePath = 'presence';
  
  // Limits
  static const int minPhotos = 2;
  static const int maxPhotos = 6;
  static const int maxBioLength = 300;
  static const int maxPromptAnswerLength = 150;
  static const int maxPrompts = 3;
  static const int maxInterests = 10;
  static const int minAge = 18;
  static const int maxAge = 50;
  
  // Match Limits by Tier
  static const int freeMatchesPerWeek = 5;
  static const int plusMatchesPerWeek = 7;
  static const int proMatchesPerWeek = 10;
  
  // Room Configuration
  static const int roomDurationDays = 7;
  static const int extensionDays = 3;
  static const int maxExtensionsFree = 0;
  static const int maxExtensionsPlus = 1;
  static const int maxExtensionsPro = 3;
  
  // Questionnaire
  static const int totalQuestions = 25;
  static const int questionsPerCategory = 5;
  
  // Voice Notes
  static const int maxVoiceNoteDuration = 60; // seconds
  
  // Pricing (in paise for Razorpay)
  static const int plusMonthlyPrice = 19900;
  static const int plusQuarterlyPrice = 49900;
  static const int plusYearlyPrice = 149900;
  static const int proMonthlyPrice = 49900;
  static const int proQuarterlyPrice = 119900;
  static const int proYearlyPrice = 399900;
  
  // Timeouts
  static const Duration otpTimeout = Duration(seconds: 30);
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Animation
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
}

/// User subscription tiers
enum SubscriptionTier {
  free,
  sparkPlus,
  sparkPro,
}

/// Gender options
enum Gender {
  male('Male', 'male'),
  female('Female', 'female'),
  nonBinary('Non-binary', 'non_binary');

  const Gender(this.label, this.value);
  final String label;
  final String value;
}

/// Gender preference options
enum GenderPreference {
  male('Men', 'male'),
  female('Women', 'female'),
  everyone('Everyone', 'everyone');

  const GenderPreference(this.label, this.value);
  final String label;
  final String value;
}

/// Relationship intent
enum RelationshipIntent {
  casual('Casual Dating', 'casual'),
  serious('Serious Relationship', 'serious'),
  friendship('Friendship', 'friendship'),
  unsure('Not Sure Yet', 'unsure');

  const RelationshipIntent(this.label, this.value);
  final String label;
  final String value;
}

/// Lifestyle options
enum DrinkingHabit {
  never('Never', 'never'),
  socially('Socially', 'socially'),
  regularly('Regularly', 'regularly');

  const DrinkingHabit(this.label, this.value);
  final String label;
  final String value;
}

enum SmokingHabit {
  never('Never', 'never'),
  socially('Socially', 'socially'),
  regularly('Regularly', 'regularly');

  const SmokingHabit(this.label, this.value);
  final String label;
  final String value;
}

enum DietPreference {
  vegetarian('Vegetarian', 'vegetarian'),
  nonVegetarian('Non-Vegetarian', 'non_vegetarian'),
  vegan('Vegan', 'vegan'),
  eggetarian('Eggetarian', 'eggetarian');

  const DietPreference(this.label, this.value);
  final String label;
  final String value;
}

enum ExerciseFrequency {
  never('Never', 'never'),
  sometimes('Sometimes', 'sometimes'),
  regularly('Regularly', 'regularly'),
  daily('Daily', 'daily');

  const ExerciseFrequency(this.label, this.value);
  final String label;
  final String value;
}

/// Match & Room status
enum MatchStatus {
  pending,
  revealed,
  expired,
  connected,
  declined,
}

enum RoomStatus {
  active,
  extended,
  connected,
  expired,
  closed,
}

enum RoomDecision {
  pending,
  connect,
  extend,
  decline,
}

/// Report categories
enum ReportCategory {
  fakeProfile('Fake Profile / Catfishing', 'fake_profile'),
  inappropriateContent('Inappropriate Content', 'inappropriate_content'),
  harassment('Harassment / Bullying', 'harassment'),
  spam('Spam / Scam', 'spam'),
  underage('Underage User', 'underage'),
  other('Other', 'other');

  const ReportCategory(this.label, this.value);
  final String label;
  final String value;
}
