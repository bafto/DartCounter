import 'package:dart_counter/statistic_viewer.dart';
import 'package:flutter/material.dart';
import 'package:dart_counter/my_number_input.dart';
import 'package:dart_counter/globals.dart' as globals;
import 'package:flutter/services.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final legsToSetController = TextEditingController();
  final setsToWinController = TextEditingController();
  int legsToSet = globals.prefs?.getInt('legsToSet') ?? 3;
  int setsToWin = globals.prefs?.getInt('setsToWin') ?? 3;
  bool doppelAus = globals.prefs?.getBool('doppelAus') ?? false;
  bool masterAus = globals.prefs?.getBool('masterAus') ?? false;
  bool score_301 = globals.prefs?.getBool('score_301') ?? false;

  @override
  void initState() {
    legsToSetController.text = legsToSet.toString();
    setsToWinController.text = setsToWin.toString();
    if(doppelAus) masterAus = false;
    super.initState();
  }

  @override
  void dispose() {
    globals.prefs?.setInt('legsToSet', legsToSet);
    globals.prefs?.setInt('setsToWin', setsToWin);
    globals.prefs?.setBool('doppelAus', doppelAus);
    globals.prefs?.setBool('masterAus', masterAus);
    globals.prefs?.setBool('score_301', score_301);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontSize: 21);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const StatisticsViewer()));
            },
          )
        ],
      ),
      body: Center(
      child: Table(
        defaultColumnWidth: const MaxColumnWidth(FixedColumnWidth(200), FixedColumnWidth(100)),
        defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
        children: [
          TableRow(
            children: [
              const Text("Legs pro Set: ", style: labelStyle),
              TextField(
                controller: legsToSetController,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  MyNumberInput(min: 1),
                ],
                onChanged: (value) {
                  legsToSet = value.isEmpty ? 1 : int.parse(value);
                },
              ),
            ]
          ),
          TableRow(
              children: [
                const Text("Sets für den Sieg: ", style: labelStyle),
                TextField(
                  controller: setsToWinController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MyNumberInput(min: 1),
                  ],
                  onChanged: (value) {
                    setsToWin = value.isEmpty ? 1 : int.parse(value);
                  },
                ),
              ]
          ),
          TableRow(
            children: [
              const Text("Doppel Aus: ", style: labelStyle),
              SwitchListTile(
                value: doppelAus,
                onChanged: (value) {
                  setState(() {
                    doppelAus = value;
                    if(masterAus && doppelAus) masterAus = false;
                  });
                },
              )
            ]
          ),
          TableRow(
              children: [
                const Text("Master Aus: ", style: labelStyle),
                SwitchListTile(
                  value: masterAus,
                  onChanged: (value) {
                    setState(() {
                      masterAus = value;
                      if(masterAus && doppelAus) doppelAus = false;
                    });
                  },
                )
              ]
          ),
          TableRow(
              children: [
                const Text("Standart Score 301: ", style: labelStyle),
                SwitchListTile(
                  value: score_301,
                  onChanged: (value) {
                    setState(() {
                      score_301 = value;
                    });
                  },
                )
              ]
          )
        ],
      ),
      ),
    );
  }
}

