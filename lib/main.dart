import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/repositories/player_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final playerRepository = LocalPlayerRepository();
  runApp(BubbleQuestApp(playerRepository: playerRepository));
}
