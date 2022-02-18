import 'package:dart_counter/main.dart';
import 'package:dart_counter/statistic_viewer.dart';
import 'package:dart_counter/statistics.dart';
import 'package:flutter/material.dart';
import 'package:dart_counter/dart_board.dart';
import 'package:dart_counter/settings.dart';
import 'package:dart_counter/globals.dart' as globals;

class Player {
  final String name;
  int score = ((globals.prefs?.getBool("score_301") ?? false) ? 301 : 501);
  int sets = 0;
  int legs = 0;

  Player(this.name);
  Player.copy(Player p) //why do I even need this?
    :
    name = p.name,
    score = p.score,
    sets = p.sets,
    legs = p.legs;
}

class SavedMove {
  MapEntry<String, List<DartBoardClickData>> score;
  final List<Player> playerStates;
  DartBoardClickData lastThrow;
  int currentPlayer;
  int currentLegStarter;
  int currentSetStarter;

  SavedMove({required List<Player> playerStates, required MapEntry<String, List<DartBoardClickData>> score,
    required this.currentPlayer, required this.currentLegStarter,
    required this.currentSetStarter, required this.lastThrow})
    :
    playerStates = List.generate(playerStates.length, (index) => Player.copy(playerStates[index])), //god damn "pAsS By ReFeReNcE"
    score = MapEntry(score.key, List.generate(score.value.length, (index) => DartBoardClickData.copy(score.value[index])));
}

class InGame extends StatefulWidget {
  final List<String> playerNames;

  const InGame({Key? key, required this.playerNames}) : super(key: key);

  @override
  _InGameState createState() => _InGameState();
}

class _InGameState extends State<InGame> {
  List<Player> players = [];
  final List<DartBoardClickData> clickData = List.filled(3, DartBoardClickData.empty());
  int currentThrow = 0;
  int currentPlayer = 0;
  int legStarter = 0; //Player who started the leg
  int setStarter = 0; //Player who started the set
  DartBoardClickData lastThrow = DartBoardClickData.empty();
  List<SavedMove> savedMoves = List.empty(growable: true);
  int currentSavedMove = -1;
  static const maxSavedMoves = 30;
  final _scrollController = ScrollController();
  String winner = ""; //set if someone won

  @override
  void initState() {
    for (final name in widget.playerNames) {
      players.add(Player(name));
    }
    super.initState();
  }

  @override
  void dispose() {
    _finishStatistics(winner);
    globals.statistics?.save();
    super.dispose();
  }

  void _finishStatistics(String winner) {
    for (final move in savedMoves) {
      _addToStatistics(move);
    }

    if (winner.isNotEmpty) globals.statistics?.players[winner]?.wins++;

    final totalSets = players.reduce((value, element) {
      final val = Player.copy(value);
      val.sets += element.sets;
      return val;
    }).sets;

    final totalLegs = players.reduce((value, element) {
      final val = Player.copy(value);
      val.legs += element.legs;
      return val;
    }).legs;

    globals.statistics?.lastPlayers.clear();
    for (final player in players) {
      globals.statistics?.players[player.name]?.totalSets += totalSets;
      globals.statistics?.players[player.name]?.totalLegs += totalLegs;
      globals.statistics?.players[player.name]?.wonSets += player.sets;
      globals.statistics?.players[player.name]?.wonLegs += player.legs;
      globals.statistics?.players[player.name]?.games++;
      globals.statistics?.lastPlayers.add(player.name);
    }
  }

