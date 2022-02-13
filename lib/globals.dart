library dart_counter.globals;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_counter/statistics.dart';
import 'dart:convert';

SharedPreferences? prefs;
Statistics? statistics;

void init() async {
  prefs ??= await SharedPreferences.getInstance();
  //prefs?.remove("statistics"); //for testing
  statistics ??= Statistics.fromJson(jsonDecode(prefs?.getString("statistics") ?? "{}"));
}