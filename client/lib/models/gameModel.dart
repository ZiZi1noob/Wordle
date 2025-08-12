import 'package:flutter/material.dart';

class CurrentGame {
  final String gameId;
  final int currentRound;
  final int maxRounds;
  final String answer;
  // final List<dynamic> guesses; // Could be List<Guess> if you have a Guess model
  final List<List<Guess>> guesses;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final GameSettings settings;
  final bool isGameOver;

  CurrentGame({
    required this.gameId,
    required this.currentRound,
    required this.answer,
    required this.maxRounds,
    required this.guesses,
    required this.createdAt,
    required this.lastUpdated,
    required this.settings,
    required this.isGameOver,
  });

  factory CurrentGame.fromJson(Map<String, dynamic> json) {
    return CurrentGame(
      gameId: json['gameId'] as String,
      currentRound: json['currentRound'] as int,
      maxRounds: json['maxRounds'] as int,
      answer: json['answer'] as String,
      //  guesses: (json['guesses'] as List?) ?? [],
      //  guesses: _parseGuesses(json['guesses']),
      guesses: json['guesses'] == null ? [] : _parseGuesses(json['guesses']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      settings: GameSettings.fromJson(json['settings'] as Map<String, dynamic>),
      isGameOver: json['isGameOver'] as bool? ?? false,
    );
  }

  static List<List<Guess>> _parseGuesses(dynamic guessesJson) {
    // Handle null or non-List input
    if (guessesJson == null) return [];

    // If it's an empty list, return empty list
    if (guessesJson is List && guessesJson.isEmpty) return [];

    // If it's not a List at this point, return empty list
    if (guessesJson is! List) return [];

    // Initialize empty 2D list
    final List<List<Guess>> result = [];

    for (var row in guessesJson) {
      // If row is not a list, skip it
      if (row is! List) continue;

      final List<Guess> guessRow = [];
      for (var guess in row) {
        // Skip if not a map
        if (guess is! Map<String, dynamic>) continue;

        try {
          guessRow.add(Guess.fromJson(guess));
        } catch (e) {
          // Skip invalid guesses
          continue;
        }
      }
      result.add(guessRow);
    }

    return result;
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'currentRound': currentRound,
    'maxRounds': maxRounds,
    'guesses':
        guesses
            .map((guessRow) => guessRow.map((guess) => guess.toJson()).toList())
            .toList(),
    'createdAt': createdAt.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'settings': settings.toJson(),
    'isGameOver': isGameOver,
  };

  CurrentGame copyWith({
    String? gameId,
    int? currentRound,
    int? maxRounds,
    String? answer,
    List<List<Guess>>? guesses,
    DateTime? createdAt,
    DateTime? lastUpdated,
    GameSettings? settings,
    bool? isGameOver,
  }) {
    return CurrentGame(
      gameId: gameId ?? this.gameId,
      answer: answer ?? this.answer,
      currentRound: currentRound ?? this.currentRound,
      maxRounds: maxRounds ?? this.maxRounds,
      guesses: guesses ?? this.guesses,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      settings: settings ?? this.settings,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class HistoryGame {
  final String gameId;
  final String answer;
  final List<dynamic> guesses;
  final bool isWon;
  final DateTime createdAt;
  final DateTime completedAt;
  final double timeUsed;

  HistoryGame({
    required this.gameId,
    required this.answer,
    required this.guesses,
    required this.isWon,
    required this.createdAt,
    required this.completedAt,
    required this.timeUsed,
  });

  factory HistoryGame.fromJson(Map<String, dynamic> json) {
    return HistoryGame(
      gameId: json['gameId'] as String,
      answer: json['answer'] as String,
      guesses: (json['guesses'] as List?)?.cast<dynamic>() ?? [],
      isWon: json['isWon'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      timeUsed: (json['timeUsed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'answer': answer,
    'guesses': guesses,
    'isWon': isWon,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
    'timeUsed': timeUsed,
  };
}

class GameState {
  final CurrentGame? currentGame;
  final List<HistoryGame>? history; // Made nullable

  GameState({this.currentGame, this.history});

  factory GameState.fromJson(Map<String, dynamic>? json) {
    // Handle null json
    if (json == null) return GameState();

    // Safely parse currentGame
    final currentGameJson = json['currentGame'];
    final currentGame =
        currentGameJson != null &&
                currentGameJson is Map &&
                currentGameJson.isNotEmpty
            ? CurrentGame.fromJson(Map<String, dynamic>.from(currentGameJson))
            : null;
    print('currentGame: ${currentGame}');

    List<HistoryGame>? history;
    final historyJson = json['history'];
    print('historyJson: ${historyJson}');
    if (historyJson is List) {
      history =
          historyJson
              .whereType<Map>() // Only process Map items
              .map((e) => HistoryGame.fromJson(Map<String, dynamic>.from(e)))
              .toList();
    }
    print('history: ${history}');

    return GameState(
      currentGame: currentGame,
      history: history, // Can be null
    );
  }

  Map<String, dynamic> toJson() => {
    if (currentGame != null) 'currentGame': currentGame!.toJson(),
    if (history != null) 'history': history!.map((e) => e.toJson()).toList(),
  };

  GameState copyWith({CurrentGame? currentGame, List<HistoryGame>? history}) {
    return GameState(
      currentGame: currentGame ?? this.currentGame,
      history: history ?? this.history,
    );
  }
}

class GameSettings {
  final int wordLength;
  final int maxRounds;
  final bool caseSensitive;

  GameSettings({
    required this.wordLength,
    required this.maxRounds,
    required this.caseSensitive,
  });

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      wordLength: json['wordLength'] as int,
      maxRounds: json['maxRounds'] as int,
      caseSensitive:
          json['caseSensitive'] == 'true' || json['caseSensitive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordLength': wordLength,
      'maxRounds': maxRounds,
      'caseSensitive': caseSensitive,
    };
  }

  @override
  String toString() {
    return 'GameSettings{'
        'wordLength: $wordLength, '
        'maxRounds: $maxRounds, '
        'caseSensitive: $caseSensitive'
        '}';
  }
}

class Guess {
  final String letter;
  final String status; // 'correct', 'present', 'absent'
  final int position;

  Guess({required this.letter, required this.status, required this.position});

  factory Guess.fromJson(Map<String, dynamic> json) {
    return Guess(
      letter: json['letter'] as String,
      status: json['status'] as String,
      position: json['position'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'letter': letter,
    'status': status,
    'position': position,
  };

  // If you need to make Guess iterable (for the letter)
  String operator [](int index) {
    if (index == 0) return letter;
    throw RangeError.index(
      index,
      this,
      'index',
      'Guess only has letter at index 0',
    );
  }

  int get length => 1;

  @override
  String toString() {
    return 'Guess{'
        'letter: $letter, '
        'status: $status, '
        'position: $position'
        '}';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'correct':
        return Colors.green;
      case 'present':
        return Colors.amber;
      case 'absent':
      default:
        return Colors.grey;
    }
  }

  String get emoji {
    switch (status.toLowerCase()) {
      case 'correct':
        return '🟩';
      case 'present':
        return '🟨';
      case 'absent':
      default:
        return '⬜';
    }
  }
}
