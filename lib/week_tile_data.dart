import 'package:flutter/cupertino.dart';

//CustomTileData für die Liste der Wochenpläne

class WeekTileData {
  final Icon icon;
  final String title;
  final String subTitle;
  final String weekKey;

  WeekTileData({
    required this.icon,
    required this.title,
    required this.weekKey,
    required this.subTitle,
  });

  @override
  String toString() {
    return "{icon: $icon; title: $title; weekKey: $weekKey; ";
  }
}