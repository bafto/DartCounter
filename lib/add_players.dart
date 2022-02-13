import 'package:dart_counter/in_game.dart';
import 'package:dart_counter/settings.dart';
import 'package:dart_counter/globals.dart' as globals;
import 'package:dart_counter/statistic_viewer.dart';
import 'package:flutter/material.dart';

class AddPlayers extends StatefulWidget {
  const AddPlayers({Key? key}) : super(key: key);

  @override
  _AddPlayersState createState() => _AddPlayersState();
}

class _AddPlayersState extends State<AddPlayers> {
  List<TextEditingController> textControllers = List<TextEditingController>.generate((globals.statistics?.lastPlayers.length ?? 0) > 0 ? globals.statistics?.lastPlayers.length ?? 1 : 1,
    (index) {
      return TextEditingController(text: (globals.statistics?.lastPlayers.length ?? 0) > 0 ? globals.statistics?.lastPlayers[index] : "");
    }
  );

  List<Widget> _buildPlayers() {
    List<Widget> players = [];
    for (int i = 0; i < textControllers.length && i < 4; i++) {
      players.add(Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(),
                hintText: "Spieler ${i+1}",
                errorText: textControllers.where((value) => value.text == textControllers[i].text).toList().length > 1 ?
                "Diesen Spieler gibt es schon" : null,
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButton<String>(
                    icon: const Icon(Icons.arrow_downward),
                    focusColor: Colors.transparent,
                    underline: Container(),
                    onChanged: (value) {
                      setState(() {
                        textControllers[i].text = value!;
                      });
                    },
                    items: globals.statistics?.players.keys.map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    )).toList(),
                  )
                )
              ),
              onChanged: (value) => setState(() {}),
              controller: textControllers[i],
            ),
          ),
        ),
      );
    }
    return players;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spieler Auswahl"),
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
      body: Wrap(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              "Füge bis zu 4 Spieler hinzu",
              style: TextStyle(fontSize: 34, decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: _buildPlayers() +
                  [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() {
                            if (textControllers.length < 4) textControllers.add(TextEditingController());
                          }),
                          child: const Text("Spieler Hinzufügen"),
                        ),
                        const SizedBox(width: 40),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            if (textControllers.length > 1) textControllers.removeLast();
                          }),
                          child: const Text("Spieler Entfernen"),
                        ),
                      ],
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          final textControllerTexts = textControllers.map((val) => val.text).toSet();
                          if(textControllerTexts.length == textControllers.toSet().length) {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                InGame(
                                  playerNames: List<String>.generate(
                                    textControllers.length,
                                        (index) {
                                      return textControllers[index].text
                                          .isEmpty ? "Spieler ${index +
                                          1}" : textControllers[index]
                                          .text;
                                    },
                                    growable: false
                                  )
                                )
                              )
                            );
                          }
                        },
                        child: const Text("Start"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}
