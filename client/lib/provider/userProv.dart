import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wordle/models/userModel.dart';
import 'package:wordle/services/userService.dart' show UserService;
import 'package:wordle/services/gameService.dart' show GameService;
import 'package:wordle/utils/notifyMsg.dart' show notifyMsg;
import 'package:wordle/utils/crypto.dart' show generateGameId;
import 'package:wordle/models/gameModel.dart'
    show CurrentGame, HistoryGame, GameSettings, GameState, Guess;

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _gameId;

  // Getters
  String get name => _user?.user.username ?? '';
  String? get gameId => _gameId;
  bool get isLoading => _isLoading;
  UserStats? get stats => _user?.stats;
  UserModel? get userData => _user;
  CurrentGame? get currentGame => _user?.gameState?.currentGame;
  List<HistoryGame> get gameHistory => _user?.gameState?.history ?? [];

  Future<bool> getUserInfo(String name, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await UserService()
          .getUserInfo(name)
          .timeout(const Duration(seconds: 10));

      if (response.code == "200" || response.code == "201") {
        _user = response.data!;
        _gameId = _user?.gameState?.currentGame?.gameId;
        await notifyMsg(response.message, context, Colors.greenAccent);
        return true;
      } else {
        await notifyMsg(response.message, context, Colors.redAccent);
        return false;
      }
    } on TimeoutException {
      await notifyMsg(
        'Request timed out',
        context,
        Theme.of(context).colorScheme.error,
      );
      return false;
    } catch (e) {
      await notifyMsg(
        e.toString().contains('Network error')
            ? 'Network error. Please check your connection.'
            : 'Error fetching user info: ${e.toString()}',
        context,
        Theme.of(context).colorScheme.error,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> newGame(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final newGameId = generateGameId();
    try {
      final response = await GameService()
          .createNewGame(name, newGameId)
          .timeout(const Duration(seconds: 10));

      if (response.code == "200" || response.code == "201") {
        final gameData = response.data!;

        // Convert the dynamic guesses to List<List<Guess>>
        final List<List<Guess>> guesses =
            (gameData['guesses'] as List)
                .map(
                  (row) =>
                      (row as List)
                          .map((g) => Guess.fromJson(g as Map<String, dynamic>))
                          .toList(),
                )
                .toList();
        final newGameRecord = CurrentGame(
          gameId: newGameId,
          currentRound: gameData['currentRound'],
          maxRounds: gameData['maxRounds'],
          guesses: gameData['guesses'],
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
          settings: GameSettings(
            wordLength: gameData['settings']['wordLength'],
            maxRounds: gameData['settings']['maxRounds'],
            caseSensitive:
                gameData['settings']['caseSensitive'] == true ||
                gameData['settings']['caseSensitive'] == 'true',
          ),
          isGameOver: false,
        );

        _user = _user?.copyWith(
          meta: _user!.meta.copyWith(lastUpdated: DateTime.now()),
          gameState: GameState(
            currentGame: newGameRecord,
            history: _user?.gameState?.history ?? [],
          ),
        );
        _gameId = newGameId;

        await notifyMsg('New game started!', context, Colors.greenAccent);
        return true;
      } else {
        await notifyMsg(response.message, context, Colors.redAccent);
        return false;
      }
    } on TimeoutException {
      await notifyMsg(
        'Request timed out',
        context,
        Theme.of(context).colorScheme.error,
      );
      return false;
    } catch (e) {
      await notifyMsg(
        'Error starting new game: ${e.toString()}',
        context,
        Theme.of(context).colorScheme.error,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitGuess(String guess, BuildContext context) async {
    if (currentGame == null || _gameId == null) {
      await notifyMsg('No active game found', context, Colors.redAccent);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await GameService()
          .submitGuess(name, _gameId!, guess)
          .timeout(const Duration(seconds: 10));

      if (response.code == "200" || response.code == "201") {
        final gameData = response.data!;
        final isGameOver = gameData['isGameOver'] == true;
        final isWon = gameData['isWon'] == true;

        // Update current game
        final updatedGame = currentGame!.copyWith(
          currentRound: gameData['currentRound'],
          guesses: gameData['guesses'],
          isGameOver: isGameOver,
          lastUpdated: DateTime.now(),
        );

        // Update user model
        _user = _user!.copyWith(
          meta: _user!.meta.copyWith(lastUpdated: DateTime.now()),
          gameState: _user!.gameState!.copyWith(currentGame: updatedGame),
        );

        // Handle game completion
        if (isGameOver) {
          print('game is over, working the logic');
          // await _completeGame(
          //   isWon: isWon,
          //   timeUsed: (gameData['timeUsed'] as num?)?.toDouble() ?? 0.0,
          //   context: context,
          // );
        }

        await notifyMsg(
          isWon ? 'You won!' : 'Guess submitted',
          context,
          isWon ? Colors.greenAccent : Colors.blue,
        );
        return true;
      } else {
        await notifyMsg(response.message, context, Colors.redAccent);
        return false;
      }
    } on TimeoutException {
      await notifyMsg(
        'Request timed out',
        context,
        Theme.of(context).colorScheme.error,
      );
      return false;
    } catch (e) {
      await notifyMsg(
        'Error submitting guess: ${e.toString()}',
        context,
        Theme.of(context).colorScheme.error,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> _completeGame({
  //   required bool isWon,
  //   required double timeUsed,
  //   required BuildContext context,
  // }) async {
  //   if (currentGame == null) return;

  //   final completedGame = HistoryGame(
  //     gameId: currentGame!.gameId,
  //     answer: '', // You'll need to get this from your backend
  //     guesses: currentGame!.guesses,
  //     isWon: isWon,
  //     createdAt: currentGame!.createdAt,
  //     completedAt: DateTime.now(),
  //     timeUsed: timeUsed,
  //     settings: currentGame!.settings,
  //   );

  //   // Update stats
  //   // final newStats = _user!.stats?.copyWith(
  //   //   gamesPlayed: (_user!.stats?.gamesPlayed ?? 0) + 1,
  //   //   gamesWon:
  //   //       isWon
  //   //           ? (_user!.stats?.gamesWon ?? 0) + 1
  //   //           : _user!.stats?.gamesWon ?? 0,
  //   //   // Update other stats as needed
  //   // );

  //   // _user = _user!.copyWith(
  //   //  // stats: newStats,
  //   //   gameState: GameState(
  //   //     currentGame: null,
  //   //     history: [..._user!.gameState?.history ?? [], completedGame],
  //   //   ),
  //   // );
  //   _gameId = null;
  // }
}
