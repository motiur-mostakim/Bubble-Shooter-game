import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/repositories/player_repository.dart';
import '../features/splash/splash_screen.dart';

class BubbleQuestApp extends StatelessWidget {
  final PlayerRepository playerRepository;

  const BubbleQuestApp({super.key, required this.playerRepository});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Bubble Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(playerRepository: playerRepository),
    );
  }
}
