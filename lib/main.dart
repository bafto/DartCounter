import 'package:dart_counter/add_players.dart';
import 'package:dart_counter/settings.dart';
import 'package:dart_counter/statistic_viewer.dart';
import 'package:flutter/material.dart';
import 'package:dart_counter/globals.dart' as globals;

void main() async {
  globals.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Dart Counter',
      home: HomeScreen(winner: null),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key, required this.winner}) : super(key: key);
  final String? winner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const StatisticsViewer()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Settings()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(flex: 9, child: Text("${winner ?? ""}${winner == null ? "" : "\nhat gewonnen!"}", style: const TextStyle(fontSize: 35), textAlign: TextAlign.center,)),
            const Spacer(flex: 1),
            Flexible(
              flex: 9,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddPlayers()));
                },
                child: const Text("Neues Match"),
                style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 34))
              ),
            ),
          ]
        ),
      ),
    );
  }
}

