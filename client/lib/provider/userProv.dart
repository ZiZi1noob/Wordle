import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:wordle/models/userModel.dart';
import 'package:lottie/lottie.dart';
import 'package:wordle/services/userService.dart' show UserService;
import 'package:wordle/services/gameService.dart' show GameService;
import 'package:wordle/utils/notifyMsg.dart' show notifyMsg;
import 'package:wordle/utils/dialogAnimations.dart' show showHelpDialog;
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
        showHelpDialog(context);
        //  await notifyMsg('New game started!', context, Colors.greenAccent);
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
    final answer = currentGame?.answer ?? '';
    final currentRound = currentGame?.currentRound ?? 0;
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    if (isWon) confettiController.play();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Confetti background for winners
                if (isWon)
                  Positioned.fill(
                    child: ConfettiWidget(
                      confettiController: confettiController,
                      blastDirection: 3.14 / 2,
                      emissionFrequency: 0.05,
                      numberOfParticles: 20,
                      maxBlastForce: 20,
                      minBlastForce: 10,
                      gravity: 0.2,
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
                      // Animated result icon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child:
                            isWon
                                ? Lottie.asset(
                                  'lottie/won.json',
                                  width: 150,
                                  height: 150,
                                  repeat: false,
                                  key: const ValueKey('win'),
                                )
                                : Lottie.asset(
                                  'lottie/lose.json',
                                  width: 150,
                                  height: 150,
                                  repeat: false,
                                  key: const ValueKey('lose'),
                                ),
                      ),

                      ShaderMask(
                        shaderCallback:
                            (bounds) => LinearGradient(
                              colors:
                                  isWon
                                      ? [Colors.green, Colors.lightGreen]
                                      : [Colors.red, Colors.orange],
                            ).createShader(bounds),
                        child: Text(
                          isWon ? 'VICTORY!' : 'GAME OVER',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Important for ShaderMask
                          ),
                        ),
                      ).animate().scale(duration: 600.ms),

                      const SizedBox(height: 15),

                      // Result message
                      Text(
                        isWon
                            ? 'You crushed it in $currentRound tries!'
                            : 'The word was:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (!isWon) ...[
                        const SizedBox(height: 10),
                        Text(
                          answer.toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                            letterSpacing: 3,
                          ),
                        ),
                      ],

                      const SizedBox(height: 25),

                      // Emoji results grid
                      if (currentGame != null) _buildEmojiResults(currentGame!),

                      const SizedBox(height: 25),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Share button
                          _buildActionButton(
                            icon: Icons.share,
                            label: 'Share',
                            color: Colors.blue,
                            onPressed: () => _shareResult(context),
                          ),

                          // New game button
                          _buildActionButton(
                            icon: Icons.refresh,
                            label: 'New Game',
                            color: Colors.green,
                            onPressed: () {
                              Navigator.pop(context);
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
    );

    confettiController.dispose();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildEmojiResults(CurrentGame game) {
    return Column(
      children: [
        const Text(
          'Your Results:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children:
                game.guesses.map((row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        row.map((guess) {
                          return Text(
                            guess.emoji,
                            style: const TextStyle(fontSize: 24),
                          );
                        }).toList(),
                  );
                }).toList(),
          ),
        ),
      ],
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
