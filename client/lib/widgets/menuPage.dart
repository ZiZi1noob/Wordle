import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wordle/provider/userProv.dart' show UserProvider;

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<UserProvider, String>(
      selector: (context, userProv) => userProv.name ?? '',
      builder: (context, name, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Welcome, $name'), centerTitle: true),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // New Game Button
                FilledButton(
                      onPressed: () async {},
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 28),
                          SizedBox(height: 4),
                          Text('New Game', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scale(begin: Offset(0.8, 0.8)),

                const SizedBox(height: 24),

                // Resume Button
                OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(200, 60),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 28),
                          SizedBox(height: 4),
                          Text('Resume Game', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .scale(begin: Offset(0.8, 0.8)),

                const SizedBox(height: 40),

                // Stats Chip
                ActionChip(
                  avatar: const Icon(Icons.leaderboard, size: 18),
                  label: const Text('View Stats'),
                  onPressed: () {},
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}
