import 'package:wordle/models/gameModel.dart'
    show GameState, GameRecord, GameSettings;

class UserModel {
  final UserMeta meta;
  final UserInfo user;
  final UserStats? stats;
  final GameState? gameState;

  UserModel({
    required this.meta,
    required this.user,
    this.stats,
    this.gameState,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      meta: UserMeta.fromJson(json['meta'] ?? {}),
      user: UserInfo.fromJson(json['user'] ?? {}),
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
      gameState:
          json['gameState'] != null
              ? GameState.fromJson(json['gameState'])
              : null,
    );
  }

  UserModel copyWith({
    UserMeta? meta,
    UserInfo? user,
    UserStats? stats,
    GameState? gameState,
  }) {
    return UserModel(
      meta: meta ?? this.meta,
      user: user ?? this.user,
      stats: stats ?? this.stats,
      gameState: gameState ?? this.gameState,
    );
  }

  @override
  String toString() {
    return 'UserModel{meta: $meta, user: $user, stats: $stats, gameState: $gameState}';
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'user': user.toJson(),
      'stats': stats?.toJson(),
      'gameState': gameState?.toJson(),
    };
  }
}

class UserMeta {
  final String version;
  final DateTime createdAt;
  final DateTime lastUpdated;

  UserMeta({
    required this.version,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta(
      version: json['version'] as String? ?? '1.0',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')!,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? '')!,
    );
  }
  UserMeta copyWith({
    String? version,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return UserMeta(
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'UserMeta{version: $version, createdAt: $createdAt, lastUpdated: $lastUpdated}';
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class UserInfo {
  final String id;
  final String username;
  final Map<String, dynamic> preferences;

  UserInfo({
    required this.id,
    required this.username,
    required this.preferences,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      username: json['username'],
      preferences: json['preferences'] ?? {},
    );
  }

  UserInfo copyWith({
    String? id,
    String? username,
    Map<String, dynamic>? preferences,
  }) {
    return UserInfo(
      id: id ?? this.id,
      username: username ?? this.username,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'preferences': preferences};
  }

  @override
  String toString() {
    return 'UserInfo{'
        'id: $id, '
        'username: $username, '
        'preferences: $preferences'
        '}';
  }
}

class UserStats {
  final int gamesPlayed;
  final int gamesWon;
  final double winPercentage;
  final int currentStreak;
  final int maxStreak;
  final List<int> guessDistribution;
  final double averageTime;

  UserStats({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.winPercentage,
    required this.currentStreak,
    required this.maxStreak,
    required this.guessDistribution,
    required this.averageTime,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      winPercentage: (json['winPercentage'] as num?)?.toDouble() ?? 0.0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      guessDistribution:
          (json['guessDistribution'] as List?)?.cast<int>() ??
          [0, 0, 0, 0, 0, 0],
      averageTime: (json['averageTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'UserStats{'
        'gamesPlayed: $gamesPlayed, '
        'gamesWon: $gamesWon, '
        'winPercentage: ${winPercentage.toStringAsFixed(2)}%, '
        'currentStreak: $currentStreak, '
        'maxStreak: $maxStreak, '
        'guessDistribution: $guessDistribution, '
        'averageTime: ${averageTime.toStringAsFixed(2)}s'
        '}';
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'winPercentage': winPercentage,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'guessDistribution': guessDistribution,
      'averageTime': averageTime,
    };
  }

  UserStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    double? winPercentage,
    int? currentStreak,
    int? maxStreak,
    List<int>? guessDistribution,
    double? averageTime,
  }) {
    return UserStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      winPercentage: winPercentage ?? this.winPercentage,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      guessDistribution: guessDistribution ?? this.guessDistribution,
      averageTime: averageTime ?? this.averageTime,
    );
  }
}
