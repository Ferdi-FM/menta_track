import 'package:flutter/cupertino.dart';

//CustomTileData für die Liste der Wochenpläne

class NotAnsweredData {
  final IconData icon;
  final String title;
  final String dayKey;
  final String weekKey;
  final String terminName;

  NotAnsweredData({
    required this.icon,
    required this.title,
    required this.dayKey,
    required this.weekKey,
    required this.terminName,
  });
}