import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// Pre-defined styles for better performance
final _titleTextStyle = GoogleFonts.notoSans(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.blue,
);

final _bodyTextStyle = GoogleFonts.notoSans(fontSize: 16);
final _sectionTitleStyle = GoogleFonts.notoSans(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const _HelpDialogContent(),
  );
}

class _HelpDialogContent extends StatelessWidget {
  const _HelpDialogContent();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildGameDescription(),
                const SizedBox(height: 25),
                _buildExamplesSection(),
                const SizedBox(height: 25),
                _buildTipsSection(),
                const SizedBox(height: 20),
                _buildCloseButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Lottie.asset(
          'assets/lottie/help.json',
          width: 60,
          height: 60,
          repeat: true,
          frameRate: FrameRate(30),
        ),
        const SizedBox(width: 10),
        Text('HOW TO PLAY', style: _titleTextStyle),
      ],
    );
  }

  Widget _buildGameDescription() {
    return Text(
      'Guess the hidden 5-letter word in 6 tries. '
      'Each guess must be a valid 5-letter word.',
      style: _bodyTextStyle,
    );
  }

  Widget _buildExamplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EXAMPLES', style: _sectionTitleStyle),
        const SizedBox(height: 15),
        _buildExampleTile(
          word: 'W',
          status: 'correct',
          description: 'The letter W is in the word and in the correct spot.',
        ),
        _buildExampleTile(
          word: 'E',
          status: 'present',
          description: 'The letter E is in the word but in the wrong spot.',
        ),
        _buildExampleTile(
          word: 'A',
          status: 'absent',
          description: 'The letter A is not in the word in any spot.',
        ),
      ],
    );
  }

  Widget _buildExampleTile({
    required String word,
    required String status,
    required String description,
  }) {
    final color = _getStatusColor(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                word,
                style: _bodyTextStyle.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(description, style: _bodyTextStyle)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'correct':
        return Colors.green;
      case 'present':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TIPS & TRICKS', style: _sectionTitleStyle),
        const SizedBox(height: 15),
        _buildTipItem('🔠', 'Start with words that have many vowels'),
        _buildTipItem('🔄', 'Try to eliminate as many letters as possible'),
        _buildTipItem('⏱️', 'Take your time - there\'s no timer!'),
      ],
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: GoogleFonts.notoColorEmoji(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: _bodyTextStyle)),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text(
          'LET\'S PLAY!',
          style: _bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
