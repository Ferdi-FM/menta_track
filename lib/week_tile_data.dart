import 'package:flutter/cupertino.dart';

//CustomTileData für die Liste der Wochenpläne

class WeekTileData {
  final IconData icon;
  final String title;
  final String weekKey;

  WeekTileData({
    required this.icon,
    required this.title,
    required this.weekKey,
  });

  @override
  String toString() {
    return "{icon: $icon; title: $title; weekKey: $weekKey; ";
  }
}