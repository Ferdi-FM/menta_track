import 'package:flutter/cupertino.dart';

//CustomTileData für die Liste der Wochenpläne

class NotAnsweredData {
  final IconData icon;
  final String terminName;
  final String dayKey;
  final String weekKey;

  NotAnsweredData({
    required this.icon,
    required this.terminName,
    required this.dayKey,
    required this.weekKey,
  });
}