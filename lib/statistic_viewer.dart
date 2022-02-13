import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dart_counter/settings.dart';
import 'package:dart_counter/globals.dart' as globals;
import 'package:flutter/rendering.dart';
import 'package:dart_counter/statistics.dart';

class StatisticsViewer extends StatefulWidget {
  const StatisticsViewer({Key? key}) : super(key: key);

  @override
  _StatisticsViewerState createState() => _StatisticsViewerState();
}

class _StatisticsViewerState extends State<StatisticsViewer> {
  String currentPlayer = globals.statistics?.players.isEmpty ?? true ? "" : globals.statistics?.players.keys.first ?? "";
  final _scrollController = ScrollController();
  static const _extraScrollSpeed = 20;

  @override
  void initState() {
    _scrollController.addListener(() {
      ScrollDirection scrollDirection = _scrollController.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle)
      {
        double scrollEnd = _scrollController.offset + (scrollDirection == ScrollDirection.reverse
            ? _extraScrollSpeed
            : -_extraScrollSpeed);
        scrollEnd = min(
            _scrollController.position.maxScrollExtent,
            max(_scrollController.position.minScrollExtent, scrollEnd));
        _scrollController.jumpTo(scrollEnd);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    globals.statistics?.save();
    super.dispose();
  }

  int _toPercent(int val, int total) {
    if (total < 1) return 0;
    return (val / total * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final player = currentPlayer.isEmpty ? null : globals.statistics?.players[currentPlayer];

    const textStyle = TextStyle(fontSize: 35, color: Colors.black);
    const headerStyle = TextStyle(fontSize: 42, color: Colors.black, decoration: TextDecoration.underline);
    const tableElementStyle = TextStyle(fontSize: 26, color: Colors.black);
    const tableHeaderStyle = TextStyle(fontSize: 30, color: Colors.black);

    if(player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Spieler Statistik"),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
              },
            ),
          ],
        ),
        body: const Center(
          child:
            Text("Es existieren momentan noch keine Statistiken.\nSpielt ein Match und versucht es dann erneut.",
            style: textStyle
          ),
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spieler Statistik"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    underline: Container(color: Colors.transparent),
                    style: headerStyle.merge(const TextStyle(fontStyle: FontStyle.italic)),
                    alignment: AlignmentDirectional.centerEnd,
                    value: currentPlayer,
                    iconSize: 0.0,
                    items: globals.statistics?.players.keys.toList().map(
                    (element) => DropdownMenuItem<String>(
                      value: element,
                      child: Text(element),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                      currentPlayer = value!;
                      });
                    },
                  ),
                  const Text("'s Statistik", style: headerStyle),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 35),
                    onPressed: () {
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: const Text("Spieler löschen", style: TextStyle(color: Colors.red)),
                        content: Text("Sind sie sicher, dass sie $currentPlayer's Statistiken löschen möchten?"),
                        actions: [
                          TextButton(
                            child: const Text("Ja"),
                            onPressed: () {
                              setState(() {
                                globals.statistics?.players.remove(currentPlayer);
                                globals.statistics?.lastPlayers.remove(currentPlayer);
                                currentPlayer = globals.statistics?.players.isEmpty ?? true ? "" : globals.statistics?.players.keys.first ?? "";
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                          TextButton(
                            child: const Text("Nein"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ));
                    },
                  )
                ],
              ),
              Container(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.lightBlueAccent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: Text("$currentPlayer hat bereits\n"
                                            "${player.games} Spiele gespielt\n"
                                            "und ${player.wins} davon gewonnen!",
                                  style: textStyle
                                ),
                              ),
                              Flexible(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image.asset("assets/Sieg.jpg"),
                                  )
                              ),
                            ],
                          )
                        ),
                      )
                    ),
                    const Spacer(flex: 1)
                  ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                    children: [
                      const Spacer(flex: 1),
                      Flexible(
                          flex: 2,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.lightBlueAccent,
                            ),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: Text("Bei einer Gesamtzahl von\n"
                                          "${player.totalLegs} Legs hat $currentPlayer ${player.wonLegs} gewonnen!\n"
                                          "Das sind ${_toPercent(player.wonLegs, player.totalLegs)}%!",
                                          style: textStyle,
                                      ),
                                    ),
                                    Flexible(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: Image.asset("assets/Wurf.jpg"),
                                        )
                                    ),
                                  ],
                                )
                            ),
                          )
                      ),
                    ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                    children: [
                      Flexible(
                          flex: 2,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.lightBlueAccent,
                            ),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: Image.asset("assets/Bull.jpg"),
                                        )
                                    ),
                                    Flexible(
                                      child: Text("Von ${player.totalSets} Sets hat $currentPlayer\n"
                                          "${player.wonSets}, also ${_toPercent(player.wonSets, player.totalSets)}%\n"
                                          "gewonnen!",
                                          style: textStyle
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          )
                      ),
                      const Spacer(flex: 1)
                    ]
                ),
              ),
              const Divider(height: 60, color: Colors.black, thickness: 0.1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.lightBlueAccent,
                          ),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: Text("$currentPlayer hat von ${player.totalDoubleTries} Doppel-Versuchen\n"
                                        "${player.totalDoubleHits} getroffen! Das ist eine\n"
                                        "Quote von ${_toPercent(player.totalDoubleHits, player.totalDoubleTries)}%",
                                        style: textStyle
                                    ),
                                  ),
                                  Flexible(
                                    child: Text("$currentPlayer hat schon ${player.hits[20]?.tripleHits}\nmal die 180 getroffen!",
                                        style: textStyle
                                    ),
                                  ),
                                  Flexible(
                                    child: Text("${player.hits.entries.reduce((value, element) {
                                      final val = ScoreElement.copy(value.value);
                                      val.totalHits += element.value.totalHits;
                                      return MapEntry(value.key, val);
                                    }).value.totalHits} Pfeile wurden bereits\nvon $currentPlayer geworfen!\nDas ist 'ne ganze Menge",
                                        style: textStyle
                                    ),
                                  ),
                                ],
                              )
                          ),
                        )
                      ),
                    ]
                  ),
                ),
              ),
              const Divider(height: 60, color: Colors.black, thickness: 0.1),
              Text("$currentPlayer's Wurf Statistik", style: textStyle),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.lightBlueAccent.shade100,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Table(
                      border: TableBorder.all(),
                      children: [
                        const TableRow(
                          children: [
                            Padding(child: Text("Feld", style: tableHeaderStyle), padding: EdgeInsets.all(5),),
                            Padding(child: Text("Treffer", style: tableHeaderStyle), padding: EdgeInsets.all(5),),
                            Padding(child: Text("Doppel", style: tableHeaderStyle), padding: EdgeInsets.all(5),),
                            Padding(child: Text("Triple", style: tableHeaderStyle), padding: EdgeInsets.all(5),),
                          ]
                        )
                      ] +
                      (() { final list = List<MapEntry<int, ScoreElement>>.of(player.hits.entries);
                        list.sort((a, b) => a.key.compareTo(b.key));
                        return list;
                      }().map((entry) {
                      return TableRow(
                        children: [
                          Padding(child: Text(entry.key.toString(), style: tableElementStyle), padding: const EdgeInsets.all(5),),
                          Padding(child: Text(entry.value.totalHits.toString(), style: tableElementStyle), padding: const EdgeInsets.all(5),),
                          Padding(child: Text(entry.value.doubleHits.toString(), style: tableElementStyle), padding: const EdgeInsets.all(5),),
                          Padding(child: Text(entry.value.tripleHits.toString(), style: tableElementStyle), padding: const EdgeInsets.all(5),),
                        ]
                      );
                      }).toList()),
                    )
                  ),
                ),
              ),
            ],
          )
        )
      )
    );
  }
}