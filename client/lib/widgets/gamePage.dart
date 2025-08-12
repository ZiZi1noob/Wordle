import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wordle/provider/userProv.dart' show UserProvider;
import 'package:flutter/services.dart';
import 'package:wordle/utils/notifyMsg.dart' show notifyMsg;
import 'package:wordle/utils/dialogAnimations.dart' show showHelpDialog;

class GamePage extends StatefulWidget {
  final bool isNewGame;

  const GamePage({super.key, required this.isNewGame});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final TextEditingController _guessController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    if (widget.isNewGame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserProvider>().newGame(context);
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 768;

    final keyboardKeySize = isDesktop ? 50.0 : 40.0;

    final currentGame = provider.currentGame;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WORDLE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showHelpDialog(context),
            tooltip: 'How to play',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _restartGame,
            tooltip: 'New game',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 800 : 500),
          child: Column(
            children: [
              // Game Board
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 30.0 : 16.0,
                  ),
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: isDesktop ? 12 : 8,
                        crossAxisSpacing: isDesktop ? 12 : 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: 30,
                      itemBuilder: (context, index) {
                        final row = index ~/ 5;
                        final col = index % 5;
                        Color? color;
                        String letter = '';

                        if (currentGame != null &&
                            row < currentGame.guesses.length &&
                            col < currentGame.guesses[row].length) {
                          final guess = currentGame.guesses[row][col];
                          letter = guess.letter;
                          color = guess.statusColor;
                        }
                        return AnimatedContainer(
                          duration: 300.ms,
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: color ?? Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (color != null)
                                BoxShadow(
                                  color: color!.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: isDesktop ? 32 : 28,
                                fontWeight: FontWeight.bold,
                                color:
                                    color != null ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Input Area
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 100.0 : 16.0,
                  vertical: isDesktop ? 30.0 : 16.0,
                ),
                child: TextField(
                  focusNode: _focusNode,
                  controller: _guessController,
                  maxLength: 5,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    letterSpacing: 2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your guess...',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _guessController.text.length == 5
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _guessController.text.length == 5
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(
                                  context,
                                ).colorScheme.error.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _guessController.text.length == 5
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send,
                        color:
                            _guessController.text.length == 5
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                      ),
                      onPressed:
                          _guessController.text.length == 5
                              ? () {
                                HapticFeedback.lightImpact();
                                _submitGuess();
                              }
                              : null,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                  onChanged: (value) => _handleTextChange(value),
                  onSubmitted: (_) {
                    HapticFeedback.lightImpact();
                    _submitGuess();
                  },
                ),
              ),

              // Virtual Keyboard
              Padding(
                padding: EdgeInsets.only(
                  bottom: isDesktop ? 40.0 : 20.0,
                  left: 16,
                  right: 16,
                ),
                child: Column(
                  children: [
                    // Top row (Q-P + Backspace)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isDesktop ? 10 : 6,
                      runSpacing: isDesktop ? 12 : 8,
                      children: [
                        ...'QWERTYUIOP'
                            .split('')
                            .map(
                              (letter) => _buildKey(
                                letter,
                                keyboardKeySize,
                                isDesktop,
                                provider,
                              ),
                            ),
                        _buildSpecialKey('⌫', keyboardKeySize * 1.5, isDesktop),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Middle row (A-L + Enter symbol)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isDesktop ? 10 : 6,
                      runSpacing: isDesktop ? 12 : 8,
                      children: [
                        ...'ASDFGHJKL'
                            .split('')
                            .map(
                              (letter) => _buildKey(
                                letter,
                                keyboardKeySize,
                                isDesktop,
                                provider,
                              ),
                            ),
                        _buildSpecialKey(
                          'ENTER',
                          keyboardKeySize * 2.3,
                          isDesktop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bottom row (Z-M)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isDesktop ? 10 : 6,
                      runSpacing: isDesktop ? 12 : 8,
                      children: [
                        ...'ZXCVBNM'
                            .split('')
                            .map(
                              (letter) => _buildKey(
                                letter,
                                keyboardKeySize,
                                isDesktop,
                                provider,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(
    String letter,
    double size,
    bool isDesktop,
    UserProvider provider,
  ) {
    Color? keyColor;
    final currentGame = provider.currentGame;

    if (currentGame != null) {
      for (final guessRow in currentGame.guesses) {
        for (final guess in guessRow) {
          if (guess.letter == letter) {
            if (guess.status == 'correct') {
              keyColor = guess.statusColor;
              break;
            } else if (guess.status == 'present' && keyColor != Colors.green) {
              keyColor = guess.statusColor;
            } else if (guess.status == 'absent' && keyColor == null) {
              keyColor = guess.statusColor;
            }
          }
        }
      }
    }
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: keyColor ?? Colors.grey.shade200,
          foregroundColor: keyColor != null ? Colors.white : Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _handleKeyPress(letter),
        child: Text(
          letter,
          style: TextStyle(
            fontSize: isDesktop ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, double width, bool isDesktop) {
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => _handleKeyPress(label),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleTextChange(String value) async {
    final newText = value.toUpperCase();

    // Check for numbers
    if (RegExp(r'[0-9]').hasMatch(newText)) {
      await notifyMsg(
        'Only letters are allowed!',
        context,
        Theme.of(context).colorScheme.error,
      );
      _guessController.text = _guessController.text.replaceAll(
        RegExp(r'[0-9]'),
        '',
      );
      _guessController.selection = TextSelection.collapsed(
        offset: _guessController.text.length,
      );
      return;
    }

    // Check for symbols/special characters
    if (RegExp(r'[^A-Za-z]').hasMatch(newText)) {
      notifyMsg(
        'No symbols or special characters allowed!',
        context,
        Theme.of(context).colorScheme.error,
      );
      _guessController.text = _guessController.text.replaceAll(
        RegExp(r'[^A-Za-z]'),
        '',
      );
      _guessController.selection = TextSelection.collapsed(
        offset: _guessController.text.length,
      );
      return;
    }

    // Length validation
    if (newText.length > 5) {
      notifyMsg(
        'Maximum 5 characters allowed!',
        context,
        Theme.of(context).colorScheme.error,
      );
      _guessController.text = newText.substring(0, 5);
    } else {
      _guessController.text = newText;
    }

    _guessController.selection = TextSelection.collapsed(
      offset: _guessController.text.length,
    );
    setState(() {});
  }

  void _handleKeyPress(String key) async {
    await HapticFeedback.lightImpact();

    if (key == 'ENTER') {
      if (_guessController.text.length == 5) {
        _submitGuess();
      } else {
        notifyMsg(
          'Please enter exactly 5 letters!',
          context,
          Theme.of(context).colorScheme.error,
        );
      }
    } else if (key == '⌫') {
      if (_guessController.text.isNotEmpty) {
        _guessController.text = _guessController.text.substring(
          0,
          _guessController.text.length - 1,
        );
      }
    } else if (_guessController.text.length < 5) {
      _guessController.text += key;
    }

    setState(() {});
  }

  void _submitGuess() async {
    if (_guessController.text.length != 5) return;

    final res = await context.read<UserProvider>().submitGuess(
      _guessController.text,
      context,
    );

    if (res) {
      setState(() {
        _guessController.clear();
        _focusNode.requestFocus();
      });
    }
  }

  void _restartGame() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Game?'),
            content: const Text('Are you sure you want to start a new game?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await context.read<UserProvider>().newGame(context);

                  _guessController.clear();
                  _focusNode.requestFocus();
                },
                child: const Text('New Game'),
              ),
            ],
          ),
    );
  }
}
