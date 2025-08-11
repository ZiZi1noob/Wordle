import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GamePage extends StatefulWidget {
  final bool isNewGame;

  const GamePage({super.key, required this.isNewGame});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<String> _guesses = [];
  final TextEditingController _guessController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isNewGame) {
      // Initialize new game
    } else {
      // Load previous game
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WORDLE'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Game Board
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 30, // 6 rows x 5 letters
                itemBuilder: (context, index) {
                  final row = index ~/ 5;
                  final col = index % 5;
                  Color? color;

                  if (row < _guesses.length) {
                    // TODO: Add real evaluation logic
                    color = Colors.grey.withOpacity(0.2);
                  }

                  return AnimatedContainer(
                    duration: 300.ms,
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        row < _guesses.length && col < _guesses[row].length
                            ? _guesses[row][col]
                            : '',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Area
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _guessController,
                      maxLength: 5,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter 5-letter word',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        counterText: '',
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _guessController.text.length == 5
                        ? _submitGuess
                        : null,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),

            // Virtual Keyboard
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: 'QWERTYUIOPASDFGHJKLZXCVBNM'.split('').map((letter) {
                return SizedBox(
                  width: 30,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      if (_guessController.text.length < 5) {
                        _guessController.text += letter;
                        setState(() {});
                      }
                    },
                    child: Text(letter),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _submitGuess() {
    setState(() {
      _guesses.add(_guessController.text.toUpperCase());
      _guessController.clear();
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('• Guess the 5-letter word in 6 tries'),
            Text('• Green: Correct letter in correct position'),
            Text('• Yellow: Correct letter in wrong position'),
            Text('• Gray: Letter not in word'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
