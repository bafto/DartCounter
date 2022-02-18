// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScoreElement _$ScoreElementFromJson(Map<String, dynamic> json) => ScoreElement(
      json['totalHits'] as int? ?? 0,
      json['doubleHits'] as int? ?? 0,
      json['tripleHits'] as int? ?? 0,
    );

Map<String, dynamic> _$ScoreElementToJson(ScoreElement instance) =>
    <String, dynamic>{
      'totalHits': instance.totalHits,
      'doubleHits': instance.doubleHits,
      'tripleHits': instance.tripleHits,
    };

StatisticPlayer _$StatisticPlayerFromJson(Map<String, dynamic> json) =>
    StatisticPlayer(
      (json['hits'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                int.parse(k), ScoreElement.fromJson(e as Map<String, dynamic>)),
          ) ??
          {},
      json['games'] as int? ?? 0,
      json['wins'] as int,
      json['totalLegs'] as int? ?? 0,
      json['wonLegs'] as int? ?? 0,
      json['totalSets'] as int? ?? 0,
      json['wonSets'] as int? ?? 0,
      json['totalDoubleTries'] as int? ?? 0,
      json['totalDoubleHits'] as int? ?? 0,
      json['total180HIts'] as int? ?? 0,
    );

Map<String, dynamic> _$StatisticPlayerToJson(StatisticPlayer instance) =>
    <String, dynamic>{
      'hits': instance.hits.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'games': instance.games,
      'wins': instance.wins,
      'totalLegs': instance.totalLegs,
      'wonLegs': instance.wonLegs,
      'totalSets': instance.totalSets,
      'wonSets': instance.wonSets,
      'totalDoubleTries': instance.totalDoubleTries,
      'totalDoubleHits': instance.totalDoubleHits,
      'total180HIts': instance.total180HIts,
    };

Statistics _$StatisticsFromJson(Map<String, dynamic> json) => Statistics()
  ..lastPlayers = (json['lastPlayers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      []
  ..players = (json['players'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, StatisticPlayer.fromJson(e as Map<String, dynamic>)),
      ) ??
      {};

Map<String, dynamic> _$StatisticsToJson(Statistics instance) =>
    <String, dynamic>{
      'lastPlayers': instance.lastPlayers,
      'players': instance.players.map((k, e) => MapEntry(k, e.toJson())),
    };