  void _addToStatistics(SavedMove move) {
    final doppelAus = globals.prefs?.getBool("doppelAus") ?? false;
    final masterAus = globals.prefs?.getBool("masterAus") ?? false;

    final player = move.score.key;
    final score = move.score.value;

    if(!(globals.statistics?.players.containsKey(player) ?? false)) {
      globals.statistics?.players[player] = StatisticPlayer({}, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    }

    if (score.reduce((value, element) => DartBoardClickData(value: value.value + element.value, isDouble: false, isTriple: false)).value == 180) {
      globals.statistics?.players[player]?.total180HIts++;
    }

    for (final _hit in score) {
      final hit = DartBoardClickData.copy(_hit);

      final throwUntilNow = score.sublist(0, score.indexOf(_hit));
      final currentPlayerScore = move.playerStates[move.currentPlayer].score;
      final val = _calculateMissing(currentPlayerScore, throwUntilNow);

      if (hit.isDouble) {
        if(hit.value != 50) hit.value ~/= 2;

        if ((doppelAus || masterAus) && val.isEven && (val <= 40 || val == 50) && hit.value * 2 == val) {
          globals.statistics?.players[player]?.totalDoubleHits++;
        }
      }

      if (hit.isTriple) {
        hit.value ~/= 3;

        if (masterAus && val <= 60 && hit.value * 3 == val) {
          globals.statistics?.players[player]?.totalDoubleHits++;
        }
      }

      if ((doppelAus && val.isEven && ((val <= 40 || val == 50) && val > 0)) || (masterAus && val <= 60 && val > 0 && (val <= 40 ? val.isEven || val % 3 == 0 : val % 3 == 0))) {
        globals.statistics?.players[player]?.totalDoubleTries++;
      }

      if(!(globals.statistics?.players[player]?.hits.containsKey(hit.value) ?? false)) {
        globals.statistics?.players[player]?.hits[hit.value] = ScoreElement(0, 0, 0);
      }

      globals.statistics?.players[player]?.hits[hit.value]?.totalHits++;
      if (hit.isDouble) globals.statistics?.players[player]?.hits[hit.value]?.doubleHits++;
      if (hit.isTriple) globals.statistics?.players[player]?.hits[hit.value]?.tripleHits++;
    }
  }

  void _pushMove(SavedMove move) {
    savedMoves.add(move);
    if (savedMoves.length > maxSavedMoves) {
      _addToStatistics(savedMoves[0]);
      savedMoves.removeAt(0);
    }
    currentSavedMove = savedMoves.length - 1;
    WidgetsBinding.instance?.addPostFrameCallback((_) => _scrollDown());
  }

  SavedMove _popMove() {
    return savedMoves.removeLast();
  }

  void _undoMoves(int n) {
    for (int i = 0; i < n; i++) {
      final move = _popMove();
      players = move.playerStates;
      lastThrow = move.lastThrow;
      legStarter = move.currentLegStarter;
      setStarter = move.currentSetStarter;
      currentPlayer = move.currentPlayer;
    }
  }

  void _resetPlayerScores() {
    for(int i = 0; i < players.length; i++) {
      players[i].score = ((globals.prefs?.getBool("score_301") ?? false) ? 301 : 501);
    }
  }

  void _resetPlayerLegs() {
    for(int i = 0; i < players.length; i++) {
      players[i].legs = 0;
    }
  }

  void _advanceCurrentPlayer() {
    if (currentPlayer < players.length - 1) {
      currentPlayer++;
    }
    else {
      currentPlayer = 0;
    }
  }

  void _advanceLegStarter() {
    if (legStarter < players.length - 1) {
      legStarter++;
    }
    else {
      legStarter = 0;
    }
  }

  void _advanceSetStarter() {
    if (setStarter < players.length - 1) {
      setStarter++;
    }
    else {
      setStarter = 0;
    }
  }

  int _calculateThrowScore(List<DartBoardClickData> clickData) {
    if(clickData.isEmpty) return 0;
    return clickData.reduce((value, element)
    {
      return DartBoardClickData(value: value.value + element.value, isDouble: false, isTriple: false);
    }).value;
  }

  int _calculateMissing(int score, List<DartBoardClickData> clickData) {
    return score - _calculateThrowScore(clickData);
  }

  void _onDartBoardClick(DartBoardClickData data) {
    setState(() {
      clickData[currentThrow] = data;
      lastThrow = data;
      if(currentThrow < 2) currentThrow++;
    });
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn
      );
    }
  }
  
  bool _doppelAusFulfilled() {
    final doppelAus = globals.prefs?.getBool("doppelAus") ?? false;
    return (doppelAus && lastThrow.isDouble) || (!doppelAus);
  }

  bool _masterAusFulfilled() {
    final masterAus = globals.prefs?.getBool("masterAus") ?? false;
    return (masterAus && (lastThrow.isDouble || lastThrow.isTriple)) || (!masterAus);
  }

  void _addScore() {
    setState(() {
      final doppelAus = globals.prefs?.getBool("doppelAus") ?? false;
      final masterAus = globals.prefs?.getBool("masterAus") ?? false;

      currentThrow = 0;

      int subtractedScore = _calculateThrowScore(clickData);
      SavedMove move = SavedMove(
          playerStates: players,
          score: MapEntry("", [DartBoardClickData.empty()]),
          currentPlayer: currentPlayer,
          currentLegStarter: legStarter,
          currentSetStarter: setStarter,
          lastThrow: DartBoardClickData.copy(lastThrow));

      // we subtract nothing if the leg condition is not fullfiled
      if(players[currentPlayer].score - subtractedScore < 0 ||
          (players[currentPlayer].score - subtractedScore == 0 &&
          (!_doppelAusFulfilled() || !_masterAusFulfilled())) ||
          ((doppelAus || masterAus) && players[currentPlayer].score - subtractedScore == 1)) {
        subtractedScore = 0;
      }

      move.score = MapEntry(players[currentPlayer].name, List.from(clickData));
      _pushMove(move);
      players[currentPlayer].score -= subtractedScore;

      if(players[currentPlayer].score == 0) {
        players[currentPlayer].legs++;
        if (players[currentPlayer].legs >
            ((globals.prefs?.getInt("legsToSet") ?? 3) - 1)) {
          players[currentPlayer].sets++;
          if (players[currentPlayer].sets > ((globals.prefs?.getInt("setsToWin") ?? 3) - 1)) _onWin(players[currentPlayer].name);
          _resetPlayerLegs();
          _advanceSetStarter();
          legStarter = setStarter - 1;
        }
        _resetPlayerScores();
        _advanceLegStarter();
        currentPlayer = legStarter;
      }
      else {
        _advanceCurrentPlayer();
      }

      // reset the side bar
      for (int i = 0; i < clickData.length; i++) {
        clickData[i] = DartBoardClickData.empty();
      }
    });
  }

  void _onWin(String winner) {
    this.winner = winner;
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => HomeScreen(winner: winner)));
  }

  Text _generateScoreText(int i) {
    final scoreStyle = TextStyle(fontSize: 24, color: i == currentThrow ? Colors.red : Colors.black);
    final c = clickData[i];
    return Text("Wurf ${i+1}: ${c.value} ${c.isDouble && c.value != 25 ? "(Doppel ${c.value~/2})" : (c.isTriple && c.value != 50 ? "(Triple ${c.value~/3})" : (c.value == 50 ? "(Bullseye)" : ""))}", style: scoreStyle);
  }

  Widget _buildRightSideBar() {
    const textStyle = TextStyle(fontSize: 24);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 11,
              child: DataTable(
                columnSpacing: 0,
                horizontalMargin: 0,
                headingRowHeight: 0,
                showCheckboxColumn: false,
                columns: [
                  DataColumn(label: Container())
                ],
                rows: List<DataRow>.generate(3,
                  (index) => DataRow(
                    onSelectChanged: (value) {
                      setState(() {
                      currentThrow = index;
                      });
                    },
                    selected: index == currentThrow,
                    cells: [DataCell(_generateScoreText(index))],
                    ),
                )
              ),
            ),
            const Divider(color: Colors.black),
            Flexible(
                flex: 3,
                child: Text("Gesamt: ${_calculateThrowScore(clickData)}", style: textStyle)
            ),
            const Spacer(flex: 1),
            Flexible(
                flex: 3,
                child: Text("Übrig: ${_calculateMissing(players[currentPlayer].score, clickData)}",
                style:
                (_calculateMissing(players[currentPlayer].score, clickData) < 0 ||
                (_calculateMissing(players[currentPlayer].score, clickData) == 0 && !_doppelAusFulfilled()) ||
                (_calculateMissing(players[currentPlayer].score, clickData) == 0 && !_masterAusFulfilled()))
                    ? textStyle.merge(const TextStyle(color: Colors.red)) : textStyle)
            ),
            const Spacer(flex: 1),
            Flexible(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _addScore,
                  child: const Text("Bestätigen", style: textStyle)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftSideBar() {
    if(savedMoves.isEmpty) return Container(color: Colors.transparent);

    const textStyle = TextStyle(fontSize: 24);
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Flexible(
            flex: 11,
            child: Card( //wrap the ListView inside a card because of clipping issues with ListTiles
              color: Theme.of(context).scaffoldBackgroundColor,
              shadowColor: Colors.transparent,
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: savedMoves.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    //selected: currentSavedMove == index,
                    dense: true,
                    selectedColor: Colors.black,
                    selectedTileColor: Colors.grey.shade300,
                    title: Text(
                      "${savedMoves[index].score.key}: ${_calculateThrowScore(savedMoves[index].score.value)}",
                      style: textStyle,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      splashRadius: 20,
                      highlightColor: Colors.grey.shade500,
                      onPressed: () {
                        setState(() {
                          _undoMoves(savedMoves.length - index);
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        currentSavedMove = index;
                      });
                    },
                  );
                }
              ),
            ),
          ),
          const Spacer(flex: 1),
          Flexible(
            flex: 3,
            child: Center(
              child: IntrinsicWidth(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _undoMoves(1);
                    });
                  },
                  child: const Text("Zurück", style: textStyle, textAlign: TextAlign.center),
                )
              )
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    const headerStyle = TextStyle(fontSize: 23);
    const rowStyle = TextStyle(fontSize: 19);
    return LayoutBuilder(builder: (context, constraints) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width),
          child: DataTable(
            showCheckboxColumn: false,
            dataRowHeight: constraints.maxHeight / (players.length + 1),
            headingRowHeight: constraints.maxHeight / (players.length + 1),
            columnSpacing: 0,
            horizontalMargin: 5,
            columns: const <DataColumn>[
              DataColumn(label: Text("Name", style: headerStyle)),
              DataColumn(label: Text("Sets", style: headerStyle)),
              DataColumn(label: Text("Legs", style: headerStyle)),
              DataColumn(label: Text("Score", style: headerStyle)),
            ],
            rows: List<DataRow>.generate(players.length,
              (index) => DataRow(
                onSelectChanged: (value) {
                  setState(() {
                    currentPlayer = index;
                  });
                },
                selected: index == currentPlayer,
                cells: List.generate(4,
                  (i) {
                    TextStyle actualStyle = rowStyle;
                    if (index == currentPlayer) actualStyle = actualStyle.merge(const TextStyle(color: Colors.red));
                    String text = "";
                    switch (i) {
                      case 0:
                        text = players[index].name;
                        break;
                      case 1:
                        text = players[index].sets.toString();
                        break;
                      case  2:
                        text = players[index].legs.toString();
                        break;
                      case 3:
                        text = players[index].score.toString();
                    }
                    return DataCell(
                        Text(text, style: index == legStarter && i == 0 ? actualStyle.merge(const TextStyle(decoration: TextDecoration.underline)) : actualStyle),
                    );
                  }
                )
              )
            ),
          )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Match"),
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
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Flexible(
                    flex: 5,
                    child: Row(
                      children: [
                        Flexible(
                            flex: 2,
                            child: _buildLeftSideBar(),
                        ),
                        Flexible(
                            flex: 5,
                            child: DartBoard(
                              onClick: _onDartBoardClick,
                            )
                        ),
                        Flexible(
                            flex: 2,
                            child: _buildRightSideBar(),
                        ),
                      ],
                    )
                ),
                Flexible(
                    flex: 2,
                    child: _buildDataTable(context),
                )
              ],
            )
          )
        ]
      )
    );
  }
}
