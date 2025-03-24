import 'package:flutter/cupertino.dart';

//CustomTileData für die Liste der an einzelnen Aktivitäten

class TerminData {
  final IconData icon;
  final String terminName;
  final String dayKey;
  final String timeEnd;
  final String weekKey;

  TerminData({
    required this.timeEnd,
    required this.icon,
    required this.terminName,
    required this.dayKey,
    required this.weekKey,
  });
}