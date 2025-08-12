import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:wordle/models/userModel.dart';
import 'package:wordle/services/userService.dart' show UserService;
import 'package:wordle/services/gameService.dart' show GameService;
import 'package:wordle/utils/notifyMsg.dart' show notifyMsg;
import 'package:wordle/utils/crypto.dart' show generateGameId;
import 'package:wordle/widgets/menuPage.dart' show MenuPage;
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
    //  _isLoading = true;
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
          answer: gameData['answer'],
          guesses: guesses,
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
      // _isLoading = false;
      notifyListeners();
    }
  }

  // Future<bool> submitGuess(String guess, BuildContext context) async {
  //   if (currentGame == null || _gameId == null) {
  //     await notifyMsg(
  //       'No active game found, backing to menu page...',
  //       context,
  //       Colors.redAccent,
  //     );
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const MenuPage()),
  //     );
  //     return false;
  //   }

  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     final response = await GameService()
  //         .submitGuess(name, _gameId!, guess)
  //         .timeout(const Duration(seconds: 10));

  //     if (response.code == "200" || response.code == "201") {
  //       final gameData = response.data!;
  //       final isGameOver = gameData['isGameOver'] == true;
  //       final isWon = gameData['isWon'] == true;

  //       // Convert the dynamic guesses to List<List<Guess>>
  //       final List<List<Guess>> guesses =
  //           (gameData['guesses'] as List)
  //               .map(
  //                 (row) =>
  //                     (row as List)
  //                         .map((g) => Guess.fromJson(g as Map<String, dynamic>))
  //                         .toList(),
  //               )
  //               .toList();
  //       // Update current game
  //       final updatedGame = currentGame!.copyWith(
  //         currentRound: gameData['currentRound'],

  //         guesses: guesses,
  //         isGameOver: isGameOver,
  //         lastUpdated: DateTime.now(),
  //       );

  //       // Update user model
  //       _user = _user!.copyWith(
  //         meta: _user!.meta.copyWith(lastUpdated: DateTime.now()),
  //         gameState: _user!.gameState!.copyWith(currentGame: updatedGame),
  //       );

  //       // Handle game completion
  //       if (isGameOver) {
  //         print('game is over, working the logic');
  //         // await _completeGame(
  //         //   isWon: isWon,
  //         //   timeUsed: (gameData['timeUsed'] as num?)?.toDouble() ?? 0.0,
  //         //   context: context,
  //         // );
  //       }

  //       await notifyMsg(
  //         isWon ? 'You won!' : 'Guess submitted',
  //         context,
  //         isWon ? Colors.greenAccent : Colors.blue,
  //       );
  //       return true;
  //     } else {
  //       await notifyMsg(response.message, context, Colors.redAccent);
  //       return false;
  //     }
  //   } on TimeoutException {
  //     await notifyMsg(
  //       'Request timed out',
  //       context,
  //       Theme.of(context).colorScheme.error,
  //     );
  //     return false;
  //   } catch (e) {
  //     await notifyMsg(
  //       'Error submitting guess: ${e.toString()}',
  //       context,
  //       Theme.of(context).colorScheme.error,
  //     );
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> submitGuess(String guess, BuildContext context) async {
    if (currentGame == null || _gameId == null) {
      await notifyMsg(
        'No active game found, backing to menu page...',
        context,
        Colors.redAccent,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
      return false;
    }

    // Check if game is already over
    if (currentGame!.isGameOver) {
      await _showGameOverDialog(context);
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

        // Update current game
        final updatedGame = currentGame!.copyWith(
          currentRound: gameData['currentRound'],
          guesses: guesses,
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
          await _showGameOverDialog(context, isWon: isWon);
        } else {
          await notifyMsg('Guess submitted', context, Colors.blue);
        }
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

  Future<void> _showGameOverDialog(
    BuildContext context, {
    bool isWon = false,
  }) async {
    final answer = currentGame?.answer ?? ''; // Get from backend
    final currentRound = currentGame?.currentRound ?? 0; // Handle null case

    // play
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                if (isWon)
                  Positioned.fill(
                    child: ConfettiWidget(
                      confettiController: ConfettiController(
                        duration: const Duration(seconds: 3),
                      ),
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child:
                            isWon
                                ? const Icon(
                                  Icons.celebration,
                                  size: 80,
                                  color: Colors.amber,
                                  key: ValueKey('win'),
                                )
                                : const Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  size: 80,
                                  color: Colors.grey,
                                  key: ValueKey('lose'),
                                ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isWon ? Colors.green : Colors.red,
                        ),
                        child: Text(isWon ? 'CONGRATULATIONS!' : 'GAME OVER'),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isWon
                            ? 'You guessed the word correctly! 🎉'
                            : 'The word was: ${answer.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 25),
                      if (isWon) ...[
                        Text(
                          'You won in $currentRound attempts!', // Use local variable
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[100],
                              foregroundColor: Colors.blueGrey[800],
                            ),
                            onPressed: () => _shareResult(context),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('New Game'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              newGame(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void _shareResult(BuildContext context) {
    final shareText =
        currentGame?.isGameOver == true
            ? "I just played Wordle and ${currentGame!.isGameOver ? 'won' : 'lost'} in ${currentGame!.currentRound} attempts!"
            : "Check out this Wordle game!";

    Share.share(shareText);
  }
}
