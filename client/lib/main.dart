import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wordle/provider/userProv.dart' show UserProvider;
import 'package:wordle/widgets/entryPage.dart' show EntryPage;

void main() async {
  await dotenv.load(fileName: '../.env');
  print('✅ Loaded .env file successfully');
  print("=== Environment Configuration ===");
  print('HTTP_PORTOCOL: ${dotenv.get('HTTP_PORTOCOL')}');
  print('HOST: ${dotenv.get('HOST')}');
  print('PORT: ${dotenv.get('PORT')}');
  print("=====================================");

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const WordleApp(),
    ),
  );
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const EntryPage(),
    );
  }
}
