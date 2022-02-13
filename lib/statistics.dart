import 'dart:convert';

import 'package:dart_counter/globals.dart' as globals;
import 'package:json_annotation/json_annotation.dart';

part 'statistics.g.dart';

@JsonSerializable(explicitToJson: true)
class ScoreElement {
  @JsonKey(defaultValue: 0)
  int totalHits = 0;
  @JsonKey(defaultValue: 0)
  int doubleHits = 0;
  @JsonKey(defaultValue: 0)
  int tripleHits = 0;

  ScoreElement(this.totalHits, this.doubleHits, this.tripleHits);
  ScoreElement.copy(ScoreElement element)
    :
      totalHits = element.totalHits,
      doubleHits = element.doubleHits,
      tripleHits = element.tripleHits;

  factory ScoreElement.fromJson(Map<String, dynamic> json) => _$ScoreElementFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreElementToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StatisticPlayer {
  @JsonKey(defaultValue: {})
  Map<int, ScoreElement> hits = {}; //key: value of the field; value: hit counts on that field
  @JsonKey(defaultValue: 0)
  int games = 0;
  int wins = 0;
  @JsonKey(defaultValue: 0)
  int totalLegs = 0;
  @JsonKey(defaultValue: 0)
  int wonLegs = 0;
  @JsonKey(defaultValue: 0)
  int totalSets = 0;
  @JsonKey(defaultValue: 0)
  int wonSets = 0;
  @JsonKey(defaultValue: 0)
  int totalDoubleTries = 0;
  @JsonKey(defaultValue: 0)
  int totalDoubleHits = 0;

  StatisticPlayer(this.hits, this.games, this.wins, this.totalLegs, this.wonLegs, this.totalSets, this.wonSets, this.totalDoubleTries, this.totalDoubleHits);

  factory StatisticPlayer.fromJson(Map<String, dynamic> json) => _$StatisticPlayerFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticPlayerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Statistics {
  @JsonKey(defaultValue: [])
  List<String> lastPlayers = [];
  @JsonKey(defaultValue: {})
  Map<String, StatisticPlayer> players = {};

  Statistics();

  factory Statistics.fromJson(Map<String, dynamic> json) => _$StatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsToJson(this);

  void save() {
    globals.prefs?.setString("statistics", jsonEncode(this));
  }
}