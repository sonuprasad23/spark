import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/matches/presentation/widgets/match_card.dart';

/// Match state
enum MatchStatus {
  notViewed,
  viewed,
  connected,
  passed,
  expired,
}

/// Match with additional metadata
class Match {
  final MatchProfile profile;
  final MatchStatus status;
  final DateTime? viewedAt;
  final DateTime? decidedAt;
  final DateTime expiresAt;
  final int weekNumber;

  const Match({
    required this.profile,
    this.status = MatchStatus.notViewed,
    this.viewedAt,
    this.decidedAt,
    required this.expiresAt,
    required this.weekNumber,
  });

  Match copyWith({
    MatchProfile? profile,
    MatchStatus? status,
    DateTime? viewedAt,
    DateTime? decidedAt,
    DateTime? expiresAt,
    int? weekNumber,
  }) {
    return Match(
      profile: profile ?? this.profile,
      status: status ?? this.status,
      viewedAt: viewedAt ?? this.viewedAt,
      decidedAt: decidedAt ?? this.decidedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      weekNumber: weekNumber ?? this.weekNumber,
    );
  }
}

/// Matches state
class MatchesState {
  final List<Match> matches;
  final bool isLoading;
  final String? error;
  final DateTime? nextRefreshAt;
  final int currentWeek;

  const MatchesState({
    this.matches = const [],
    this.isLoading = false,
    this.error,
    this.nextRefreshAt,
    this.currentWeek = 1,
  });

  MatchesState copyWith({
    List<Match>? matches,
    bool? isLoading,
    String? error,
    DateTime? nextRefreshAt,
    int? currentWeek,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      nextRefreshAt: nextRefreshAt ?? this.nextRefreshAt,
      currentWeek: currentWeek ?? this.currentWeek,
    );
  }

  List<Match> get pendingMatches =>
      matches.where((m) => m.status == MatchStatus.notViewed).toList();

  List<Match> get viewedMatches =>
      matches.where((m) => m.status == MatchStatus.viewed).toList();

  List<Match> get connectedMatches =>
      matches.where((m) => m.status == MatchStatus.connected).toList();

  int get remainingCount => pendingMatches.length + viewedMatches.length;
}

/// Matches notifier
class MatchesNotifier extends StateNotifier<MatchesState> {
  MatchesNotifier() : super(const MatchesState());

  /// Load weekly matches
  Future<void> loadMatches() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Fetch from Firestore
      await Future.delayed(const Duration(seconds: 1));

      // Generate sample matches
      final now = DateTime.now();
      final nextSunday = now.add(Duration(days: 7 - now.weekday));
      
      final sampleMatches = MatchProfile.sampleMatches.map((profile) {
        return Match(
          profile: profile,
          status: MatchStatus.notViewed,
          expiresAt: nextSunday,
          weekNumber: _getCurrentWeek(),
        );
      }).toList();

      state = state.copyWith(
        matches: sampleMatches,
        isLoading: false,
        nextRefreshAt: nextSunday,
        currentWeek: _getCurrentWeek(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// View/reveal a match
  Future<void> viewMatch(String matchId) async {
    final index = state.matches.indexWhere((m) => m.profile.id == matchId);
    if (index == -1) return;

    final updatedMatches = List<Match>.from(state.matches);
    updatedMatches[index] = updatedMatches[index].copyWith(
      status: MatchStatus.viewed,
      viewedAt: DateTime.now(),
    );

    state = state.copyWith(matches: updatedMatches);

    // TODO: Sync to Firestore
  }

  /// Connect with a match
  Future<bool> connectWithMatch(String matchId) async {
    try {
      final index = state.matches.indexWhere((m) => m.profile.id == matchId);
      if (index == -1) return false;

      // TODO: Send connection request to backend
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedMatches = List<Match>.from(state.matches);
      updatedMatches[index] = updatedMatches[index].copyWith(
        status: MatchStatus.connected,
        decidedAt: DateTime.now(),
      );

      state = state.copyWith(matches: updatedMatches);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Pass on a match
  Future<bool> passOnMatch(String matchId) async {
    try {
      final index = state.matches.indexWhere((m) => m.profile.id == matchId);
      if (index == -1) return false;

      // TODO: Send pass to backend
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedMatches = List<Match>.from(state.matches);
      updatedMatches[index] = updatedMatches[index].copyWith(
        status: MatchStatus.passed,
        decidedAt: DateTime.now(),
      );

      state = state.copyWith(matches: updatedMatches);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  int _getCurrentWeek() {
    final now = DateTime.now();
    return (now.difference(DateTime(now.year, 1, 1)).inDays / 7).ceil();
  }
}

/// Matches provider
final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  final notifier = MatchesNotifier();
  notifier.loadMatches();
  return notifier;
});

/// Remaining matches count
final remainingMatchesProvider = Provider<int>((ref) {
  return ref.watch(matchesProvider).remainingCount;
});

/// Next refresh time provider
final nextMatchRefreshProvider = Provider<DateTime?>((ref) {
  return ref.watch(matchesProvider).nextRefreshAt;
});
